#' Distancia del nido por cada punto
#'
#' @param GPS_edited es el data frame con una columna llamada "Latitude" y otra llamada "Longitude"
#' @param nest_loc es un data frame con una columna llamada "Latitude" y otra llamada "Longitude"
#'
#' @return regresa el data frame con una nueva columna llamada "max_dist_km"
#' @export
#'
#' @examples nest_loc<-data.frame(Longitude = -109.4531, Latitude = -27.20097)
#' GPS_dist<-dist_colonia(GPS_edited = GPS_edited, nest_loc=nest_loc)
dist_colonia<-function(GPS_edited=GPS_edited,
                       nest_loc=nest_loc){
  
  if ("Latitude" %in% colnames(GPS_edited)){
  } else {
    warning("Please check that nest_loc has a column named Latitude, otherwise please rename the column as Latitude")
  }
  
  if ("Longitude" %in% colnames(GPS_edited)){
  } else {
    warning("Please check that nest_loc has a column named Longitude, otherwise please rename the column as Longitude")
  }
  
  if ("Latitude" %in% colnames(nest_loc)){
  } else {
    warning("Please check that nest_loc has a column named Latitude, otherwise please rename the column as Latitude")
  }
  
  if ("Longitude" %in% colnames(nest_loc)){
  } else {
    warning("Please check that nest_loc has a column named Longitude, otherwise please rename the column as Longitude")
  }
  # tracks
  track_df<-as.data.frame(GPS_edited)
  track_spatial<-track_df
  track_spatial$lat<-track_spatial$Latitude
  track_spatial$lon<-track_spatial$Longitude
  sp::coordinates(track_spatial)<-~lon+lat
  
  # colonia
  colonia<-nest_loc
  colonia_spatial<- sp::SpatialPoints(cbind(colonia$Longitude,colonia$Latitude)) 
  
  #crs
  sp::proj4string(track_spatial)= sp::CRS("+init=epsg:4326")
  sp::proj4string(colonia_spatial)= sp::CRS("+init=epsg:4326")
  
  #error: Points are projected. They should be in degrees (longitude/latitude)
  track_spatial <- sp::spTransform(track_spatial, sp::CRS("+init=epsg:4326"))
  colonia_spatial <- sp::spTransform(colonia_spatial, sp::CRS("+init=epsg:4326"))
  
  # distancia_km
  maxdist_m<-(geosphere::distm(track_spatial,colonia_spatial,fun = geosphere::distHaversine))
  meters_df<-cbind(track_df,maxdist_m)
  meters_df$maxdist_km<-round(meters_df$maxdist_m/1000,digits=2)
  meters_df$maxdist_m<-NULL
  
  return(meters_df)
  #cat("A column named maxdist_km was added to the data frame, 
  #           the values correspond to distance of each point from the colony")
  cat("\n SP: Una columna llamada maxdist_km fue agregada al data frame, los valores corresponden a la distancia de cada punto del nido \n 
      EN: A new column named maxdist_km was added to the data frame, the values are the distance of each location to the colony")
}