## READ IN SHAPEFILES

#setwd("H:\\Couches MFFP") #Ouranos
setwd("C:\\Users\\mlopez\\Documents\\GitHub\\Couches MFFP")  #TELUQ

library(raster)
library(rgeos)
library(maptools)
library(rgdal)
library(shapefiles)


x <- CRS("+proj=longlat +ellps=WGS84")
pa1 = readShapePoly("territoire_guide", verbose = TRUE, proj4string = x) 
plot(pa1)
pa1
