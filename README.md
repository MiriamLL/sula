
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sula

<h1>
🗿
</h1>
<!-- badges: start -->
<!-- badges: end -->

Este paquete contiene datos de tracks de kena (*Sula dactylatra*)
colectados en Rapa Nui

## Instalación

Puedes instalar este paquete desde [GitHub](https://github.com/) usando:

``` r
# install.packages("devtools")
devtools::install_github("MiriamLL/sula")
```

## Ejemplo

Carga la libreria

``` r
library(sula)
```

Carga los datos de GPS

``` r
head(GPSdata)
#>    Latitude Longitude    DateGMT  TimeGMT   IDs
#> 1 -27.20097 -109.4531 02/11/2017 17:05:30 GPS01
#> 2 -27.20084 -109.4531 02/11/2017 17:09:35 GPS01
#> 3 -27.20053 -109.4529 02/11/2017 17:13:50 GPS01
#> 4 -27.20092 -109.4531 02/11/2017 17:17:59 GPS01
#> 5 -27.20065 -109.4529 02/11/2017 17:22:13 GPS01
#> 6 -27.20061 -109.4528 02/11/2017 17:26:25 GPS01
```

# Proximamente

Funciones para editar/corregir tus datos de GPS
