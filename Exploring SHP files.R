## READ IN SHAPEFILES

#setwd("H:\\Couches MFFP") #Ouranos
setwd("C:\\Users\\mlopez\\Documents\\GitHub\\Couches MFFP")  #TELUQ

library(raster)
library(rgeos)
library(maptools)
library(rgdal)
library(shapefiles)

#1 readShapePoly of the package maptools
x <- CRS("+proj=longlat +ellps=WGS84")
pa1 = readShapePoly("territoire_guide", verbose = TRUE, proj4string = x) 
plot(pa1)
pa1

#2 readOGR
pa2 = readOGR(".", "territoire_guide")

#3 PBSMapping - it could distord data. Only use if any of the 2 previos don't work
library(PBSmapping)
pa3 = importShapefile("territoire_guide.shp")
plot(pa3)

#palutm <- spTransform(pa1, CRS("+proj=utm +zone=21 +ellps=WGS84")) #Gives error Error in .spTransform_Polygon(input[[i]], to_args = to_args, from_args = from_args,
#Quebec zone between 17 and 21

#EXPLORE SHAPEFILES ATTRIBUTES
pa1
extent(pa1) #show max and min

names(pa1) #not much info in this case

head(pa1@data) #not much info in this case

str(pa1@data)

print(pa1$TER_GUIDE) #this case only has one attribute

"1a" %in% pa1$TER_GUIDE #Only gives TRUE

summary(pa1@data) #not much info in this case - 25 attributes

summary(pa1@data$TER_GUIDE)  #not much info in this case - 25 attributes


