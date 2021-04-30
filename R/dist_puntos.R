#' Agrega una columna con la distancia entre cada punto. 
#'
#' @param GPS_edited es un data frame con datos de Longitude y Latitude
#'
#' @return el mismo data frame con una columna llamada pointsdist_km
#' @export
#'
#' @examples GPS_dist<-dist_puntos(GPS_edited = GPS_edited)
dist_puntos<-function(GPS_edited = GPS_edited){
  
  Viajes_df<-as.data.frame(GPS_edited)
  
  #separa los viajes
  Viajes_list<-split(Viajes_df,Viajes_df$trip_number)
  
  #calcula para cada elemento de la lista
  for( i in seq_along(Viajes_list)){
    Viaje_df<-Viajes_list[[i]]  
    Viaje_coords<- Viaje_df[,c('Longitude','Latitude')]
    Viaje_spatial <- sp::SpatialPointsDataFrame(coords = Viaje_coords, data = Viaje_df)
    sp::proj4string(Viaje_spatial)= sp::CRS("+init=epsg:4326")  
    
    #calcula la distancia para cada punto  
    Viaje_distancias<-sapply(2:nrow(Viaje_spatial),
                             function(i){geosphere::distm( Viaje_spatial[i-1,], Viaje_spatial[i,])})
    
    #c(sf::st_distance(my_df[-1,],my_df[-nrow(my_df),],by_element=TRUE),NA)
    
    Viaje_distancias<-c(NA,Viaje_distancias)
    Viaje_df$pointsdist_km<-round(Viaje_distancias/1000,2)
    
    Viajes_list[[i]]<-Viaje_df
  }
  
  
  Viajes_df<- do.call("rbind",Viajes_list)
  
  cat("Una columna llamada pointsdist_km fue agregada al data frame,los valores corresponden a la distancia entre cada punto GPS")
  
  return(Viajes_df)
}