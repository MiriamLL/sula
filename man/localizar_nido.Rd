% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/localizar_nido.R
\name{localizar_nido}
\alias{localizar_nido}
\title{Localiza las coordenadas donde esta el nido}
\usage{
localizar_nido(GPS_data = GPS_data, lon_col = lon_col, lat_col = lat_col)
}
\arguments{
\item{GPS_data}{data frame con los datos de GPS debe contener columna de latitud y de longitud en formato numerico.}

\item{lon_col}{nombre de la columna de longitud}

\item{lat_col}{nombre de la columna de latitud}
}
\value{
un data frame con la coordenada del nido para ese individuo
}
\description{
Localiza las coordenadas donde esta el nido
}
\examples{
nest_loc<-localizar_nido(GPS_data = GPS_01,lat_col="Latitude",lon_col="Longitude")
}
