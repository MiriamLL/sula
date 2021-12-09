#' Identifica viajes, calcula distancia de la colonia de los puntos y distancia entre puntos
#'
#' @param GPS_data un data frame con columnas longitud y latitud en decimales
#' @param lon_col el nombre de la columna con la longitud, es necesario escribirlo con comillas
#' @param lat_col el nombre de la columna con la latitud, escribir con comillas
#' @param distancia_km un numero correspondiente a la distancia de la colonia
#' @param sistema_ref sistema de referencia, por ejemplo "+init=epsg:4326"
#' @param ID_col el nombre de la columna con los IDs 
#'
#' @return el mismo data frame con la columna trip_number, num_seq, max_dist_km, y pointsdist_km
#' @export
#'
#' @examples GPS_final<-preparar_varios(GPS_data=GPS_raw,
#' lon_col="Longitude",
#' lat_col="Latitude",
#' ID_col="IDs",
#' distancia_km=1,
#' sistema_ref="+init=epsg:4326")
preparar_varios<-function(GPS_data=GPS_data,
                          lon_col=lon_col,
                          lat_col=lat_col,
                          ID_col=ID_col,
                          distancia_km=distancia_km,
                          sistema_ref=sistema_ref){
  
  GPS_df<-as.data.frame(GPS_data)
  
  ID_col<-ID_col
  
  cat("\n ES: Apareceran algunos warnings.
      \n EN: Warnings will appear.")
  
  # separa los individuos
  GPS_primero_ls<-split(GPS_df,GPS_df[[ID_col]])
  
  #####################
  # distancia colonia##
  #####################
  GPS_segundo_ls<-list()
  
  # correr iteracion
  for( a in seq_along(GPS_primero_ls)){
    GPS_Ind<-GPS_primero_ls[[a]]
    #identificar nido# 
    Nest_loc<-GPS_Ind %>%dplyr::summarise(Longitude = dplyr::first(GPS_Ind[[lon_col]]),
                                          Latitude  = dplyr::first(GPS_Ind[[lat_col]]), )
    
    
    
    #calcular distancias#
    track_df<-as.data.frame(GPS_Ind)
    track_spatial<-track_df
    track_spatial$lat<-track_spatial[[lat_col]]
    track_spatial$lon<-track_spatial[[lon_col]]
    sp::coordinates(track_spatial)<-~lon+lat
    sp::proj4string(track_spatial)= sp::CRS(sistema_ref)
    track_spatial <- sp::spTransform(track_spatial, sp::CRS(sistema_ref))
    
    # colonia
    colonia<-Nest_loc
    colonia_spatial<- sp::SpatialPoints(cbind(colonia$Longitude,colonia$Latitude)) 
    sp::proj4string(colonia_spatial)= sp::CRS(sistema_ref) 
    colonia_spatial <- sp::spTransform(colonia_spatial, sp::CRS(sistema_ref))
    
    # distancia_km
    maxdist_m<-(geosphere::distm(track_spatial,colonia_spatial,fun = geosphere::distHaversine))
    meters_df<-cbind(track_df,maxdist_m)
    maxdist_km<-round(meters_df$maxdist_m/1000,digits=2)
    
    GPS_Ind$maxdist_km<-maxdist_km
    
    GPS_segundo_ls[[a]]<-GPS_Ind
    GPS_segundo_df <- do.call("rbind",GPS_segundo_ls)
  }
  
  #identificar viajes
  GPS_tercero_ls<-split(GPS_segundo_df,GPS_segundo_df[[ID_col]])
  
  GPS_cuarto_ls<-list()
  
  for( b in seq_along(GPS_tercero_ls)){
    distancia_km<-distancia_km
    GPS_Ind<-GPS_tercero_ls[[b]]
    Individuo<-dplyr::first(GPS_Ind[[ID_col]])
    Nest_loc<-GPS_Ind %>%dplyr::summarise(Longitude = dplyr::first(GPS_Ind[[lon_col]]),
                                          Latitude  = dplyr::first(GPS_Ind[[lat_col]]), )
    
    track_df<-as.data.frame(GPS_Ind)
    track_spatial<-track_df
    track_spatial$lat<-track_spatial[[lat_col]]
    track_spatial$lon<-track_spatial[[lon_col]]
    sp::coordinates(track_spatial)<-~lon+lat
    sp::proj4string(track_spatial)= sp::CRS(sistema_ref)
    track_spatial <- sp::spTransform(track_spatial, sp::CRS(sistema_ref))
    
    #colonia
    colonia<-Nest_loc
    colonia_spatial<- sp::SpatialPoints(cbind(colonia$Longitude,colonia$Latitude)) 
    sp::proj4string(colonia_spatial)= sp::CRS(sistema_ref) 
    colonia_spatial <- sp::spTransform(colonia_spatial, sp::CRS(sistema_ref))
    
    # distancia_km
    distancia_km_in<-distancia_km/100
    distancia_buf<-rgeos::gBuffer(colonia_spatial, width=1*distancia_km_in) 
    
    # distancia_buffer
    distancia_buffer<-distancia_buf
    # tiene que ser convertido a data frame para que aparezca la columna
    distancia_buffer_df<-data.frame(ID=1:length(distancia_buffer)) 
    
    #problema nota con slot, agregar importFrom("methods", "slot") en NAMESPACE (manualmente)
    distancia_buffer_id <- sapply(methods::slot(distancia_buffer, "polygons"), 
                                  function(x) methods::slot(x, "ID"))
    
    distancia_buffer_df <- data.frame(ID=1:length(distancia_buffer), row.names = distancia_buffer_id)
    distancia_buffer<- sp::SpatialPolygonsDataFrame(distancia_buffer, distancia_buffer_df)
    sp::proj4string(distancia_buffer) <- sp::proj4string(track_spatial)
    track_buffer<-sp::over(track_spatial, distancia_buffer) 
    
    #todo lo que esta dentro del buffer es 1 y fuera es 0
    track_buffer_df<-as.data.frame(track_buffer)
    track_df$trip<-as.numeric(track_buffer_df$ID)
    
    #sustituye nas por ceros
    track_df$trip[is.na(track_df$trip)] <- 0
    
    track_df$trip<-gsub("1", "N", track_df$trip)
    track_df$trip<-gsub("0", "Y", track_df$trip)
    
    GPS_cuarto_ls[[b]]<-track_df
  }
  
  #HERE GENERATES THE PROBLEM
  
  GPS_quinto_df <- do.call("rbind",GPS_cuarto_ls)
  
  #Contar viajes
  GPS_sexto_ls<-split(GPS_quinto_df,GPS_quinto_df[[ID_col]])
  
  GPS_septimo_ls<-list()
  
  for( c in seq_along(GPS_sexto_ls)){
    GPS_Ind<-GPS_sexto_ls[[c]]
    
    trip_data<-GPS_Ind
    
    #add secuence
    num_seq<-nrow(trip_data)
    num_seq<-as.numeric(num_seq)
    trip_data$num_seq<-paste(seq(1:num_seq))
    
    #subset only trips
    only_trips<-subset(trip_data,trip_data$trip == "Y")
    only_trips$num_seq<-as.integer(only_trips$num_seq)
    only_trips$trip_number<-(cumsum(c(1L, diff(only_trips$num_seq)) != 1L))
    only_trips$trip_number<-paste0("trip_",only_trips$trip_number+1)
    
    GPS_septimo_ls[[c]]<-only_trips
  }
  
  GPS_octavo_df <- do.call("rbind",GPS_septimo_ls)
  
  # no visible binding for global variable 'IDs'
  data<-GPS_octavo_df
 
  # #must have at least three locs
  GPS_noveno_df <- data %>%
    dplyr::group_by(data$IDs,data$trip_number)%>%
    dplyr::filter(dplyr::n() >= 3)
  
  GPS_noveno_ls<-split(GPS_noveno_df,GPS_noveno_df[[ID_col]])
  GPS_decimo_ls<-list()
  
  col_tripnum<-'trip_number'
  
  for( d in seq_along(GPS_noveno_ls)){
    GPS_Ind<-GPS_noveno_ls[[d]]
    
    
    
    Viajes_ls<-split(GPS_Ind,GPS_Ind[[col_tripnum]])
    
    Viajes_por_ID<-list()
    Viajes_lista<-list()
    
    for( e in seq_along(Viajes_ls)){
      Viaje_df<-Viajes_ls[[e]]
      
      Viaje_coords<- Viaje_df[,c(lon_col,lat_col)]
      Viaje_spatial <- sp::SpatialPointsDataFrame(coords = Viaje_coords, data = Viaje_df)
      sp::proj4string(Viaje_spatial)= sp::CRS(sistema_ref)  
      
      #calcula la distancia para cada punto  
      Viaje_distancias<-sapply(2:nrow(Viaje_spatial),
                               function(f){geosphere::distm( Viaje_spatial[f-1,], Viaje_spatial[f,])})
      
      Viaje_distancias<-c(NA,Viaje_distancias)
      Viaje_df$pointsdist_km<-round(Viaje_distancias/1000,2)
      #Viaje_df$pointsdist_km[is.na(Viaje_df$pointsdist_km)] <- 0
      
      Viaje_df<-as.data.frame(Viaje_df)
      
      Viajes_lista2<-list(Viaje_df) #crea mas de un elemento en la lista, era porque el i se convertia en cinco!
      Viajes_por_ID[e]<-Viajes_lista2
      
    }
    
    Viajes_Ind <- do.call("rbind",Viajes_por_ID)
    Viajes_Ind_ls<-list(Viajes_Ind)
    Viajes_final <- c(Viajes_lista, Viajes_Ind_ls)
    GPS_decimo_ls[d]<-Viajes_final
  }
  
  GPS_onceavo_df <- do.call("rbind",GPS_decimo_ls)
  
  # Columna dia hora
  # GPS_onceavo_df$diahora<-paste(GPS_onceavo_df[[dia_col]],GPS_onceavo_df[[hora_col]])
  # GPS_onceavo_df$diahora<- as.POSIXct(strptime(as.character(GPS_onceavo_df$diahora),formato), "GMT")
  
  var3<-c(ID_col,"trip_number","num_seq")
  
  GPS_doceavo_df<-GPS_onceavo_df %>% 
    dplyr::relocate(var3)
  
  GPS_doceavo_df$trip<-NULL
  GPS_doceavo_df$`data$IDs`<-NULL
  GPS_doceavo_df$`data$trip_number`<-NULL
  
  return(GPS_doceavo_df)
}