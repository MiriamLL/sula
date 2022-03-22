#' Adds a column with the trip number and removes central locations
#'
#' @param GPS_data A data frame with a column named 'trip_number'
#'
#' @return Returns a data frame with the trip number and without central locations
#' @export
#'
#' @examples GPS_trips<-count_trips(GPS_data=GPS_trip)
count_trips<-function(GPS_data=GPS_data){
  
  trip_data<-GPS_data
  
  #add sequence
  num_seq<-nrow(trip_data)
  num_seq<-as.numeric(num_seq)
  trip_data$num_seq<-paste(seq(1:num_seq))
  
  #subset only trips
  only_trips<-subset(trip_data,trip_data$trip == "Y")
  only_trips$num_seq<-as.integer(only_trips$num_seq)
  only_trips$trip_number<-(cumsum(c(1L, diff(only_trips$num_seq)) != 1L))
  only_trips$trip_number<-paste0("trip_",only_trips$trip_number+1)
  
  return(only_trips)
}
