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
  
  required_cols <- c("Longitude", "Latitude")
  
  for (df_name in c("GPS_data", "Nest_location")) {
    df <- get(df_name)
    missing_cols <- setdiff(required_cols, colnames(df))
    if (length(missing_cols) > 0) {
      stop(paste("Missing columns in", df_name, ":", paste(missing_cols, collapse = ", ")))
    }
  }
  
  # tracks
  track_df<-as.data.frame(GPS_data)
  track_spatial<-track_df
  track_spatial$lat<-track_spatial$Latitude
  track_spatial$lon<-track_spatial$Longitude
  sp::coordinates(track_spatial)<-~lon+lat
  sp::proj4string(track_spatial)= sp::CRS("+init=epsg:4326")
  track_spatial <- sp::spTransform(track_spatial, sp::CRS("+init=epsg:4326"))
  track_spatial<-sf::st_as_sf(track_spatial)
  
  # center buffer
  colonia<-Nest_location
  colonia_spatial<- sp::SpatialPoints(cbind(colonia$Longitude,colonia$Latitude)) 
  sp::proj4string(colonia_spatial)= sp::CRS("+init=epsg:4326") 
  colonia_spatial <- sp::spTransform(colonia_spatial, sp::CRS("+init=epsg:4326"))
  colonia_spatial<-sf::st_as_sf(colonia_spatial)
  
  # distance
  Distance_km<-Distance_km*1000
  distancia_buffer<-sf::st_buffer(colonia_spatial, Distance_km)
  
  # over
  track_buffer<-sapply(sf::st_intersects(track_spatial,distancia_buffer),
                        function(z) if (length(z)==0) NA_integer_ else z[1])
  
  #todo lo que esta dentro del buffer es 1 y fuera es 0
  track_df$trip<-as.numeric(track_buffer)
  
  #sustituye nas por ceros
  track_df$trip[is.na(track_df$trip)] <- 0
  
  track_df$trip<-gsub("1", "N", track_df$trip)
  track_df$trip<-gsub("0", "Y", track_df$trip)
  
  return(track_df)
}
