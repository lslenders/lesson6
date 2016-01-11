## Assignment Lesson 6 
## Jason Davis& Lieven Slenders
## 11-1-2016

#----------------------------------------------------------------

## Load source packages and functions.-------------------
# Load packages.
library(rgdal)
library(raster)
library(downloader)
# Load functions.

# Download manually data from source.
# http://www.mapcruzin.com/download-shapefile/netherlands-places-shape.zip
# http://www.mapcruzin.com/download-shapefile/netherlands-railways-shape.zip

## setting working directory
getwd()

# set working directory to you own specifications!!
setwd("D:/workspace/geoscripting/lesson6")



# loading in shapefiles
railways <- ("data/netherlands-railways-shape/railways.shp")
vector = file.path("data/netherlands-places-shape","places.shp")
places <- readOGR(vector, layer = ogrListLayers(vector)) ## to to read out the shp into spatial object. 

ogrListLayers
