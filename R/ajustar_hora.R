#' Corrige el tiempo de acuerdo a la zona horaria.
#'
#' @param GPS_data tu data frame con columna de hora y tiempo
#' @param dif_hor un numero correspondiente a la diferencia horaria
#' @param dia_col el nombre de la columna donde tienes la fecha
#' @param hora_col el nombre de la columna donde tienes el tiempo
#' @param formato el formato en el que esta tu fecha y hora
#'
#' @return un data frame con dos columnas adicionales dia_hora y hora_corregida
#' @export
#'
#' @examples 
#' t_formato="%d/%m/%Y %H:%M:%S"
#' GPS_gmt<-ajustar_hora(GPS_data = GPS_raw, dif_hor = 5,
#' dia_col = 'DateGMT', hora_col = 'TimeGMT',formato=t_formato)
ajustar_hora <- function(GPS_data=GPS_data, 
                         dif_hor=dif_hor,
                         dia_col=dia_col,
                         hora_col=hora_col,
                         formato=formato){
  
  data<-GPS_data
  
  data$dia_hora<-paste(data[[dia_col]],data[[hora_col]])
  
  data$dia_hora<- as.POSIXct(strptime(as.character(data$dia_hora),
                                      formato), "GMT")
  var1<-"dia_hora"
  var2<-dif_hor
  
  data<-data %>%
    dplyr::mutate(hora_corregida = (data[[var1]]) - as.numeric(var2)*60*60)
  
  return(data)
}
