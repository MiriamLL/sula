#' Calcula los parametros del viaje de alimentacion
#'
#' @param GPS_data es un data frame con tus datos, debe contener columnas 'Longitude','Latitude', trip_number y dia_horacol que es una columna en formato POSTIXct 
#' @param diahora_col una columna en formato POSTIXct
#' @param formato el formato en el que esta la diahora_col
#' @param nest_loc un data frame con las coordenadas del nido 'Longitude','Latitude'
#'
#' @return una tabla con los parametros del viaje
#' @export
#'
#' @examples nest_loc=data.frame(Longitude = -109.4531,Latitude = -27.20097)
#' trip_params<-calcular_tripparams(GPS_data = GPS_edited,
#' diahora_col = "tStamp",
#' formato = "%Y-%m-%d %H:%M:%S",
#' nest_loc=nest_loc)
calcular_tripparams<-function(GPS_data = GPS_data,
                              diahora_col=diahora_col,
                              formato=formato,
                              nest_loc=nest_loc){
  
  Viajes_list<-split(GPS_data,GPS_data$trip_number)
  
  #############
  ### HORAS ###
  #############
  Horas_list<-list()
  
  #obtiene para cada elemento de la lista
  for( i in seq_along(Viajes_list)){
    
    Viaje_df<-Viajes_list[[i]]
    
    trip_start<-dplyr::first(Viaje_df[[diahora_col]])
    trip_end<-dplyr::last(Viaje_df[[diahora_col]])
    trip_id<-dplyr::first(Viaje_df$trip_number)
    
    
    Horas_list[[i]]<-data.frame(trip_id = trip_id,
                                trip_start = trip_start, 
                                trip_end   = trip_end)
    
  }
  
  Horas_df<- do.call("rbind",Horas_list)
  
  Horas_df$trip_start<-as.POSIXct(strptime(Horas_df$trip_start,formato),"GMT")
  Horas_df$trip_end<-as.POSIXct(strptime(Horas_df$trip_end,formato),"GMT")  
  Horas_df$duration_h<-as.numeric(difftime(Horas_df$trip_end,Horas_df$trip_start, units="hours"))
  Horas_df$duration_h<-round(Horas_df$duration_h,2)
  
  #############
  ##TOTAL
  #############
  
  for( i in seq_along(Viajes_list)){
    
    Viaje_df<-Viajes_list[[i]]  
    Viaje_coords<- Viaje_df[,c('Longitude','Latitude')]
    Viaje_spatial <- sp::SpatialPointsDataFrame(coords = Viaje_coords, data = Viaje_df)
    sp::proj4string(Viaje_spatial)= sp::CRS("+init=epsg:4326")  
    
    #calcula la distancia para cada punto  
    Viaje_distancias<-sapply(2:nrow(Viaje_spatial),
                             function(i){geosphere::distm( Viaje_spatial[i-1,],
                                                           Viaje_spatial[i,])})
    
    #c(sf::st_distance(my_df[-1,],my_df[-nrow(my_df),],by_element=TRUE),NA)
    
    Viaje_distancias<-c(NA,Viaje_distancias)
    Viaje_df$pointsdist_km<-round(Viaje_distancias/1000,2)
    
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
    
    trip_id<-dplyr::first(data$trip_number)
    
    Totaldist_list[[i]]<- data.frame(trip_id = trip_id,
                                     totaldist_km = Totaldist_df)
    
  }
  
  Totaldist_df <- do.call("rbind",Totaldist_list)
  
  
  #################
  ####MAX##########
  #################
  
  Nest_df<-nest_loc
  Nest_coords<- Nest_df[,c('Longitude','Latitude')]
  Nest_spatial <- sp::SpatialPointsDataFrame(coords = Nest_coords, data = Nest_df)
  sp::proj4string(Nest_spatial)= sp::CRS("+init=epsg:4326") 
  
  #calcula para cada elemento de la lista
  for( i in seq_along(Viajes_list)){
    
    Viaje_df<-Viajes_list[[i]]  
    Viaje_coords<- Viaje_df[,c('Longitude','Latitude')]
    Viaje_spatial <- sp::SpatialPointsDataFrame(coords = Viaje_coords, data = Viaje_df)
    sp::proj4string(Viaje_spatial)= sp::CRS("+init=epsg:4326") 
    
    
    maxdist_m<-(geosphere::distm(Viaje_spatial,Nest_spatial,fun = geosphere::distHaversine))
    meters_df<-cbind(Viaje_df,maxdist_m)
    meters_df$maxdist_km<-round(meters_df$maxdist_m/1000,digits=2)
    meters_df$maxdist_m<-NULL
    
    Viajes_list[[i]]<-meters_df
  }
  
  # crear lista vacia
  Maxdist_list<-list()
  
  # calcular para cada elemento de la lista
  for( i in seq_along(Viajes_list)){
    
    data<-Viajes_list[[i]]
    var1<-"maxdist_km"
    
    Maxdist_df <- data %>%
      dplyr::summarise(maxdist_km=max(data[[var1]],na.rm=TRUE))
    
    trip_id<-dplyr::first(data$trip_number)
    
    Maxdist_list[[i]]<- data.frame(trip_id = trip_id,
                                   maxdist_km = Maxdist_df)
    
  }
  
  Maxdist_df <- do.call("rbind",Maxdist_list)
  
  
  Params_df<-cbind(Maxdist_df,Totaldist_df,Horas_df)
  Params_df<-Params_df[,c("trip_id",
                          "maxdist_km","totaldist_km","duration_h",
                          "trip_start","trip_end")]
  
  return(Params_df)
  
}