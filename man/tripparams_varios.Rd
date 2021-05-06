% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tripparams_varios.R
\name{tripparams_varios}
\alias{tripparams_varios}
\title{Calcula parametros de viajes de varios individuos}
\usage{
tripparams_varios(
  GPS_data = GPS_data,
  col_ID = col_ID,
  col_tripnum = col_tripnum,
  col_diahora = col_diahora
)
}
\arguments{
\item{GPS_data}{un data frame con columnas que incluyan identificador por individuo, identificador por viaje, y una columna en dia y hora.}

\item{col_ID}{el nombre de la columna del data frame que incluye el identificador del individuo}

\item{col_tripnum}{el nombre de la columna del data frame que incluye el identificador del viaje}

\item{col_diahora}{el nombre de la columna del data frame que incluye el dia y hora en formato POSTIXct}
}
\value{
un data frame con parametros de los viajes
}
\description{
Calcula parametros de viajes de varios individuos
}
\examples{
trip_params<-tripparams_varios(GPS_data=GPS_preparado,
col_ID = "IDs",
col_tripnum="trip_number",
col_diahora="hora_corregida")
}