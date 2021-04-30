#' Calcula distancia recorrida de la colonia por viaje
#'
#' @param GPS_edited un data frame con datos de Longitude y Latitude
#'
#' @return regresa un nuevo data frame con la distancia total recorrida por viaje.
#' @export
#'
#' @examples totaldist_km<-calcular_totaldist(GPS_edited = GPS_edited)
calcular_totaldist<-function(GPS_edited = GPS_edited){
  
  # obtener distancia entre puntos
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
  
  
  # crear lista vacia
  Totaldist_list<-list()
  
  # calcular para cada elemento de la lista
  for( i in seq_along(Viajes_list)){
    
    data<-Viajes_list[[i]]
    var1<-"pointsdist_km"
      
    Totaldist_df <- data %>%
      dplyr::summarise(totaldist_km=sum(data[[var1]],na.rm=TRUE))
    
    trip_id<-dplyr::first(data$trip_number)
    
    Totaldist_list[[i]]<- data.frame(trip_id = trip_id,
                                     totaldist_km = Totaldist_df)
    
}
  
  Totaldist <- do.call("rbind",Totaldist_list)
  
  return(Totaldist)
}
