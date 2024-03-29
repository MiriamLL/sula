% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dist_colonia.R
\name{dist_colonia}
\alias{dist_colonia}
\title{Distancia del nido por cada punto}
\usage{
dist_colonia(GPS_edited = GPS_edited, nest_loc = nest_loc)
}
\arguments{
\item{GPS_edited}{es el data frame con una columna llamada "Latitude" y otra llamada "Longitude"}

\item{nest_loc}{es un data frame con una columna llamada "Latitude" y otra llamada "Longitude"}
}
\value{
regresa el data frame con una nueva columna llamada "max_dist_km"
}
\description{
Distancia del nido por cada punto
}
\examples{
nest_loc<-data.frame(Longitude = -109.4531, Latitude = -27.20097)
GPS_dist<-dist_colonia(GPS_edited = GPS_edited, nest_loc=nest_loc)
}
