#' Calcula parametros de viajes de varios individuos
#'
#' @param GPS_data un data frame con columnas que incluyan identificador por individuo, identificador por viaje, y una columna en dia y hora.
#' @param col_ID el nombre de la columna del data frame que incluye el identificador del individuo
#' @param col_tripnum el nombre de la columna del data frame que incluye el identificador del viaje
#' @param col_diahora el nombre de la columna del data frame que incluye el dia y hora en formato POSTIXct
#' @param separador El nombre de la columna a usar para separar los viajes, puede ser el numero del viaje o separar por individuos. Escribir entre  comillas.
#'
#' @return un data frame con parametros de los viajes
#' @export
#'
#' @examples trip_params<-tripparams_varios(GPS_data=GPS_preparado,
#' col_ID = "IDs",
#' col_tripnum="trip_number",
#' col_diahora="hora_corregida",
#' separador='trip_number')
tripparams_varios<-function(GPS_data = GPS_data,
                            col_ID = col_ID,
                            col_tripnum=col_tripnum,
                            col_diahora=col_diahora,
                            separador=separador){
  
  if (!is.null(GPS_data[[separador]])) {
  } else {
    warning("Please check the name on the separador column")
  }
  
  if (nrow(GPS_data)!=0){
  } else {
    warning("Please check the name on the GPS_data data frame")
  }
  
  GPS_data$trip_ID<-paste0(GPS_data[[col_ID]],"_",GPS_data[[col_tripnum]])
  
  GPS_data$separador<-(GPS_data[[separador]])
  Viajes_ls<-split(GPS_data,GPS_data$separador)
  
  #############
  ### HORAS ###
  #############
  Horas_ls<-list()
  
  #obtiene para cada elemento de la lista
  for( a in seq_along(Viajes_ls)){
    
    Viaje_df<-Viajes_ls[[a]]
    
    trip_start<-dplyr::first(Viaje_df[[col_diahora]])
    trip_end<-dplyr::last(Viaje_df[[col_diahora]])
    trip_id<-dplyr::first(Viaje_df[[separador]])
    
    Individuo<-dplyr::first(Viaje_df[[col_ID]])
    
    Horas_ls[[a]]<-data.frame(ID=Individuo,
                              trip_id = trip_id,
                              trip_start = trip_start, 
                              trip_end   = trip_end)
    
  }
  
  Horas_df<- do.call("rbind",Horas_ls)
  
  Horas_df$duration_num<-as.numeric(difftime(Horas_df$trip_end,Horas_df$trip_start, units="hours"))
  Horas_df$duration_num<-round(Horas_df$duration_num,2)
  
  #############
  ##TOTAL
  #############
  
  # crear lista vacia
  Totaldist_list<-list()
  
  # calcular para cada elemento de la lista
  for( b in seq_along(Viajes_ls)){
    
    data<-Viajes_ls[[b]]
    var1<-"pointsdist_km"
    
    Totaldist_df <- data %>%
      dplyr::summarise(totaldist_km=sum(data[[var1]],na.rm=TRUE))
    
    trip_id<-dplyr::first(data[[separador]])
    Individuo<-dplyr::first(data[[col_ID]])
    
    Totaldist_list[[b]]<- data.frame(ID=Individuo,
                                     trip_id = trip_id,
                                     totaldist_km = Totaldist_df)
    
    
    
  }
  
  Totaldist_df <- do.call("rbind",Totaldist_list)
  
  Maxdist_list<-list()
  
  # calcular para cada elemento de la lista
  for( c in seq_along(Viajes_ls)){
    
    data<-Viajes_ls[[c]]
    var1<-"maxdist_km"
    
    Maxdist_df <- data %>%
      dplyr::summarise(maxdist_km=max(data[[var1]],na.rm=TRUE))
    
    trip_id<-dplyr::first(data[[separador]])
    
    Individuo<-dplyr::first(data[[col_ID]])
    
    Maxdist_list[[c]]<- data.frame(ID=Individuo,
                                   trip_id = trip_id,
                                   maxdist_km = Maxdist_df)
    
  }
  
  Maxdist_df <- do.call("rbind",Maxdist_list)
  
  Parametros_df<-cbind(Maxdist_df,Totaldist_df,Horas_df)
  
  Parametros_df<-Parametros_df[,c("ID","trip_id",
                                  "maxdist_km","totaldist_km","duration_num",
                                  "trip_start","trip_end")]
  
  Parametros_varios<-Parametros_df
  return(Parametros_varios)
}