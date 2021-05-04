#' Obtiene informacion del nido, usando el primer punto de registro
#'
#' @param GPS_data Un data frame con las columnas Latitude, Longitude y IDs
#' @param lon_col El nombre de la columna donde esta la Longitude
#' @param lat_col El nombre de la columna donde esta la Latitude
#' @param ID_col El nombre de la columna donde estan los IDs
#'
#' @return Un data frame con la localizacion de los nidos
#' @export
#'
#' @examples Nidos_df<-localizar_nidos(GPS_data=GPS_raw,lon_col="Longitude",lat_col="lat_col"Latitude",ID_col="IDs")
localizar_nidos<-function(GPS_data=GPS_data,
                          lon_col=lon_col,
                          lat_col=lat_col,
                          ID_col=ID_col){
  
  GPS_df<-as.data.frame(GPS_data)
  
  # separa los individuos
  GPS_list<-split(GPS_df,GPS_df$IDs)
  
  # crear lista vacia
  Nidos_list<-list()
  
  for( i in seq_along(GPS_list)){
    
    data<-GPS_list[[i]]
    var1<-lon_col
    var2<-lat_col
    var3<-ID_col
    
    nest_loc<-data %>%
      dplyr::summarise(
        Longitude = dplyr::first(data[[var1]]),
        Latitude  = dplyr::first(data[[var2]]), )
    
    nest_loc$ID<-dplyr::first(data[[var3]])
    
    Nidos_list[[i]]<-nest_loc
    
  }
  
  
  Nidos_df <- do.call("rbind",Nidos_list)
  
  return(Nidos_df)
}