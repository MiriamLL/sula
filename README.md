
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

## Multiples individuos 👯‍

Carga los datos de GPS de diez individuos.  
**Nota** Las horas no estan corregidas.

``` r
head(GPS_raw)
```

## Un individuo 💃🏽

Carga los datos de GPS de un individuo.  
**Nota** Incluye columna con fecha y hora en formato POSIXct

``` r
head(GPS_01)
```

# Funciones

## ajustar\_hora 🕐

Esta función corrige el tiempo de acuerdo a la zona horaria, necesitas
incluir tus datos, definir la columna de hora y dia, el formato en el
que estan y el numero de horas de diferencia.

``` r
GPS_gmt<-ajustar_hora(GPS_raw = GPS_raw,
                            dif_hor = 5,
                            col_dia = 'DateGMT',
                            col_hora = 'TimeGMT',
                            formato="%d/%m/%Y %H:%M:%S")
```

Regresa un nuevo data frame con dos columnas adicionales: **dia\_hora**
con el dia y fecha original y **hora\_corregida** con la nueva hora

## localizar\_nido 🐣

Si no sabes las coordenadas del nido esta función usa el primer valor de
los datos de GPS como punto de la colonia. Asume que los datos del nido
corresponde al primer registro de GPS. Esta función esta pensada para
obtener datos de un solo individuo.

``` r
nest_loc<-localizar_nido(GPS_track = GPS_01,
                          lat_col="Latitude",
                          lon_col="Longitude")
```

Regresa un nuevo data frame con dos columnas: Latitude y Longitude.
