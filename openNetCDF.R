library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggmap)
library(viridis)
library(weathermetrics)
library(chron)
library(RColorBrewer)
library(lattice)
library(ncdf4)

ncin <- nc_open("pr_day_ACCESS1-3_rcp45_r1i1p1_na10kgrid_qm-moving-50bins-detrend_1951.nc")