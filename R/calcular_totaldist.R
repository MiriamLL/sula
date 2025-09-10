#' Calcula distancia recorrida de la colonia por viaje
#'
#' @param GPS_data un data frame con datos de Longitude y Latitude
#' @param separador El nombre de la columna a usar para separar los viajes, puede ser el numero del viaje o separar por individuos. Escribir entre  comillas.
#'
#' @return regresa un nuevo data frame con la distancia total recorrida por viaje.
#' @export
#'
#' @examples totaldist_km<-calcular_totaldist(GPS_data = GPS_edited, separador='trip_number')
calcular_totaldist<-function(GPS_data = GPS_data, separador=separador){
  
  if (!is.null(GPS_data[[separador]])) {
  } else {
    warning("Please check the name on the separador column")
  }
  
  if (nrow(GPS_data)!=0){
  } else {
    warning("Please check the name on the GPS_data data frame")
  }
  
  
  Viajes_df<-as.data.frame(GPS_data)
  
  #separa los viajes
  Viajes_df$separador<-(Viajes_df[[separador]])
  Viajes_list<-split(Viajes_df,Viajes_df$separador)
  
  if ("Latitude" %in% colnames(GPS_data)){
  } else {
    warning("Please check that nest_loc has a column named Latitude, otherwise please rename the column as Latitude")
  }
  
  if ("Longitude" %in% colnames(GPS_data)){
  } else {
    warning("Please check that nest_loc has a column named Longitude, otherwise please rename the column as Longitude")
  }
  
  #calcula para cada elemento de la lista
  for( i in seq_along(Viajes_list)){
  
    Viaje_df<-Viajes_list[[i]]  
    
    coords <- as.matrix(Viaje_df[, c("Longitude", "Latitude")])
    
    # Compute distances between consecutive points
    if (nrow(coords) >= 2) {
      dist_vector <- geosphere::distHaversine(coords[-nrow(coords), ], coords[-1, ])
      dist_vector <- c(NA, dist_vector)  # Align with rows
    } else {
      dist_vector <- rep(NA, nrow(coords))
    }
    
    Viaje_df$pointsdist_km<-round(dist_vector/1000,2)
    
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
    
    trip_id<-dplyr::first(data$separador)
    
    Totaldist_list[[i]]<- data.frame(trip_id = trip_id,
                                     totaldist_km = Totaldist_df)
    
}
  
  Totaldist <- do.call("rbind",Totaldist_list)
  
  return(Totaldist)
}
