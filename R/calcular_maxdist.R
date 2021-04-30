#' Calcular la distancia maxima de la colonia por viaje
#'
#' @param GPS_edited un data frame con las columnas 'Longitude' y 'Latitude'
#' @param nest_loc un data frame con las coordenadas de la colonia en 'Longitude','Latitude'
#'
#' @return regresa un data frame con los maximos de la colonia por viaje
#' @export
#'
#' @examples nest_loc<-data.frame(Longitude = -109.4531, Latitude = -27.20097)
#' maxdist_km<-calcular_maxdist(GPS_edited=GPS_edited, nest_loc=nest_loc)
calcular_maxdist<-function(GPS_edited=GPS_edited,
                           nest_loc=nest_loc){
  
  
  Viajes_df<-as.data.frame(GPS_edited)
  
  #separa los viajes
  Viajes_list<-split(Viajes_df,Viajes_df$trip_number)
  
  Nest_df<-nest_loc
  Nest_coords<- Nest_df[,c('Longitude','Latitude')]
  Nest_spatial <- sp::SpatialPointsDataFrame(coords = Nest_coords, data = Nest_df)
  sp::proj4string(Nest_spatial)= sp::CRS("+init=epsg:4326") 
  
  #calcula para cada elemento de la lista
  for( i in seq_along(Viajes_list)){
    
    Viaje_df<-Viajes_list[[i]]  
    Viaje_coords<- Viaje_df[,c('Longitude','Latitude')]
    Viaje_spatial <- sp::SpatialPointsDataFrame(coords = Viaje_coords, data = Viaje_df)
    sp::proj4string(Viaje_spatial)= sp::CRS("+init=epsg:4326") 
    
    
    maxdist_m<-(geosphere::distm(Viaje_spatial,Nest_spatial,fun = geosphere::distHaversine))
    meters_df<-cbind(Viaje_df,maxdist_m)
    meters_df$maxdist_km<-round(meters_df$maxdist_m/1000,digits=2)
    meters_df$maxdist_m<-NULL
    
    Viajes_list[[i]]<-meters_df
  }
  
  # crear lista vacia
  Maxdist_list<-list()
  
  # calcular para cada elemento de la lista
  for( i in seq_along(Viajes_list)){
    
    data<-Viajes_list[[i]]
    var1<-"maxdist_km"
    
    Maxdist_df <- data %>%
      dplyr::summarise(maxdist_km=max(data[[var1]],na.rm=TRUE))
    
    trip_id<-dplyr::first(data$trip_number)
    
    Maxdist_list[[i]]<- data.frame(trip_id = trip_id,
                                   maxdist_km = Maxdist_df)
    
  }
  
  Maxdist <- do.call("rbind",Maxdist_list)
  
  return(Maxdist)
}