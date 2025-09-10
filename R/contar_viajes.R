#' Cuenta viajes y elimina periodos que no sean viajes de alimentacion
#'
#' @param GPS_data un data frame con una columna llamada trip que incluya Y o N
#'
#' @return un data frame con una columna con trip_number, num_seq y solo las locaciones fuera de la colonia
#' @export
#'
#' @examples GPS_viaje<-contar_viajes(GPS_data=GPS_trip)
contar_viajes<-function(GPS_data=GPS_data){
  
  trip_data<-GPS_data
  
  num_seq<-nrow(trip_data)
  num_seq<-as.numeric(num_seq)
  trip_data$num_seq<-paste(seq(1:num_seq))
  
  #subset only trips
  only_trips<-subset(trip_data,trip_data$trip == "Y")
  only_trips$num_seq<-as.integer(only_trips$num_seq)
  
  #subset only trips
  only_trips$trip_number<-(cumsum(c(1L, diff(only_trips$num_seq)) != 1L))
  only_trips$trip_number<-only_trips$trip_number+1
  only_trips$trip_number<-stringr::str_pad(only_trips$trip_number, 3, pad = "0")
  only_trips$trip_number<-paste0("trip_",only_trips$trip_number)
  
  #before
  #num_seq<-nrow(trip_data)
  #num_seq<-as.numeric(num_seq)
  #trip_data$num_seq<-paste(seq(1:num_seq))
  #only_trips<-subset(trip_data,trip_data$trip == "Y")
  #only_trips$num_seq<-as.integer(only_trips$num_seq)
  #only_trips$trip_number<-(cumsum(c(1L, diff(only_trips$num_seq)) != 1L))
  #only_trips$trip_number<-paste0("trip_",only_trips$trip_number+1)
  
  #cat(paste0("Original track contained ", nrow(trip_data),
  #           " rows and the edited track contains ", nrow(only_trips), " rows"))
  cat(paste0("\n ES: El track original contenia ", nrow(trip_data),
             " filas y ", nrow(only_trips), 
             " filas son registros cuando estaba fuera de la colonia",
             "\n EN: The original track had ", nrow(trip_data),
             " rows, and ", nrow(only_trips), 
             " are locations outside the colony"))
  
  return(only_trips)
}
