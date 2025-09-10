#' Agrega columna identificando viajes
#'
#' @param GPS_data es el data frame con datos de GPS con las columnas Latitude y Longitude
#' @param nest_loc es un data frame con las columnas Latitude y Longitude
#' @param distancia_km un numero de acuerdo al buffer de interes
#'
#' @return el data frame con una columna adicional
#' @export
#' 
#' @examples nest_loc<-data.frame(Longitude=-109.4531, Latitude=-27.20097)
#' GPS_01_trips<-identificar_viajes(GPS_data=GPS01,nest_loc=nest_loc,distancia_km=0.01)
identificar_viajes<-function(GPS_data=GPS_data,
                             nest_loc=nest_loc,
                             distancia_km=distancia_km){
  
  required_cols <- c("Longitude", "Latitude")
  
  for (df_name in c("GPS_data", "nest_loc")) {
    df <- get(df_name)
    missing_cols <- setdiff(required_cols, colnames(df))
    if (length(missing_cols) > 0) {
      stop(paste("Missing columns in", df_name, ":", paste(missing_cols, collapse = ", ")))
    }
  }
  
  # tracks
  track_df <- as.data.frame(GPS_data)
  track_spatial <- track_df
  track_spatial$lat <- track_spatial$Latitude
  track_spatial$lon <- track_spatial$Longitude
  sp::coordinates(track_spatial) <- ~lon + lat
  sp::proj4string(track_spatial) <- sp::CRS("+init=epsg:4326")  # This is enough
  # sp::spTransform not needed here since it's already in EPSG:4326
  track_spatial <- sf::st_as_sf(track_spatial)
  
  # center buffer
  colonia<-nest_loc
  colonia_spatial<- sp::SpatialPoints(cbind(colonia$Longitude,colonia$Latitude)) 
  sp::proj4string(colonia_spatial)= sp::CRS("+init=epsg:4326") 
  colonia_spatial <- sp::spTransform(colonia_spatial, sp::CRS("+init=epsg:4326"))
  colonia_spatial<-sf::st_as_sf(colonia_spatial)
  
  # distance
  Distance_km<-distancia_km*1000
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
  
  cat("\n SP: Una columna llamada trip fue agregada. \n Y corresponde a registros dentro del rango y N a registros fuera del rango 
      \n EN: A column named trip was added to the data frame. \n Y corresponds locations outside the range, and N to locations inside the range")
  return(track_df)
}
