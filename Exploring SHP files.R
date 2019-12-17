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
pa1 = readShapePoly("DOM_BIO", verbose = TRUE, proj4string = x) 
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

names(pa1) #shows the columns in the vector

head(pa1@data) #show a table of some of the data in the vector

str(pa1@data) #shows the type of data in every column

print(pa1$NOM) #Show all data in the column of the vector

"SapiniŠre … bouleau blanc" %in% pa1$NOM

summary(pa1@data) #show statistics of the data by column

summary(pa1@data$NOM)  #gives more info about that particular column
summary(pa1@data$DOM_BIO)
tablepa1 = table(pa1@data$DOM_BIO) #same a summary but with valid values
tablepa1

mean(pa1@data$SUPERFICIE) #Gives the mena of the column

#####SIMPLE VISUALIZATIONS

library(rworldmap)

wn = getMap(resolution = "coarse")
plot("wn")

data(wrld_simpl, package = "maptools")
plot(wrld_simpl, add=T)

Quebec= readOGR(dsn = ".", layer = "DOM_BIO")
plot(Quebec, add=T, col="#f2f2f2", bg="skyblue", axes=TRUE, border="red")

