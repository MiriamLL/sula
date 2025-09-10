#' interpolate_trips, interpolate your tracking data to a specific interval per group
#'
#' @param GPS_data you GPS data
#' @param interval the interval in seconds
#' @param column_datetime a column with date and time, and in a date time format
#' @param column_lat the name of your column with the 'Latitude' data
#' @param column_lon the name of your column with the 'Longitude' data
#' @param column_group the name of your column with the group data
#'
#' @return Gives back a data frame with the interpolated data
#' @export 
#'
#' @examples GPS_interpolated<-interpolate_by_group(GPS_data=GPS_preparado,interval='900 sec',
#' column_datetime='dia_hora',column_lat='Latitude',column_lon='Longitude',column_group='trip_number')
#' 
interpolate_by_group<-function(GPS_data = GPS_data, 
                               interval = interval, 
                               column_datetime=column_datetime,
                               column_lat=column_lat,
                               column_lon = column_lon,
                               column_group=column_group) 
{
  df_to_interpolate <- GPS_data
  df_to_interpolate$dt <- df_to_interpolate[[column_datetime]]
  df_to_interpolate$Longitude <- df_to_interpolate[[column_lon]]
  df_to_interpolate$Latitude <- df_to_interpolate[[column_lat]]
  df_to_interpolate$group<-df_to_interpolate[[column_group]]
  
  df_to_interpolate <- df_to_interpolate[, c("group","dt", "Longitude", "Latitude")]
  colnames(df_to_interpolate) <- c("group","dt", "Longitude", "Latitude")
  
  if (class(df_to_interpolate$dt)[1] == "POSIXct") {'Column class from datetime is correctly in POSIXct'}
  else {stop(("Please change the class of your column_datetime, currently is not POSIXct"))}
  
  
  group_list <- split(df_to_interpolate, df_to_interpolate$group)
  small_trips <- lapply(group_list, function(x) nrow(x) > 3)
  long_trips <- group_list[unlist(small_trips)]
  
  for (i in seq_along(long_trips)) {
    separate_groups <- long_trips[[i]]
    
    separate_groups <- separate_groups[!duplicated(separate_groups$dt), ]
    
    new_longitude0 <- stats::approx(separate_groups$dt, separate_groups$Longitude, 
                                    xout = seq(min(separate_groups$dt), max(separate_groups$dt), by = interval))
    new_longitude1 <- data.frame(x = new_longitude0$x, y = new_longitude0$y)
    
    new_latitude0 <- stats::approx(separate_groups$dt,separate_groups$Latitude, 
                                   xout = seq(min(separate_groups$dt), max(separate_groups$dt), by = interval))
    new_latitude1 <- data.frame(x = new_latitude0$x, y = new_latitude0$y)
    
    new_coords <- cbind(new_longitude1, new_latitude1)
    
    new_coords$group <- unique(separate_groups$group)
    colnames(new_coords)<-c('dt','Longitude','x','Latitude','group')
    new_coords<-new_coords[c('group','dt','Longitude','Latitude')]
    
    long_trips[[i]] <- new_coords
  }
  
  interpolation_df<- do.call("rbind", long_trips)
  rownames(interpolation_df) <- NULL
  return(interpolation_df)
}
