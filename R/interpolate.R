#' A function to interpolate your data at an specific interval
#'
#' @param GPS_data you GPS data
#' @param interval the interval in seconds
#' @param column_datetime a column with date and time, and in a date time format
#' @param column_lat the name of your column with the 'Latitude' data
#' @param column_lon the name of your column with the 'Longitude' data
#'
#' @return returns a interpolated data frame using the interval provided
#' @export
#'
#' @examples GPS01_trip5 <-GPS_preparado[GPS_preparado$ID == 'GPS01' & GPS_preparado$trip_number=='trip_5',]
#' GPS01_trip1_interpolated<-interpolate(GPS_data = GPS01_trip5,interval='10 sec',
#' column_datetime = 'dia_hora',column_lat = 'Latitude',column_lon = 'Longitude')
interpolate<-function (GPS_data = GPS_data, 
                       interval = interval, 
                       column_datetime = column_datetime, 
                       column_lat = column_lat, 
                       column_lon = column_lon){
  
  Inter_df <- GPS_data
  Inter_df$dt <- Inter_df[[column_datetime]]
  
  Inter_df$Longitude <- Inter_df[[column_lon]]
  Inter_df$Latitude <- Inter_df[[column_lat]]
  
  New_longitude0 <- stats::approx(Inter_df$dt, Inter_df$Longitude, 
                                  xout = seq(min(Inter_df$dt), max(Inter_df$dt), by = interval))
  New_longitude1 <- data.frame(x = New_longitude0$x, y = New_longitude0$y)
  
  New_latitude0 <- stats::approx(Inter_df$dt, Inter_df$Latitude,
                                 xout = seq(min(Inter_df$dt), max(Inter_df$dt), by = interval))
  
  New_latitude1 <- data.frame(x = New_latitude0$x, y = New_latitude0$y)
  
  New_coords <- cbind(New_longitude1, New_latitude1)
  
  New_coords$trip_number <- unique(Inter_df$trip_number)
  
  DateTimeGMT <- "DateTimeGMT"
  Latitude <- "Latitude"
  Longitude <- "Longitude"
  
  colnames(New_coords)[1] <- DateTimeGMT
  colnames(New_coords)[2] <- Longitude
  colnames(New_coords)[4] <- Latitude
  
  New_coords <- New_coords[, c("DateTimeGMT", 
                               "Longitude", 
                               "Latitude")]
  return(New_coords)
}