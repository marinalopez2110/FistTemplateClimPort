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
library(raster)

setwd("C:\\Users\\mlopez\\Documents\\GitHub\\Data Ouranos") #TELUQ

fname <- "tasmax_day_BNU-ESM_rcp45_r1i1p1_na10kgrid_qm-moving-50bins-detrend_1956.nc"
ncin <- nc_open(fname)
print(ncin)
lon <- ncvar_get(ncin,"lon")
dim(lon)
lat <- ncvar_get(ncin,"lat")
dim(lat)
tmp.array <- ncvar_get(ncin,"tasmax")
tmp.array <- tmp.array -273.15 ###Convert into Celsius
dim(tmp.array)
dunits <- ncatt_get(ncin,"tasmax","units")
dunits
tunits <- ncatt_get(ncin,"time","units")
tunits

###Convert into raster
rasbrick <- brick(fname)
rasbrick

TempMax <- brick(fname, vaname="tasmax", layer="time")
str(TempMax)

###Create a time index for the multi-layer objetct
TIME <- as.POSIXct(substr(TempMax@data@names, start = 2, stop=20), format="%Y.%m.%d")
df <- data.frame(INDEX = 1:length(TIME), TIME=TIME)

###Create a subset of only the fist month of the year
subset <- df[format(df$TIME, "%m") == "01",]

sub.temp <- TempMax[[subset$INDEX]]

temp_month1 <- calc(sub.temp, fun=mean)
plot(temp_month1)


nc_close(ncin)

###########CREATING A PLOT MAP FROM A SLICE OF DATA (ONE DAY)
tmp.slice <- tmp.array[,,1] #CHANGE LAST DIGIT TO SELECT THE DAY (ex.1 for jan, 168 for june)

image(lon,lat,tmp.slice)

mapCDFtemp <- function(lat,lon,tas) #model and perc should be a string
  
{
  titletext <- "Température Max Quebec"
  expand.grid(lon, lat) %>%
    rename(lon = Var1, lat = Var2) %>%
    mutate(lon = ifelse(lon > 180, -(360 - lon), lon),
           tas = as.vector(tas)) %>% 
    #mutate(tas = convert_temperature(tas, "k", "c")) %>%
    ggplot() + 
    geom_point(aes(x = lon, y = lat, color = tas),
               size = 0.8) +
    borders("world", colour="black", fill=NA) + 
    scale_color_viridis(na.value="white",name = "Température") + 
    theme(legend.direction="vertical", legend.position="right", legend.key.width=unit(0.4,"cm"), legend.key.heigh=unit(2,"cm")) + 
    coord_quickmap() + 
    ggtitle(titletext) 
}

par(mfrow=c(1,2))
mapCDFtemp(lat,lon,tmp.slice)

