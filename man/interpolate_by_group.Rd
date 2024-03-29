% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/interpolate_by_group.R
\name{interpolate_by_group}
\alias{interpolate_by_group}
\title{interpolate_trips, interpolate your tracking data to a specific interval per group}
\usage{
interpolate_by_group(
  GPS_data = GPS_data,
  interval = interval,
  column_datetime = column_datetime,
  column_lat = column_lat,
  column_lon = column_lon,
  column_group = column_group
)
}
\arguments{
\item{GPS_data}{you GPS data}

\item{interval}{the interval in seconds}

\item{column_datetime}{a column with date and time, and in a date time format}

\item{column_lat}{the name of your column with the 'Latitude' data}

\item{column_lon}{the name of your column with the 'Longitude' data}

\item{column_group}{the name of your column with the group data}
}
\value{
Gives back a data frame with the interpolated data
}
\description{
interpolate_trips, interpolate your tracking data to a specific interval per group
}
\examples{
GPS_interpolated<-interpolate_by_group(GPS_data=GPS_preparado,interval='900 sec',
column_datetime='dia_hora',column_lat='Latitude',column_lon='Longitude',column_group='trip_number')

}
