
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

Carga los datos de GPS

``` r
head(GPS_raw)
```

# Funciones

## ajustar\_hora 🕐

Esta función corrige el tiempo de acuerdo a la zona horaria, necesitas
incluir tus datos, definir la columna de hora y dia, el formato en el
que estan y el numero de horas de diferencia.

``` r
GPS_corregido<-ajustar_hora(GPS_raw = GPS_raw,
                            diferencia_horaria = 5,
                            columna_dia = 'DateGMT',
                            columna_hora = 'TimeGMT',
                            formato="%d/%m/%Y %H:%M:%S")
```

Regresa un nuevo data frame con dos columnas adicionales: **dia\_hora**
con el dia y fecha original y **hora\_corregida** con la nueva hora
