####TEMPERATURE ANALYSIS FILE (MAX AND MIN)

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
library(PCICt)


###Declaring filanmes and variables to explore####
setwd("C:\\Users\\mlopez\\Documents\\GitHub\\Data Ouranos") #TELUQ

fname <- "tasmin_day_CMCC-CMS_rcp45_r1i1p1_na10kgrid_qm-moving-50bins-detrend_1954.nc"
RelVar <- "tasmin" #Relevant variable

ncin <- nc_open(fname) #open netcdf file#print(ncin)
print (ncin)

######Starts Exploring and creating varibales#####
### Longitude and Latitude varibales and dimenssions
lon <- ncvar_get(ncin,"lon")
nlon <- dim(lon)
summary(lon)
lat <- ncvar_get(ncin,"lat")
nlat <- dim(lat)
summary (lat)

#Exploring Relevant variable (temp, prec) and time variables
dunits <- ncatt_get(ncin, RelVar,"units")
dunits
tunits <- ncatt_get(ncin,"time","units")
tunits
time <- ncvar_get(ncin,"time")
time
nt <- dim(time)
nt
ncin$dim$time$units
ncin$dim$time$calendar
####Finishes Exploring and creating varibales#####



####### STARTS PLOT MAP PER MONTH########
###Convert into raster
rasbrick <- brick(fname)
rasbrick
PlotVar <- brick(fname, varname=RelVar, layer="time")
strPlotvar <- str(PlotVar)


###Create a time index for the multi-layer objetct
TIME <- as.POSIXct(substr(PlotVar@data@names, start = 2, stop=20), format="%Y.%m.%d")
dftime <- data.frame(INDEX = 1:length(TIME), TIME=TIME)

###Create a subset of only the fist month of the year
subset <- dftime[format(dftime$TIME, "%m") == alist("01","02","03"),] #Selecting 3 months
subset
sub.var <- PlotVar[[subset$INDEX]]
var_vec_long <- calc(sub.var, fun=mean) #mean variable(temp, prec) of the month
plot(var_vec_long - 273.15) #plot in Celsius for THREE MONTH

####### FINISHES PLOT MAP PER MONTH########

#######TO CREATE SHAPEFILE
rasbrick[[1]] #day 1
plot(rasbrick[[1]]) # plot the firs tday
graphics.off() #cleans all plots
r <- raster(rasbrick, layer=1) # Select which data is needed to be saved
r
#
class(r)
plot(r,axes=T)
#
# Use this function "gdal_polygonizeR" for ploygonize big data. It's faster than raster package function.
# https://johnbaumgartner.wordpress.com/2012/07/26/getting-rasters-into-shape-from-r/
# system.time(p <- gdal_polygonizeR(r))
p <- rasterToPolygons(r, dissolve=TRUE)
p
plot(p,axes=T)
# Save as shapefile
writeOGR(p, dsn="C:\\Users\\mlopez\\Documents\\GitHub\\Images", layer='tos_O1_2001_2002', driver="ESRI Shapefile", overwrite_layer=T)




nc_close(ncin) # Close netcdf file

