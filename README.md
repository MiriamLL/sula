
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sula <img src="man/figures/logo.png" align="right" width = "120px"/>

Este paquete contiene datos de tracks de kena (*Sula dactylatra*)
colectados en Rapa Nui  
<h1>
🗿
</h1>

## Instalación

Puedes instalar este paquete desde [GitHub](https://github.com/) usando:

``` r
# install.packages("devtools")
devtools::install_github("MiriamLL/sula")
```

# Datos

Carga la libreria

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
**Nota** Los datos no estan en formato. Las horas no estan corregidas.

``` r
head(GPS_raw)
```

# Funciones

## Un individuo

### ajustar\_hora 🕐

Esta función corrige el tiempo de acuerdo a la zona horaria, necesitas
incluir tus datos, definir la columna de hora y día, el formato en el
que están y el numero de horas de diferencia.

``` r
GPS_gmt<-ajustar_hora(GPS_raw = GPS_raw,
                            dif_hor = 5,
                            col_dia = 'DateGMT',
                            col_hora = 'TimeGMT',
                            formato="%d/%m/%Y %H:%M:%S")
```

Regresa el mismo data frame con dos columnas adicionales: **dia\_hora**
con el dia y fecha original y **hora\_corregida** con la nueva hora

### localizar\_nido 🐣

Si no sabes las coordenadas del nido esta función usa el primer valor de
los datos de GPS como punto de la colonia. Asume que los datos del nido
corresponde al primer registro de GPS.

``` r
nest_loc<-localizar_nido(GPS_track = GPS_01,
                          lat_col="Latitude",
                          lon_col="Longitude")
```

Regresa un nuevo data frame con dos columnas: Latitude y Longitude.

### identificar\_viajes 🛩️

Agrega una columna de acuerdo a distancia de la colonia para determinar
si esta en un viaje de alimentación o no.

``` r
GPS_trip<-identificar_viajes(GPS_track=GPS_01,
                        nest_loc=nest_loc,
                        distance_km=0.01)
```

En la columna llamada trip:  
**N**=dentro de la distancia considerada como no viaje de alimentación,
y  
**Y**=viaje de alimentación.

### contar\_viajes 🧮

Agrega una columna con el número del viaje y elimina locaciones dentro
de el radio de la colonia.

``` r
GPS_edited<-contar_viajes(GPS_trip=GPS_trip)
```

### dist\_colonia 📏

Agrega una columna con la distancia de la colonia de cada punto.  
**Nota** usa CRS: 4326

``` r
GPS_dist<-dist_colonia(GPS_edited = GPS_edited, nest_loc=nest_loc)
```

Regresa el mismo data frame con una nueva columna llamada ‘maxdist\_km’

### dist\_puntos 📐

Agrega una columna con la distancia entre cada punto.  
**Nota** usa CRS: 4326

``` r
GPS_dist<-dist_puntos(GPS_edited = GPS_edited)
```

Regresa el mismo data frame con una nueva columna llamada
‘pointsdist\_km’.  
Incluye NAs al inicio del viaje.

### duracion\_viaje ⏳
