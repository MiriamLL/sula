#' Agrega columna identificando viajes
#'
#' @param GPS_track es el data frame con datos de GPS con las columnas Latitude y Longitude
#' @param nest_loc es un data frame con las columnas Latitude y Longitude
#' @param distance_km un numero de acuerdo al buffer de interes
#'
#' @return el data frame con una columna adicional
#' @export
#' 
#' @examples nest_loc<-data.frame(Longitude   = -109.4531, Latitude   = -27.20097)
#' GPS_01_trips<-identificar_viajes(GPS_track=GPS_01,nest_loc=nest_loc,distance_km=0.01)
identificar_viajes<-function(GPS_track=GPS_track,
                             nest_loc=nest_loc,
                             distance_km=0.01){
  
  track<-GPS_track
  colonia<-nest_loc
  distancia_km<-distance_km
  
  # tracks
  track_df<-as.data.frame(track)
  track_spatial<-track_df
  track_spatial$lat<-track_spatial$Latitude
  track_spatial$lon<-track_spatial$Longitude
  sp::coordinates(track_spatial)<-~lon+lat
  sp::proj4string(track_spatial)= sp::CRS("+init=epsg:4326")
  
  #colonia
  colonia<-nest_loc
  colonia_spatial<- sp::SpatialPoints(cbind(colonia$Longitude,colonia$Latitude)) 
  
  # distancia_km
  distancia_buf<-rgeos::gBuffer(colonia_spatial, width=1*distance_km) 
  
  # distancia_buffer
  distancia_buffer<-distancia_buf
  distancia_buffer_df<-data.frame(ID=1:length(distancia_buffer)) 
  #rownames(distancia_buffer_df)
  distancia_buffer_id <- sapply(slot(distancia_buffer, "polygons"), function(x) slot(x, "ID"))
  distancia_buffer_df <- data.frame( ID=1:length(distancia_buffer), row.names = distancia_buffer_id)
  distancia_buffer<- sp::SpatialPolygonsDataFrame(distancia_buffer, distancia_buffer_df)
  #class(distancia_buffer) 
  
  #plot(tracks_spatial)
  #plot(distancia_buffer,col='red',add=TRUE)
  
  sp::proj4string(distancia_buffer) <- sp::proj4string(track_spatial)
  track_buffer<-sp::over(track_spatial, distancia_buffer) 
  
  #todo lo que esta dentro del buffer es 1 y fuera es 0
  track_buffer_df<-as.data.frame(track_buffer)
  track_df$trip<-as.numeric(track_buffer_df$ID)
  
  #sustituye nas por ceros
  track_df$trip[is.na(track_df$trip)] <- 0
  
  track_df$trip<-gsub("1", "N", track_df$trip)
  track_df$trip<-gsub("0", "Y", track_df$trip)
  
  cat("A column named trip was added to the data frame,Y corresponds locations outside the range, and N to locations inside the range")
  return(track_df)
}