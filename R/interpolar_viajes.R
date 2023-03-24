#' Interpola los viajes de acuerdo a intervalo
#'
#' @param GPS_preparado es el data frame con columnas "Latitude", "Longitude" y "tStamp"
#' @param intervalo es el intervalo al que quieres convertir tu track, por ejemplo "900 secs" 
#' @param col_diahora es la columna con la informacion de dia y hora, en formato POSIXct, por ejemplo "tStamp"
#' @param separador es la columna con la informacion de los viajes, por ejemplo 'trip_number'
#' @param col_ID es la columna con la informacion de los invididuos, por ejemplo "ID"
#'
#' @return el data frame con datos a cada intervalo de tiempo
#' @export
#'
#' @examples GPS_interpolated<-interpolar_viajes(GPS_preparado=GPS_preparado, 
#' intervalo="900 sec", 
#' columna_diahora="dia_hora", 
#' separador='trip_number',
#' columna_ID='IDs')
#' 
interpolar_viajes<-function(GPS_preparado=GPS_preparado,
                                intervalo=intervalo,
                                columna_diahora=columna_diahora,
                                columna_ID=columna_ID,
                                separador=separador){
  
  
  Data<-GPS_preparado
  
  # Separate trips
  if (!is.null(Data[[columna_diahora]])) {
  } else {
    warning("Please check the name in col_diahora")
  }
  
  Data$ID_trip<-paste0((Data[[columna_ID]]),"_",(Data[[separador]]))
  
  Trips_ls<-split(Data,Data$ID_trip)
  
  ## remove element of the list smaller than 3 locs
  Subset_trips <- lapply(Trips_ls, function(x) nrow(x) > 3)
  Long_trips_ls<-Trips_ls[unlist(Subset_trips)]
  
 
  for( i in seq_along(Long_trips_ls)){
    
    Separated_df <- Long_trips_ls[[i]]  
    
    #funcion
    Inter_df<-Separated_df
    
    Inter_df$dt<-Inter_df[[columna_diahora]]#as.POSIXct(strptime(Inter_df$timestamp, "%Y-%m-%d %H:%M:%S"), "GMT")
    
    New_longitude0<-stats::approx(Inter_df$dt,Inter_df$Longitude,xout=seq(min(Inter_df$dt),max(Inter_df$dt),by=intervalo))
    New_longitude1<-data.frame(x=New_longitude0$x,y=New_longitude0$y)
    
    New_latitude0<-stats::approx(Inter_df$dt,Inter_df$Latitude,xout=seq(min(Inter_df$dt),max(Inter_df$dt),by=intervalo))
    New_latitude1<-data.frame(x=New_latitude0$x,y=New_latitude0$y)
    
    New_coords<-cbind(New_longitude1,New_latitude1)
    
    
    colnames(New_coords)<-c('x1','x2','x3','x4')
    
    New_coords$dt<-New_coords$x1
    New_coords$Longitude<-New_coords$x2
    New_coords$Latitude<-New_coords$x4
    New_coords$trip_number<-unique(Inter_df$trip_number)
    New_coords$ID<-unique(Separated_df$ID_trip)
    
    New_coords$x1<-NULL
    New_coords$x2<-NULL
    New_coords$x3<-NULL
    New_coords$x4<-NULL
    
    row.names(New_coords)=NULL
    
    Long_trips_ls[[i]]<- New_coords
  }
  
  Long_trips_interp <- do.call("rbind",Long_trips_ls)
  #note that it reduces the number of recorded tracks
  
  rownames(Long_trips_interp) <- NULL
  return(Long_trips_interp)
  
  
  cat(paste0("\n ES: El track original contenia ", nrow(GPS_preparado),
             " filas y el track interpolado a ",intervalo," contiene ", nrow(Long_trips_interp),
             "\n EN: The original track had ", nrow(GPS_preparado),
             " rows, and the interpolated track to ",intervalo," has ", nrow(Long_trips_interp)))
}
