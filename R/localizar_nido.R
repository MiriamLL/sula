#' Localiza las coordenadas donde esta el nido
#'
#' @param GPS_track data frame con los datos de GPS debe contener columna de latitud y de longitud en formato numerico.
#' @param lon_col nombre de la columna de longitud
#' @param lat_col nombre de la columna de latitud
#'
#' @return un data frame con la coordenada del nido para ese individuo
#' @export
#'
#' @examples nest_loc<-localizar_nido(GPS_track = GPS_01,lat_col="Latitude",lon_col="Longitude")
localizar_nido<-function(GPS_track=GPS_track,
                         lon_col=lon_col,
                         lat_col=lat_col){
  
  data<-GPS_track
  var1<-lon_col
  var2<-lat_col
  
  nest_loc<-data %>%
    dplyr::summarise(
      Longitude = dplyr::first(data[[var1]]),
      Latitude  = dplyr::first(data[[var2]]), )
  
  print(nest_loc)
  return(nest_loc)
}