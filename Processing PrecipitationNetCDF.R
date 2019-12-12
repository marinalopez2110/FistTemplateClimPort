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
fname <- "pr_day_ACCESS1-3_rcp45_r1i1p1_na10kgrid_qm-moving-50bins-detrend_1951.nc"
RelVar <- "pr" #Relevant variable

ncin <- nc_open(fname) #open netcdf file
print(ncin)


######Starts Exploring and creating varibales#####
### Longitude and Latitude varibales and dimensions
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
str(PlotVar)

###Create a time index for the multi-layer objetct
TIME <- as.POSIXct(substr(PlotVar@data@names), format="%Y.%m.%d")
dftime <- data.frame(INDEX = 1:length(TIME), TIME=TIME)
dftime

###Create a subset of only the fist month of the year
subset <- dftime[format(dftime$TIME, "%m") == "01",]
subset
sub.var <- PlotVar[[subset$INDEX]]
var_vec_long <- calc(sub.var, fun=sum) #Sum of precipitation of the month
plot(var_vec_long) #plot in mm/day for ONE MONTH

####### FINISHES PLOT MAP PER MONTH########


######## STARTS CODE FOR THE TIME SERIES PLOT##########
# reshape the array into vector
var_array <- ncvar_get(ncin,RelVar)
var_vec_long <- as.vector(var_array)
length(var_vec_long)

# reshape the vector into a matrix
var_mat <- matrix(var_vec_long, nrow=nlon*nlat, ncol=nt)
dim(var_mat)

head(na.omit(var_mat))

# create a dataframe
lonlat <- as.matrix(expand.grid(lon,lat))
var_df02 <- data.frame(cbind(lonlat,var_mat))
names(var_df02) <- c("lon","lat","Jan01","Jan02","Jan03","Jan04","Jan05","Jan06",
                     "Jan07","Jan08","Jan09","Jan10","Jan11","Jan12")
# Omit Invalid Values
head(na.omit(var_df02))
ValidValuesVar = na.omit(var_df02)
ValidValuesVar

#get the mean of every column for ValidValuesVar, so we have the mean variable of every day in all locations
SumVarDayQuebec = colSums(ValidValuesVar)
SumVarDayQuebec

plot (SumVarDayQuebec[3:367])
VecPrecDay <- as.vector(SumVarDayQuebec[3:33])
VecPrecDay
TotalPrecMonth <- sum(VecPrecDay, na.rm = FALSE)
TotalPrecMonth
####### FINISHES CODE FOR TIME SERIES ############################

nc_close(ncin) # Close netcdf file

