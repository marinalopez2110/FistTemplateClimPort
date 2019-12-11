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
library(ncdf.tools)

###Declaring filanmes and variables to explore####
setwd("C:\\Users\\mlopez\\Documents\\GitHub\\Data Ouranos") #TELUQ
fname <- "tasmin_day_CMCC-CMS_rcp45_r1i1p1_na10kgrid_qm-moving-50bins-detrend_1954.nc"
ncin <- nc_open(fname) #open netcdf file
print(ncin)


######Starts Exploring and creating varibales#####
### Longitude and Latitude varibales and dimenssions
lon <- ncvar_get(ncin,"lon")
nlon <- dim(lon)
summary(lon)
lat <- ncvar_get(ncin,"lat")
nlat <- dim(lat)
summary (lat)

#Exploring temperature and time variables
dunits <- ncatt_get(ncin,"tasmin","units")
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
TempMin <- brick(fname, varname="tasmin", layer="time")
str(TempMin)

###Create a time index for the multi-layer objetct
TIME <- as.POSIXct(substr(TempMin@data@names, start = 2, stop=20), format="%Y.%m.%d")
dftime <- data.frame(INDEX = 1:length(TIME), TIME=TIME)

###Create a subset of only the fist month of the year
subset <- dftime[format(dftime$TIME, "%m") == "01",]

sub.temp <- TempMin[[subset$INDEX]]

temp_month1 <- calc(sub.temp, fun=mean) #mean temperature of the month
plot(temp_month1 - 273.15) #plot in Celsius for ONE MONTH
####### FINISHES PLOT MAP PER MONTH########


######## STARTS CODE FOR THE TIME SERIES PLOT##########
# create dataframe -- reshape data
# matrix (nlon*nlat rows by 2 cols) of lons and lats
lonlat <- as.matrix(expand.grid(lon,lat))
dim(lonlat)

# vector of `tmp` values
tmp_vec <- as.vector(tmp.slice)
length(tmp_vec)

# create dataframe and add names
dname <- "tasmin"  # note: tmp means temperature (not temporary)
tmp_df01 <- data.frame(cbind(lonlat,tmp_vec))
names(tmp_df01) <- c("lon","lat",paste(dname,as.character(m), sep="_"))
head(na.omit(tmp_df01), 10)

# reshape the array into vector
tmp_array <- ncvar_get(ncin,dname)
tmp_vec_long <- as.vector(tmp_array)
length(tmp_vec_long)

# reshape the vector into a matrix
tmp_mat <- matrix(tmp_vec_long, nrow=nlon*nlat, ncol=nt)
dim(tmp_mat)

head(na.omit(tmp_mat))

# create a dataframe
lonlat <- as.matrix(expand.grid(lon,lat))
tmp_df02 <- data.frame(cbind(lonlat,tmp_mat))
names(tmp_df02) <- c("lon","lat","tmpJan01","tmpJan02","tmpJan03","tmpJan04","tmpMay","tmpJun",
                     "tmpJul","tmpAug","tmpSep","tmpOct","tmpNov","tmpDec")
# Omit Invalid Values
head(na.omit(tmp_df02, 20))
ValidValuesTemp = na.omit(tmp_df02)
ValidValuesTemp

#get the mean of every column for ValidValuesTemp, so we have the mean temperature of every day in all locations
MeanTemDayQuebec = colMeans(ValidValuesTemp) - 273.15
MeanTemDayQuebec

plot (MeanTemDayQuebec[3:367])
####### FINISHES CODE FOR TIME SERIES ############################

nc_close(ncin) # Close netcdf file

