## Jason Davis& Lieven Slenders
## Assignment Lesson 6 
## 11-1-2016

#--------------------------------------------------
## Industrial Railways-----------------------------
#--------------------------------------------------


## Load source packages and functions.-------------------
# Load packages.
library(rgdal)
library(raster)
library(downloader)
# Load functions.
# ... source(')

## configure working environment ----------------------
getwd()
# set working directory to you own specifications!!
setwd("D:/workspace/geoscripting/lesson6")


# Download data from source ------------
# manually or automatically
download(url = 'http://www.mapcruzin.com/download-shapefile/netherlands-places-shape.zip',
          "data/netherlands-places-shape.zip",
          quiet = T, mode = "wget")

# http://www.mapcruzin.com/download-shapefile/netherlands-places-shape.zip
# http://www.mapcruzin.com/download-shapefile/netherlands-railways-shape.zip


# loading in shapefiles

vector = file.path("data/netherlands-places-shape","places.shp")
places <- readOGR(vector, layer = ogrListLayers(vector)) ## to to read out the shp into spatial object. 
str(places)
head(places)

railways_vector <- ("data/netherlands-railways-shape/railways.shp")
railways <- readOGR(railways_vector, layer = ogrListLayers(railways_vector))

#select industrial fromn types
industr <- railways[railways$type %in% 'industrial',]

# buffer around railways
library(rgeos)

buffer <- industr

# NDVI calculation per year.
NDVI2014 <- overlay(L8proc[[1]], L8proc[[2]], fun=calcNDVI)
NDVI1990 <- overlay(L5proc[[1]], L5proc[[2]], fun=calcNDVI)

