#' Adds a column with information when the animal was close to the central location or outside the central location
#'
#' @param GPS_data is the data frame with the tracking data, must have columns named 'Longitude' and 'Latitude' if not provided please rename those columns
#' @param Nest_location is the data frame with the nest location, must have columns named 'Longitude' and 'Latitude' if not provided please rename those columns
#' @param Distance_km is the distance that would be considered inside the central location or outside the central location
#'
#' @return returns the same data frame with an additional column, Y for outside the central location, N for inside the central location
#' @export
#' 
#' @examples GPS_01_nest<-data.frame(Longitude=-109.4531, Latitude=-27.20097)
#' GPS01_trips<-identify_trips(GPS_data=GPS01,Nest_location=GPS_01_nest,Distance_km=1)
identify_trips<-function(GPS_data=GPS_data,
                             Nest_location=Nest_location,
                             Distance_km=Distance_km){
  
  if ("Latitude" %in% colnames(GPS_data)){
  } else {
    warning("Please check that GPS_data has a column named Latitude, otherwise please rename the column as Latitude")
  }
  
  if ("Longitude" %in% colnames(GPS_data)){
  } else {
    warning("Please check that GPS_data has a column named Longitude, otherwise please rename the column as Longitude")
  }
  
  if ("Latitude" %in% colnames(Nest_location)){
  } else {
    warning("Please check that Nest_location has a column named Latitude, otherwise please rename the column as Latitude")
  }
  
  if ("Longitude" %in% colnames(Nest_location)){
  } else {
    warning("Please check that Nest_location has a column named Longitude, otherwise please rename the column as Longitude")
  }
  
  # tracks
  track_df<-as.data.frame(GPS_data)
  track_spatial<-track_df
  track_spatial$lat<-track_spatial$Latitude
  track_spatial$lon<-track_spatial$Longitude
  sp::coordinates(track_spatial)<-~lon+lat
  sp::proj4string(track_spatial)= sp::CRS("+init=epsg:4326")
  track_spatial <- sp::spTransform(track_spatial, sp::CRS("+init=epsg:4326"))
  
  #colonia
  colonia<-Nest_location
  colonia_spatial<- sp::SpatialPoints(cbind(colonia$Longitude,colonia$Latitude)) 
  sp::proj4string(colonia_spatial)= sp::CRS("+init=epsg:4326") 
  colonia_spatial <- sp::spTransform(colonia_spatial, sp::CRS("+init=epsg:4326"))
  
  # distancia_km
  Distance_km<-Distance_km/100
  distancia_buf<-rgeos::gBuffer(colonia_spatial, width=1*Distance_km) 
  
  # distancia_buffer
  distancia_buffer<-distancia_buf
  # tiene que ser convertido a data frame para que aparezca la coluna
  distancia_buffer_df<-data.frame(ID=1:length(distancia_buffer)) 
  
  #problema nota con slot, agregar importFrom("methods", "slot") en NAMESPACE (manualmente)
  distancia_buffer_id <- sapply(methods::slot(distancia_buffer, "polygons"), function(x) methods::slot(x, "ID"))
  
  distancia_buffer_df <- data.frame(ID=1:length(distancia_buffer), row.names = distancia_buffer_id)
  distancia_buffer<- sp::SpatialPolygonsDataFrame(distancia_buffer, distancia_buffer_df)
  sp::proj4string(distancia_buffer) <- sp::proj4string(track_spatial)
  track_buffer<-sp::over(track_spatial, distancia_buffer) 
  
  #todo lo que esta dentro del buffer es 1 y fuera es 0
  track_buffer_df<-as.data.frame(track_buffer)
  track_df$trip<-as.numeric(track_buffer_df$ID)
  
  #sustituye nas por ceros
  track_df$trip[is.na(track_df$trip)] <- 0
  
  track_df$trip<-gsub("1", "N", track_df$trip)
  track_df$trip<-gsub("0", "Y", track_df$trip)
  
  return(track_df)
}
