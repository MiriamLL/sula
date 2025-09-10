#' Agrega una columna con la distancia entre cada punto. 
#'
#' @param GPS_data es un data frame con datos de Longitude y Latitude.
#' @param separador El nombre de la columna a usar para separar los viajes, puede ser el numero del viaje o separar por individuos. . El nombre de la columna debe ir entre comillas.

#'
#' @return el mismo data frame con una columna llamada pointsdist_km
#' @export
#'
#' @examples GPS_dist<-dist_puntos(GPS_data = GPS_edited,separador='trip_number')
dist_puntos<-function(GPS_data = GPS_data,separador=separador){
  
  if (nrow(GPS_data)!=0){
  } else {
    warning("Please check the name on the GPS_data data frame")
  }
  
  if (!is.null(GPS_data[[separador]])) {
  } else {
    warning("Please check the name on the separador column")
  }
  
  if ("Latitude" %in% colnames(GPS_data)){
  } else {
    warning("Please check that nest_loc has a column named Latitude, otherwise please rename the column as Latitude")
  }
  
  if ("Longitude" %in% colnames(GPS_data)){
  } else {
    warning("Please check that nest_loc has a column named Longitude, otherwise please rename the column as Longitude")
  }
  
  GPS_data$separador<-(GPS_data[[separador]])
  
  Viajes_df<-as.data.frame(GPS_data)
  
  #separa los viajes
  Viajes_list<-split(Viajes_df,Viajes_df$separador)
  
  #calcula para cada elemento de la lista
  for( i in seq_along(Viajes_list)){
    Viaje_df<-Viajes_list[[i]]  
    Viaje_coords <- as.matrix(Viaje_df[, c('Longitude', 'Latitude')])
    
    #calcula la distancia para cada punto  
    Viaje_distancias <- sapply(2:nrow(Viaje_coords),
                               function(i) {
                                 geosphere::distm(Viaje_coords[i - 1, ], Viaje_coords[i, ])
                               })
    
    #c(sf::st_distance(my_df[-1,],my_df[-nrow(my_df),],by_element=TRUE),NA)
    
    Viaje_distancias<-c(NA,Viaje_distancias)
    Viaje_df$pointsdist_km<-round(Viaje_distancias/1000,2)
    
    Viajes_list[[i]]<-Viaje_df
  }
  
  
  Viajes_df<- do.call("rbind",Viajes_list)
  
  cat("\n ES: Una columna llamada pointsdist_km fue agregada. \n Los valores corresponden a la distancia entre cada punto GPS.
      \n EN: A new column named pointsdist_km was added to the data frame. \n The values are the distance between locations.")
  
  return(Viajes_df)
}
