% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calcular_totaldist.R
\name{calcular_totaldist}
\alias{calcular_totaldist}
\title{Calcula distancia recorrida de la colonia por viaje}
\usage{
calcular_totaldist(GPS_data = GPS_data, separador = separador)
}
\arguments{
\item{GPS_data}{un data frame con datos de Longitude y Latitude}

\item{separador}{El nombre de la columna a usar para separar los viajes, puede ser el numero del viaje o separar por individuos. Escribir entre  comillas.}
}
\value{
regresa un nuevo data frame con la distancia total recorrida por viaje.
}
\description{
Calcula distancia recorrida de la colonia por viaje
}
\examples{
totaldist_km<-calcular_totaldist(GPS_data = GPS_edited, separador='trip_number')
}
