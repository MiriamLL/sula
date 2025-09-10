#' Calcular la distancia maxima de la colonia por viaje
#'
#' @param GPS_data un data frame con las columnas 'Longitude' y 'Latitude'
#' @param nest_loc un data frame con las coordenadas de la colonia en 'Longitude','Latitude'
#' @param separador la columna a usar para separar los viajes, puede ser el numero del viaje o separar por individuos, por ejemplo 'trip_number'
#'
#' @return regresa un data frame con los maximos de la colonia por viaje
#' @export
#'
#' @examples nest_loc<-data.frame(Longitude = -109.4531, Latitude = -27.20097)
#' maxdist_km<-calcular_maxdist(GPS_data=GPS_edited, nest_loc=nest_loc,separador='trip_number')
calcular_maxdist<-function(GPS_data=GPS_data,
                           nest_loc=nest_loc,
                           separador=separador){
  
  
  if (!is.null(GPS_data[[separador]])) {
  } else {
    warning("Please check the name on the separador column")
  }
  
  if (nrow(GPS_data)!=0){
  } else {
    warning("Please check the name on the GPS_data data frame")
  }
  
  if (nrow(nest_loc)!=0){
  } else {
    warning("Please check the name on the nest_loc data frame")
  }
  
  
  Viajes_df<-as.data.frame(GPS_data)
  
  #separa los viajes
  Viajes_df$separador<-(Viajes_df[[separador]])
  
  Viajes_list<-split(Viajes_df,Viajes_df$separador)
  
  Nest_df<-nest_loc
  
  if ("Latitude" %in% colnames(nest_loc)){
  } else {
    warning("Please check that nest_loc has a column named Latitude, otherwise please rename the column as Latitude")
  }
  
  if ("Longitude" %in% colnames(nest_loc)){
  } else {
    warning("Please check that nest_loc has a column named Longitude, otherwise please rename the column as Longitude")
  }
  
  if ("Latitude" %in% colnames(GPS_data)){
  } else {
    warning("Please check that nest_loc has a column named Latitude, otherwise please rename the column as Latitude")
  }
  
  if ("Longitude" %in% colnames(GPS_data)){
  } else {
    warning("Please check that nest_loc has a column named Longitude, otherwise please rename the column as Longitude")
  }
  
  Nest_coords<- Nest_df[,c('Longitude','Latitude')]
  Nest_spatial <- sp::SpatialPointsDataFrame(coords = Nest_coords, data = Nest_df)
  sp::proj4string(Nest_spatial)= sp::CRS("+init=epsg:4326") 
  
  #calcula para cada elemento de la lista
  for( i in seq_along(Viajes_list)){
    
    Viaje_df<-Viajes_list[[i]]  
    Viaje_coords<- Viaje_df[,c('Longitude','Latitude')]
    Viaje_spatial <- sp::SpatialPointsDataFrame(coords = Viaje_coords, data = Viaje_df)
    sp::proj4string(Viaje_spatial)= sp::CRS("+init=epsg:4326") 
    
    
    Viaje_coords <- as.matrix(Viaje_df[, c('Longitude', 'Latitude')])
    Nest_coords <- as.matrix(Nest_df[, c('Longitude', 'Latitude')])
    
    maxdist_m <- geosphere::distm(Viaje_coords, Nest_coords, fun = geosphere::distHaversine)
    
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
    
    trip_id<-dplyr::first(data$separador)
    
    Maxdist_list[[i]]<- data.frame(trip_id = trip_id,
                                   maxdist_km = Maxdist_df)
    
  }
  
  Maxdist <- do.call("rbind",Maxdist_list)
  
  return(Maxdist)
}
