#' Corrige el tiempo de acuerdo a la zona horaria.
#'
#' @param GPS_raw tu data frame con columna de hora y tiempo
#' @param dif_hor un numero correspondiente a la diferencia horaria
#' @param col_dia el nombre de la columna donde tienes la fecha
#' @param col_hora el nombre de la columna donde tienes el tiempo
#' @param formato el formato en el que esta tu fecha y hora
#'
#' @return un data frame con dos columnas adicionales dia_hora y hora_corregida
#' @export
#'
#' @examples 
#' t_formato="%d/%m/%Y %H:%M:%S"
#' GPS_gmt<-ajustar_hora(GPS_raw = GPS_raw, 
#' dif_hor = 5,
#' col_dia = 'DateGMT',
#' col_hora = 'TimeGMT',
#' formato=t_formato)
ajustar_hora <- function(GPS_raw=GPS_raw, 
                         dif_hor=dif_hor,
                         col_dia=col_dia,
                         col_hora=col_hora,
                         formato=formato){
  
  data<-GPS_raw
  
  data$dia_hora<-paste(data[[col_dia]],data[[col_hora]])
  
  data$dia_hora<- as.POSIXct(strptime(as.character(data$dia_hora),
                                      formato), "GMT")
  var1<-"dia_hora"
  var2<-dif_hor
  
  data<-data %>%
    dplyr::mutate(hora_corregida = (data[[var1]]) - as.numeric(var2)*60*60)
  
  return(data)
}