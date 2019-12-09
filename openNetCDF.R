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
library(ncdf4.tools)

setwd("C:\\Users\\mlopez\\Documents\\GitHub\\Data Ouranos") #TELUQ

fname <- "tasmax_day_BNU-ESM_rcp45_r1i1p1_na10kgrid_qm-moving-50bins-detrend_1956.nc"
ncin <- nc_open(fname)
print(ncin)
lon <- ncvar_get(ncin,"lon")
nlon <- dim(lon)
summary(lon)
lat <- ncvar_get(ncin,"lat")
nlat <- dim(lat)
summary (lat)
tmp.array.day <- ncvar_get(ncin,"tasmax")
tmp.array.day <- tmp.array -273.15 ###Convert into Celsius
dim(tmp.array.day)
dunits <- ncatt_get(ncin,"tasmax","units")
dunits
tunits <- ncatt_get(ncin,"time","units")
tunits
time <- ncvar_get(ncin,"time")
time
nt <- dim(time)
nt
ncin$dim$time$units
ncin$dim$time$calendar

###Convert into raster
rasbrick <- brick(fname)
rasbrick

TempMax <- brick(fname, varname="tasmax", layer="time")
str(TempMax)

###Create a time index for the multi-layer objetct
TIME <- as.POSIXct(substr(TempMax@data@names, start = 2, stop=20), format="%Y.%m.%d")
dftime <- data.frame(INDEX = 1:length(TIME), TIME=TIME)

###Create a subset of only the fist month of the year
subset <- dftime[format(dftime$TIME, "%m") == "01",]

sub.temp <- TempMax[[subset$INDEX]]

temp_month1 <- calc(sub.temp, fun=mean) #mean temperature of the month
plot(temp_month1)

nc_close(ncin)

###########CREATING A PLOT MAP FROM A SLICE OF DATA (ONE DAY)
m <- 1 #select day
tmp.slice <- tmp.array.day[,,m] #CHANGE LAST DIGIT TO SELECT THE DAY (ex.1 for jan, 168 for june)

image(lon,lat,tmp.slice)

mapCDFtemp <- function(lat,lon,tas) #model and perc should be a string
  
{
  titletext <- "Température Max Québec"
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

# create dataframe -- reshape data
# matrix (nlon*nlat rows by 2 cols) of lons and lats
lonlat <- as.matrix(expand.grid(lon,lat))
dim(lonlat)

# vector of `tmp` values
tmp_vec <- as.vector(tmp.slice)
length(tmp_vec)

# create dataframe and add names
dname <- "tasmax"  # note: tmp means temperature (not temporary)
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
names(tmp_df02) <- c("lon","lat","tmpJan01","tmpJan02","tmpMar","tmpApr","tmpMay","tmpJun",
                     "tmpJul","tmpAug","tmpSep","tmpOct","tmpNov","tmpDec")
# options(width=96)
head(na.omit(tmp_df02, 20))

# get the annual mean and MTWA and MTCO
tmp_df02$mtwa <- apply(tmp_df02[3:367],1,max) # mtwa
tmp_df02$mtco <- apply(tmp_df02[3:367],1,min) # mtco
tmp_df02$mat <- apply(tmp_df02[3:367],1,mean) # annual (i.e. row) means
head(na.omit(tmp_df02))

dim(na.omit(tmp_df02))


# create a dataframe without missing values
tmp_df03 <- na.omit(tmp_df02)
head(tmp_df03)