#' Calcula la duración de los viajes de alimentación
#'
#' @param GPS_data un data frame con una columna que incluya día y hora, y otra columna que incluya el numero del viaje
#' @param col_diahora la columna en formato POSTIXct con información del día y hora
#' @param formato el formato en el que esta la hora y día en la columna POSTIXct con información del día y hora
#' @param unidades elegir "hours", "minutes", "seconds".
#' @param separador la columna a usar para separar los viajes, puede ser el numero del viaje o separar por individuos, por ejemplo 'trip_number'
#'
#' @return regresa un nuevo data frame con la información del viaje, cuando inicio, cuando termino y la duración
#' @export
#'
#' @examples formato<-"%Y-%m-%d %H:%M:%S"
#' duracion<-calcular_duracion(GPS_data=GPS_edited,col_diahora="tStamp",
#' formato=formato,unidades="hours",separador='trip_number')
calcular_duracion<-function(GPS_data = GPS_data,
                            col_diahora=col_diahora,
                            formato=formato,
                            unidades=unidades,
                            separador=separador){

  if (!is.null(GPS_data[[separador]])) {
  } else {
    warning("Please check the name on the separador column")
  }
  if (!is.null(GPS_data[[col_diahora]])) {
  } else {
    warning("Please check the name in col_diahora")
  }
  
  GPS_data$separador<-(GPS_data[[separador]])
  
  Viajes_list<-split(GPS_data,GPS_data$separador)
  
  Horas_list<-list()
  
  #obtiene para cada elemento de la lista
  for( i in seq_along(Viajes_list)){
    
    Viaje_df<-Viajes_list[[i]]
    
    trip_start<-dplyr::first(Viaje_df[[col_diahora]])
    trip_end<-dplyr::last(Viaje_df[[col_diahora]])
    trip_id<-dplyr::first(Viaje_df[[separador]])
    
    
    Horas_list[[i]]<-nest_loc<-data.frame(trip_id = trip_id,
                                          trip_start = trip_start, 
                                          trip_end   = trip_end)
    
  }
  
  Horas_lista<- do.call("rbind",Horas_list)
  
  Horas_lista$trip_start<-as.POSIXct(strptime(Horas_lista$trip_start,formato),"GMT")
  Horas_lista$trip_end<-as.POSIXct(strptime(Horas_lista$trip_end,formato),"GMT")  
  Horas_lista$duration<-as.numeric(difftime(Horas_lista$trip_end,Horas_lista$trip_start, units=unidades))
  
  return(Horas_lista)
}
