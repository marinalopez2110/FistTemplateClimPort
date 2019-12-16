####PLOTTING TEMPERATURE MAX TIME SERIES for MANY FILES

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
library(here) 
library(stringr) 
library(purrr) 

###Declaring filanmes and variables to explore####
setwd("C:\\Users\\mlopez\\Documents\\GitHub\\Data Ouranos") #TELUQ
path = "C:\\Users\\mlopez\\Documents\\GitHub\\Data Ouranos"

#REGEX to find all files starting with the relevant vairable, any model, any rcp and any year:
file.names <- dir(path, pattern = "^tasmax_day_[A-Za-z1-9-]+_rcp[0-9]+_r1i1p1_na10kgrid_qm-moving-50bins-detrend_[0-9]+[.]nc")
file.names
RelVar <- "tasmax" #Relevant variable

#Loop to open all the netncd files of the variable that we care>
var_array1 <- array(0, dim=c(1064,700,1095))
time1 <- c()
k=1
for (i in 1:length(file.names)){
  print ("Printing i")
  print (i)
  j <- i*365
  print ("Printing j")
  print (j)
  ncin <- nc_open(file.names[i]) #open netcdf file
  print(ncin)
  dncin1 <- dim(ncin)
  print ("Printing dimessions of ncin")
  print (dncin1)
  dimvar <- dim (ncvar_get(ncin,RelVar))
  print ("Printing dimmesions of de variable tasmax on ncin")
  print (dimvar)
  var_array1[,,k:j] <- ncvar_get(ncin,RelVar)
  dim(var_array1)
  print ("Printing temperature array")
  print (var_array1)
  time1[k:j] <- ncvar_get(ncin,"time")
  print ("Printing time")
  print (time1)
  k <- 1+j
  print ("Printing k")
  print (k)
 
}




######Starts Exploring and creating varibales#####
### Longitude and Latitude varibales and dimenssions
lon <- ncvar_get(ncin,"lon")
nlon <- dim(lon)
summary(lon)
lat <- ncvar_get(ncin,"lat")
nlat <- dim(lat)
summary (lat)

#Exploring Relevant variable (temp) and time variables
dunits <- ncatt_get(ncin, RelVar,"units")
dunits
tunits <- ncatt_get(ncin,"time","units")
tunits
time <- ncvar_get(ncin,"time")
time1
nt <- length(time1)
nt
ncin$dim$time$units
ncin$dim$time$calendar


###NOTE - checking date - not correct, this gives 14-dec-2020 instead of 01-Jan2021. All the leap years missing
as.Date("1950-01-01") + 25915


####Finishes Exploring and creating varibales#####

######## STARTS CODE FOR THE TIME SERIES PLOT##########
# reshape the array into vector
#var_array <- ncvar_get(ncin,RelVar)
dim(var_array1)
var_vec_long <- as.vector(var_array1)
length(var_vec_long)

# reshape the vector into a matrix
var_mat <- matrix(var_vec_long, nrow=nlon*nlat, ncol=nt)
dim(var_mat)
head(na.omit(var_mat))

# create a dataframe
lonlat <- as.matrix(expand.grid(lon,lat))
var_df02 <- data.frame(cbind(lonlat,var_mat))
names(var_df02) <- c("lon","lat")
names(var_df02[3:(j+2)]) <- format(as.Date(as.numeric(time1), origin = "1950-01-01"))
time2 <- as.Date(as.numeric(time1), origin = "1950-01-01")
# Omit Invalid Values
head(na.omit(var_df02))
ValidValuesVar = na.omit(var_df02)
ValidValuesVar

#get the mean of every column for ValidValuesVar, so we have the mean variable of every day in all locations
MeanVarDayQuebec = colMeans(ValidValuesVar) - 273.15
MeanVarDayQuebec

plot (time2, MeanVarDayQuebec[3:(j+2)],
      main="Moyenne des température maximales quotidiennes (°C) ",
      xlab = "Année",
      ylab="Température (°C)",
      col= "red")


####### FINISHES CODE FOR TIME SERIES ############################

nc_close(ncin) # Close netcdf file

