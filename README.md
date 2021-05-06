
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sula <img src="man/figures/logo.png" align="right" width = "120px"/>

[![DOI](https://zenodo.org/badge/354821022.svg)](https://zenodo.org/badge/latestdoi/354821022)

Este paquete contiene:  
- **Datos** de tracks de kena (*Sula dactylatra*) colectados en Rapa Nui
para replicar los ejemplos 🗿  
- **Trece funciones** para limpiar y calcular parámetros de viajes a
partir de datos GPS

## Instalación

Puedes instalar este paquete desde [GitHub](https://github.com/) usando:

``` r
# install.packages("devtools")
devtools::install_github("MiriamLL/sula")
```

# Datos

Carga la librería

``` r
library(sula)
```

## Un individuo 💃🏽

Carga los datos de GPS de un individuo.  
**Nota** Incluye columna con fecha y hora en formato POSIXct

``` r
head(GPS_01)
```

## Multiples individuos 👯‍

Carga los datos de GPS de diez individuos.  
**Nota** Son datos en crudo por lo que las horas no están corregidas.

``` r
head(GPS_raw)
```

## Notas de campo

Incluye el periodo cuando se colocó el dispositivo hasta cuando se
retiró.  
Nota: no corresponden al periodo real de muestreo. Se proveen estos
datos para practicar las funciones.

``` r
Notas<-Notas
```

# Funciones

## ajustar\_hora 🕐

Esta función corrige el tiempo de acuerdo a la zona horaria, se necesita
especificar los datos GPS, el nombre de la columna que contiene datos de
hora y día, el formato en el que están éstos datos, y el número de horas
de diferencia a corregir de acuerdo al GMT.

``` r
GPS_gmt<-ajustar_hora(GPS_data = GPS_raw,
                      dia_col = 'DateGMT',
                      hora_col = 'TimeGMT',
                      formato="%d/%m/%Y %H:%M:%S",
                      dif_hor = 5)
```

Regresa el mismo data frame con dos columnas adicionales: **dia\_hora**
con el día y fecha original y **hora\_corregida** con la hora
correspondiente al GMT.

## Un individuo

### recortar\_periodo

Este función permite recortar periodos dentro de los datos.

``` r
GPS_recortado<-recortar_periodo(GPS_data=GPS_01,
                                inicio='02/11/2017 18:10:00',
                                final='05/11/2017 14:10:00',
                                dia_col='DateGMT',
                                hora_col='TimeGMT',
                                formato="%d/%m/%Y %H:%M:%S")
#> El track original contenia 1038 filas y el track editado contiene 986 filas
```

Nota: El formato de tiempo y hora debe ser el mismo formato que el
formato de inicio y final.

#### localizar\_nido 🐣

Esta función usa el primer valor de los datos de GPS como punto de la
colonia, sirve para identificar la localización del nido por individuo.
Regresa un nuevo data frame con dos columnas: Latitude y Longitude
correspondientes a la localización del nido.

``` r
nest_loc<-localizar_nido(GPS_data = GPS_01,
                          lat_col="Latitude",
                          lon_col="Longitude")
```

Nota: Asume que los datos del nido corresponde al primer registro de
GPS.

#### identificar\_viajes 🛩️

Esta función agrega una columna de acuerdo a distancia de la colonia
para determinar si esta en un viaje de alimentación o no.

``` r
GPS_trip<-identificar_viajes(GPS_data=GPS_01,
                        nest_loc=nest_loc,
                        distancia_km=1)
```

En la columna llamada trip:  
**N**=dentro de la distancia considerada como no viaje de alimentación,
y  
**Y**=viaje de alimentación.

#### contar\_viajes 🧮

Esta función agrega una columna con el número del viaje y elimina
locaciones dentro de el radio de la colonia.

``` r
GPS_edited<-contar_viajes(GPS_data=GPS_trip)
```

#### dist\_colonia 📏

Agrega una columna con la distancia de la colonia de cada punto. Regresa
el mismo data frame con una nueva columna llamada ‘maxdist\_km’

``` r
GPS_dist<-dist_colonia(GPS_data = GPS_edited, nest_loc=nest_loc)
```

**Nota** usa CRS: 4326. Enlaces: [¿referencia
geográfica?](https://mgimond.github.io/Spatial/chp09-0.html), [¿cual
usar?](https://geocompr.robinlovelace.net/reproj-geo-data.html)

#### dist\_puntos 📐

Agrega una columna con la distancia entre cada punto. Regresa el mismo
data frame con una nueva columna llamada ‘pointsdist\_km’.

``` r
GPS_dist<-dist_puntos(GPS_data = GPS_edited)
```

**Nota** usa CRS: 4326. Incluye NAs al inicio del viaje. Enlaces:
[¿referencia
geográfica?](https://mgimond.github.io/Spatial/chp09-0.html), [¿cual
usar?](https://geocompr.robinlovelace.net/reproj-geo-data.html)

## Obtener parametros de los viajes

#### calcular\_duracion ⏳

Identifica el inicio y el final del viaje y calcula la duración. Regresa
un nuevo data frame con 4 columnas: trip\_id, trip\_start, trip\_end y
duration.

``` r
duracion<-calcular_duracion(GPS_data = GPS_edited,
                              col_diahora = "tStamp",
                              formato = "%Y-%m-%d %H:%M:%S",
                              unidades="hours")
```

Nota: la duración se calcula en valores númericos.

#### calcular\_totaldist 📐

Calcula distancia recorrida de la colonia por viaje.  
Debe contener la columna Longitude y Latitude con estos nombres.  
Regresa un nuevo data frame con la distancia total recorrida por viaje.

``` r
totaldist_km<-calcular_totaldist(GPS_edited = GPS_edited)
```

#### calcular\_maxdist 📏

Obtiene la distancia máxima de la colonia por viaje.  
Debe contener la columna Longitude y Latitude con estos nombres.  
Regresa un nuevo data frame con la distancia máxima de la colonia por
viaje.

``` r
maxdist_km<-calcular_maxdist(GPS_data = GPS_edited, nest_loc=nest_loc)
```

#### calcular\_tripparams 📐⏳📏

Calcula la duración de los viajes, la distancia máxima de la colonia y
la distancia total recorrida. Regresa un nuevo data frame con los
parámetros por viaje.

``` r
trip_params<-calcular_tripparams(GPS_data = GPS_edited,
                              col_diahora = "tStamp",
                              formato = "%Y-%m-%d %H:%M:%S",
                              nest_loc=nest_loc)
```

## Multiples individuos

#### recortar\_por\_ID ✂️✂️✂️

Puedes recortar periodos en los viajes.  
Para el ejemplo hay que tener dos data frames:  
Uno con los **datos de GPS** incluyendo las columnas DateGMT,TimeGMT y
IDs.  
Si no tienen estos nombres favor de renombrarlas.  
El otro data frame son los **datos de campo** y deben incluir las
columnas “IDs”, ‘Hora\_inicio’ y “Hora\_final”.  
Si no tienen esos nombres favor de renombrarlas.

``` r
GPS_recortados<-recortar_por_ID(GPS_data=GPS_raw,
                                Notas=Notas,
                                formato="%d/%m/%Y %H:%M:%S")
```

#### localizar\_nidos 🐣🐣🐣

Esta función asume que los datos del nido corresponde al primer registro
de GPS y regresa las coordenadas de los nidos para cada individuo.

``` r
Nidos_df<-localizar_nidos(GPS_data=GPS_raw,
                         lon_col="Longitude",
                         lat_col="Latitude",
                         ID_col="IDs")
```

#### preparar\_varios 🔌🔌🔌

Esta función sirve para preparar los datos antes de calcular parámetros
por individuo.  
En la función especifica: el nombre de tu data frame, el nombre de la
columna de los ID (identificadores por individuo), el nombre de la
columna de la longitud y el nombre de la columna de la latitud. Para
elegir los viajes elige un buffer de fuera de la colonia
(distancia\_km). Elige también tu sistema de referencia geográfica.

``` r
GPS_preparado<-preparar_varios(GPS_data=GPS_raw,ID_col="IDs",
                               lon_col="Longitude",lat_col="Latitude",
                               distancia_km=1,sistema_ref="+init=epsg:4326")
```

Nota que al usar esta función aparecerán warnings. Estos warnings
advierten sobre la transformación del objeto espacial.

Enlaces: [¿referencia
geográfica?](https://mgimond.github.io/Spatial/chp09-0.html), [¿cual
usar?](https://geocompr.robinlovelace.net/reproj-geo-data.html)

#### tripparams\_varios 📐📐📐

Para calcula parámetros de viajes de varios individuos especifica el
nombre de la columna que contiene los identificadores por individuo, el
nombre de la columna que contiene información número del viaje y el
nombre de la columna que contiene información del día y hora en formato
POSTIXct.

``` r
trip_params<-tripparams_varios(GPS_data=GPS_preparado,
                               col_ID = "IDs",
                               col_tripnum="trip_number",
                               ol_diahora="hora_corregida")
```

Nota: para usar esta función tus datos deben tener una columna día y
hora, si no es así, puedes hacerlo de manera manual o usar la función
**ajustar\_hora** de este paquete y poner 0 en la diferencia horaria.

``` r
GPS_preparado<-ajustar_hora(GPS_data = GPS_preparado,
                            dif_hor = 0,
                            dia_col = 'DateGMT',
                            hora_col = 'TimeGMT',
                            formato="%d/%m/%Y %H:%M:%S")
```

# Citar

Los datos de prueba vienen de esa publicación. 🔓 - Lerma M, Dehnhard N,
Luna-Jorquera G, Voigt CC, Garthe S (2020) Breeding stage, not sex,
affects foraging characteristics in masked boobies at Rapa Nui.
Behavioral ecology and sociobiology 74: 149.

-   Lerma M (2021) Package sula. Zenodo.
    <http://doi.org/10.5281/zenodo.4682898>

[![DOI](https://zenodo.org/badge/354821022.svg)](https://zenodo.org/badge/latestdoi/354821022)
