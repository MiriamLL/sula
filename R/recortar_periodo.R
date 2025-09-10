#' Recorta periodos dentro de los datos
#'
#' @param GPS_data data frame con columna hora y dia
#' @param dia_col nombre de la columna donde esta el dia
#' @param hora_col nombre de la columna donde esta la hora
#' @param formato formato de hora y dia
#' @param inicio inicio del periodo que se quiere recortar
#' @param final final del periodo que se quiere recortar
#'
#' @return el mismo data frame solo con el periodo que interesa
#' @export
#'
#' @examples GPS_recortado<-recortar_periodo(GPS_data=GPS_01,
#' inicio='02/11/2017 18:10:00',
#' final='05/11/2017 14:10:00',
#' dia_col='DateGMT',
#' hora_col='TimeGMT',
#' formato="%d/%m/%Y %H:%M:%S")
recortar_periodo<-function(GPS_data=GPS_data,
                           dia_col=dia_col,
                           hora_col=hora_col,
                           formato=formato,
                           inicio=inicio,
                           final=final){
  data<-GPS_data
  
  data$dia_hora<-paste(data[[dia_col]],data[[hora_col]])
  
  data$dia_hora<- as.POSIXct(strptime(as.character(data$dia_hora),formato), "GMT")
  
  inicio<-as.POSIXct(strptime(inicio, formato), "GMT") 
  final<- as.POSIXct(strptime(final, formato), "GMT")
  
  var1<-'dia_hora'
  
  condicion<-dplyr::case_when((data[[var1]] >= inicio & data[[var1]] <= final) ~ "Y",TRUE ~ "N")
  
  data$recorte<-condicion
  
  recortado<-subset(data,data$recorte=="Y")
  
  cat(paste0("\n ES: El track original contenia ", nrow(GPS_data),
             " filas y el track editado contiene ", nrow(recortado), 
             " filas \n EN: The original track had ",nrow(GPS_data),
             " rows, and the edited track has ",nrow(recortado)))
  
  return(recortado)
}
