#' Use first location to identify nest location
#'
#' @param GPS_data A data frame with GPS data
#' @param column_lon The name of the column where the longitude data is in your data frame. 
#' @param column_lat The name of the column where the latitude data is your data frame. 
#'
#' @return The nest location
#' @export
#'
#' @examples GPS01_nest<-locate_nest(GPS_data = GPS01,column_lat = 'Longitude',column_lon = 'Latitude')
locate_nest<-function(GPS_data=GPS_data,
                         column_lon=column_lon,
                         column_lat=column_lat){
  
  data<-GPS_data
  var1<-column_lon
  var2<-column_lat
  
  nest_loc<-data %>%
    dplyr::summarise(
      Longitude = dplyr::first(data[[var1]]),
      Latitude  = dplyr::first(data[[var2]]), )
  
  print(nest_loc)
  return(nest_loc)
}
