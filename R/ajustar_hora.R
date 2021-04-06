#' Corrige la hora en tu base de datos
#'
#' @param datos Un data frame que contenga una columna que tenga datos en POSIXct
#' @param columna Columna con fecha y hora, para convertir hay que pegar la columa dia y hora y usar la funcion as.POSIXct
#' @param diferencia_horaria El numero de horas de diferencia
#'
#' @return Regresa un nuevo data frame con el nombre 'horas_corregidas'
#' @export
#'
#' @examples ajustar_hora(datos=GPSdata2, columna=diahora,diferencia_horaria=5)

ajustar_hora <- function(datos, columna, diferencia_horaria){
  
  diferencia_horaria<-as.numeric(diferencia_horaria)
  
  hora_transformada = datos %>% dplyr::pull({{columna}})
  
  datos<-datos %>%
   dplyr::mutate(hora_transformada = hora_transformada - diferencia_horaria*60*60)
  
 assign("horas_corregidas",datos,envir = .GlobalEnv)
}

