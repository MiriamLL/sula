#' Recorta periodos usando informacion de IDs
#'
#' @param GPS_data un data frame con las columnas 'IDs','DateGMT' y 'TimeGMT' con estos nombres
#' @param Notas un data frame con las columnas 'Hora_inicio' y 'Hora_final' con estos nombres
#' @param formato el formato en el que estan escritas las fechas, debe ser el mismo para ambos data frames
#'
#' @return el data frame GPS_data pero recortado, es decir con menos observaciones
#' @export
#'
#' @examples GPS_recortados<-recortar_por_ID(GPS_data=GPS_raw,Notas=Notas,formato="%d/%m/%Y %H:%M:%S")
recortar_por_ID<-function(GPS_data=GPS_data,
                          Notas=Notas,
                          formato= formato){
  #nombres de las columnas
  ID_col='IDs'
  
  dia_col='DateGMT'
  hora_col="TimeGMT"
  
  inicio_col='Hora_inicio'
  final_col='Hora_final'
  
  
  # crear lista
  GPS_list<-split(GPS_data,GPS_data[c(ID_col)])
  
  GPS_recortados_list<-list()
  
  for( i in seq_along(GPS_list)){
    GPS_df<-GPS_list[[i]]
    
    #extract ID name
    Individuo<-dplyr::first(GPS_df[[ID_col]])
    
    # extract time
    Notas_ID<-subset(Notas,Notas[c(ID_col)]==Individuo)
    
    Inicio<-dplyr::first(Notas_ID[[inicio_col]])
    Final<-dplyr::first(Notas_ID[[final_col]])
    
    Hora_inicio<- as.POSIXct(strptime(Inicio, formato), tz='GMT') 
    Hora_final<- as.POSIXct(strptime(Final, formato), tz='GMT') 
    
    # recortar
    GPS_df$dia_hora<-paste(GPS_df[[dia_col]],GPS_df[[hora_col]])
    GPS_df$dia_hora<- as.POSIXct(strptime(as.character(GPS_df$dia_hora),formato), "GMT")
    
    GPS_condicion<-dplyr::case_when((GPS_df[['dia_hora']] >= Hora_inicio & 
                                       GPS_df[['dia_hora']] <= Hora_final) ~ "Y",TRUE ~ "N")
    
    GPS_df$recorte<-GPS_condicion
    GPS_recortado<-subset(GPS_df,GPS_df$recorte=="Y")
    
    GPS_recortado$recorte<-NULL
    
    GPS_recortados_list[[i]]<-GPS_recortado
  }
  
  GPS_recortados_df <- do.call("rbind",GPS_recortados_list)
  return(GPS_recortados_df)
  
}