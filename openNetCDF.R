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
library(maps)

setwd("C:\\Users\\mlopez\\Documents\\GitHub\\Data Ouranos") #TELUQ

ncin <- nc_open("tasmax_day_BNU-ESM_rcp45_r1i1p1_na10kgrid_qm-moving-50bins-detrend_1956.nc")
print(ncin)
lon <- ncvar_get(ncin,"lon")
dim(lon)
lat <- ncvar_get(ncin,"lat")
dim(lat)
tmp.array <- ncvar_get(ncin,"tasmax")
tmp.array <- tmp.array -273.15
dim(tmp.array)
dunits <- ncatt_get(ncin,"tasmax","units")
dunits
tunits <- ncatt_get(ncin,"time","units")
tunits
nc_close(ncin)
tmp.slice <- tmp.array[,,1]

image(lon,lat,tmp.slice)

mapCDFtemp <- function(lat,lon,tas) #model and perc should be a string
  
{
  
  titletext <- "title"
  
  expand.grid(lon, lat) %>%
    
    rename(lon = Var1, lat = Var2) %>%
    
    mutate(lon = ifelse(lon > 180, -(360 - lon), lon),
           
           tas = as.vector(tas)) %>% 
    
    #mutate(tas = convert_temperature(tas, "k", "c")) %>%
    
    
    
    ggplot() + 
    
    geom_point(aes(x = lon, y = lat, color = tas),
               
               size = 0.8) + 
    
    borders("world", colour="black", fill=NA) + 
    
    scale_color_viridis(na.value="white",name = "Temperature") + 
    
    theme(legend.direction="vertical", legend.position="right", legend.key.width=unit(0.4,"cm"), legend.key.heigh=unit(2,"cm")) + 
    
    coord_quickmap() + 
    
    ggtitle(titletext) 
  
}
mapCDFtemp(lat,lon,tmp.slice)
