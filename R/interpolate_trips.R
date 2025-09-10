#' interpolate_trips, interpolate your tracking data to a specific interval
#'
#' @param GPS_data Is the data you want to interpolate
#' @param interval Is the interval you want to use, in seconds, for example 900 s is 15 minutes
#' @param column_date Is the name of the column where you have the Date, if you dont have date separately, you can always create a new column only with the date
#' @param column_time Is the name of the column where you have the Time, if you dont have time separately in a column, you can always create a new column only with the time
#' @param datetime_format Is the format you use for your date and time, for example "%d/%m/%Y %H:%M:%S", "%d-%m-%Y %H:%M:%S" or "%Y-%m-%d %H:%M:%S"
#' @param column_lat Is the name of the column where you have the Latitude
#' @param column_lon Is the name of the column where you have the Longitude
#' @param column_trip Is the name of the column where you have the Trip number, if you dont have number of trip please check the function count_trips
#'
#' @return Gives back a data frame with the interpolated data, only four columns will be returned: dt, Longitude, Latitude, and trip_number
#' @export 
#'
#' @examples GPS_interpolated<-interpolate_trips(GPS_data=GPS01_trips,interval='900 sec',
#' column_date='DateGMT',column_time='TimeGMT',column_trip='trip_number',
#' column_lat='Latitude',column_lon='Longitude',datetime_format="%d/%m/%Y %H:%M:%S")

interpolate_trips<-function(GPS_data=GPS_data,
                            interval=interval,
                            column_date=column_date,
                            column_time=column_time,
                            datetime_format=datetime_format,
                            column_lat=column_lat,
                            column_lon=column_lon,
                            column_trip=column_trip){
  
  
  Inter_df <- GPS_data
  
  # Prepare columns
  Inter_df$date <- Inter_df[[column_date]]
  Inter_df$time <- Inter_df[[column_time]]
  Inter_df$dt <- paste(Inter_df$date,Inter_df$time)
  Inter_df$dt<-as.POSIXct(strptime(Inter_df$dt,datetime_format),tz = "GMT")
  
  Inter_df$Longitude <- Inter_df[[column_lon]]
  Inter_df$Latitude <- Inter_df[[column_lat]]
  Inter_df$trip_number <- Inter_df[[column_trip]]
  
  # Loop
  Trips_ls<-split(Inter_df,Inter_df$trip_number)
  
  for( i in seq_along(Trips_ls)){
    Trip_df <- Trips_ls[[i]] 
    
    
    # Longitude, make sure the column name corresponds, and dt must be in the right format
    New_longitude0 <- stats::approx(Trip_df$dt, Trip_df$Longitude,
                                    xout = seq(min(Trip_df$dt), max(Trip_df$dt), by = interval))
    New_longitude1 <- data.frame(x = New_longitude0$x, y = New_longitude0$y)
    
    # Latitude, make sure the column name corresponds
    New_latitude0 <- stats::approx(Trip_df$dt, Trip_df$Latitude, 
                                   xout = seq(min(Trip_df$dt), max(Trip_df$dt), by = interval))
    New_latitude1 <- data.frame(x = New_latitude0$x, y = New_latitude0$y)
    
    # Bind
    New_coords <- cbind(New_longitude1, New_latitude1)
    New_coords$trip_number <- unique(Trip_df$trip_number)
    
    trip_number<-'trip_number'
    DateTimeGMT<-'DateTimeGMT'
    Latitude<-'Latitude'
    Longitude<-'Longitude'
    
    colnames(New_coords)[1]<-DateTimeGMT
    colnames(New_coords)[2]<-Longitude
    colnames(New_coords)[4]<-Latitude
    colnames(New_coords)[5]<-trip_number
    
    
    New_coords <- New_coords[,c('trip_number','DateTimeGMT',"Longitude","Latitude")]
    
    Trips_ls[[i]]<- New_coords}
  
  Trips_interp <- do.call("rbind",Trips_ls)
  rownames(Trips_interp) <- NULL
  
  return(Trips_interp)
}
