
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sula <img src="man/figures/logo.png" align="right" width = "120px"/>

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4740920.svg)](https://doi.org/10.5281/zenodo.4740920)

This package contains: <br>  
- **Tracking data** from Masked boobies *(Sula dactylatra)* collected at
Easter Island.  
- **Functions** to clean your data and calculate the foraging trip
parameters of the individuals.

**[Enlace en
español](https://www.miriam-lerma.com/posts/2021-05-14-sula/).**

The goal is that you use the data as an example and adapt your data
accordingly to calculate your own foraging trip parameters. Also you can
have most of the information in parallel to your original tracking data
for check-ups in a GIS software.

## Installation

``` r
# install.packages("devtools")
devtools::install_github("MiriamLL/sula")
```

``` r
library(sula)
```

# Funciones

### ajustar_hora 🕐

This function allows you to correct the time of the GPS according to
your GMT. You need to provide your data frame, the name of you columns
containing time and date, the format of those columns and the time
difference between the data and your GMT. It returns hora_corregida with
the corrected time.

``` r
GPS_gmt<-ajustar_hora(GPS_data = GPS_raw,
                      dia_col = 'DateGMT',
                      hora_col = 'TimeGMT',
                      formato="%d/%m/%Y %H:%M:%S",
                      dif_hor = 5)
```

### recortar_periodo

This function allows you to cut specific periods in your data. Inicio
means start, Final means end.

``` r
GPS_recortado<-recortar_periodo(GPS_data=GPS_01,
                                inicio='02/11/2017 18:10:00',
                                final='05/11/2017 14:10:00',
                                dia_col='DateGMT',
                                hora_col='TimeGMT',
                                formato="%d/%m/%Y %H:%M:%S")
#> 
#>  ES: El track original contenia 1038 filas y el track editado contiene 986 filas 
#>  EN: The original track had 1038 rows, and the edited track has 986
```

#### localizar_nido 🐣

This functions identifies the location of the nest assuming that the
first column is the nest location.

``` r
nest_loc<-localizar_nido(GPS_data = GPS_01,
                          lat_col="Latitude",
                          lon_col="Longitude")
```

#### identificar_viajes 🛩️

This function adds a column with the distance from the nest, and a
column to let you know if the location corresponds to a foraging trip or
not. You need to give a buffer in **distancia_km**.

``` r
GPS_trip<-identificar_viajes(GPS_data=GPS_01,
                        nest_loc=nest_loc,
                        distancia_km=1)
```

#### contar_viajes 🧮

This function gives a number to each trip and eliminates the locations
that do not correspond to trips.

``` r
GPS_edited<-contar_viajes(GPS_data=GPS_trip)
```

#### dist_colonia 📏

This function calculates the distance from the colony of each location.
Returns a new column called ‘maxdist_km’.

``` r
GPS_dist<-dist_colonia(GPS_edited = GPS_edited, 
                       nest_loc=nest_loc)
```

#### dist_puntos 📐

This function calculates the distance between each location. Returns a
new column called ‘pointsdist_km’.

``` r
GPS_dist<-dist_puntos(GPS_data = GPS_edited,
                      separador='trip_number')
```

#### calcular_duracion ⏳

This function calculates the duration of each trip. Returns a new data
frame with four columns: trip_id, trip_start, trip_end y duration.

``` r
duracion<-calcular_duracion(GPS_data = GPS_edited,
                            col_diahora = "tStamp",
                            formato = "%Y-%m-%d %H:%M:%S",
                            unidades="hours",
                            separador="trip_number")
```

#### calcular_totaldist 📐

This function calculates the total distance travelled by each trip.

``` r
totaldist_km<-calcular_totaldist(GPS_data= GPS_edited,
                                 separador="trip_number")
```

#### calcular_maxdist 📏

This function calculates the maximum distance of each foraging trip.

``` r
maxdist_km<-calcular_maxdist(GPS_data = GPS_edited, 
                             nest_loc=nest_loc,
                             separador="trip_number")
```

#### calcular_tripparams 📐⏳📏

Calculates trip duration, total distance from the colony and maximum
distance and returns a data frame with the information.

``` r
trip_params<-calcular_tripparams(GPS_data = GPS_edited,
                              diahora_col = "tStamp",
                              formato = "%Y-%m-%d %H:%M:%S",
                              nest_loc=nest_loc,
                              separador="trip_number")
```

#### recortar_por_ID ✂️✂️✂️

This function allows you to cut specific periods in your data using a
data frame with field information (Notas).

``` r
GPS_recortados<-recortar_por_ID(GPS_data=GPS_raw,
                                Notas=Notas,
                                formato="%d/%m/%Y %H:%M:%S")
```

#### localizar_nidos 🐣🐣🐣

This functions identifies the location of the nest from several
individuals assuming that the first column is the nest location.

``` r
Nidos_df<-localizar_nidos(GPS_data=GPS_raw,
                         lon_col="Longitude",
                         lat_col="Latitude",
                         ID_col="IDs")
```

#### preparar_varios 🔌🔌🔌

This functions adds the columns: maximum distance from the colony per
location, distance between locations, trip number

``` r
GPS_preparado<-preparar_varios(GPS_data=GPS_raw,
                               ID_col="IDs",
                               lon_col="Longitude",
                               lat_col="Latitude",
                               distancia_km=1,
                               sistema_ref="+init=epsg:4326")
```

#### tripparams_varios 📐📐📐

This function calculates trip parameters for several individuals.

**Note** to use this function, your data must be in date and time
format. Otherwise you can use the function **ajustar_hora** to convert
it to the correct object class.

``` r
GPS_preparado<-ajustar_hora(GPS_data = GPS_preparado,
                            dif_hor = 0,
                            dia_col = 'DateGMT',
                            hora_col = 'TimeGMT',
                            formato="%d/%m/%Y %H:%M:%S")
```

``` r
trip_params<-tripparams_varios(GPS_data=GPS_preparado,
                               col_ID = "IDs",
                               col_diahora="hora_corregida",
                               separador="trip_number")
```

# Other tools

## Interpolate data

This function interpolates the data according to a set interval

**GPS_preparado** is your data frame with the columns “Latitude” and
“Longitude”  
Set an **interval**, for example “900 secs”  
Define which is the name of the column that contains the information
from day and time (**col_diahora**). For example: “tStamp”  
A **separator**, for example, ‘trip_number’  
This function runs for several individuals therefore the **col_ID**
should correspond to the name of your column with the individuals’ ID

``` r
GPS_interpolated<-interpolar_viajes(GPS_preparado=GPS_preparado, 
                                    intervalo="900 sec", 
                                    col_diahora="dia_hora", 
                                    separador='trip_number',
                                    col_ID='IDs')
```

# Citation

The data comes from this publication 🔓  
- Lerma M, Dehnhard N, Luna-Jorquera G, Voigt CC, Garthe S (2020)
Breeding stage, not sex, affects foraging characteristics in masked
boobies at Rapa Nui. Behavioral ecology and sociobiology 74: 149.

The package can be cited as:  
- Lerma M (2021) Package sula. Zenodo.
<https://doi.org/10.5281/zenodo.4740920>

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4740920.svg)](https://doi.org/10.5281/zenodo.4740920)
