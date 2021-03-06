## Jason Davis& Lieven Slenders
## Assignment Lesson 6 
## 11-1-2016

#--------------------------------------------------
## Industrial Railways-----------------------------
#--------------------------------------------------


# I Preprocessing -------------------
## Load packages
library(rgdal)
library(raster)
library(downloader)
library(rgeos)

## configure working environment
getwd()
setwd("D:/workspace/geoscripting/lesson6") # set working directory to you own specifications!!


# Download data from source 
download(url = 'http://www.mapcruzin.com/download-shapefile/netherlands-places-shape.zip',
          "data/netherlands-places-shape.zip",
          quiet = T, mode = "wget")
download(url = 'http://www.mapcruzin.com/download-shapefile/netherlands-railways-shape.zip',
         "data/netherlands-railways-shape.zip",
         quiet = T, mode = "wget")

# manually
# http://www.mapcruzin.com/download-shapefile/netherlands-places-shape.zip
# http://www.mapcruzin.com/download-shapefile/netherlands-railways-shape.zip


## load in shapefiles
vector = file.path("data/netherlands-places-shape","places.shp")
places <- readOGR(vector, layer = ogrListLayers(vector)) ## to to read out the shp into spatial object. 

railways_vector <- ("data/netherlands-railways-shape/railways.shp")
railways <- readOGR(railways_vector, layer = ogrListLayers(railways_vector))

## transform to coordinateReference Syste, 
prj_string_RD <- CRS("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +towgs84=565.2369,50.0087,465.658,-0.406857330322398,0.350732676542563,-1.8703473836068,4.0812 +units=m +no_defs")
railwaysRD <- spTransform(railways, prj_string_RD) 
placesRD <- spTransform(places, prj_string_RD)

## select industrial from types
railwaysdf <- railwaysRD[railwaysRD$type == "industrial",]

# combine places and selected railways in DF
DF <- list("railways" = railwaysdf, "places" = placesRD)


# 2 making a buffer around railways 1000m ----------------------------
railwaysBuffer <- gBuffer(DF$railways, width = 1000,byid=TRUE)


#  place that intersects with the buffer
intersectPlaces <- gIntersection(DF$places, railwaysBuffer) # Returns all spatial intersections as sp objects of the appropriate class
i <- gIntersects(DF$places, railwaysBuffer, byid = TRUE) # gIntersects returns TRUE if spgeom1 and spgeom2 have at least one point in common.
city <- DF$places@data[i]

placeName <- city[2]
placePopulation <- city[4]
intersectObjects <- c(intersectPlaces, placeName, placePopulation)


## Create plot  -------------------------------------------------
visualization <- function(railwaysBuffer, DF, intersectObjects) { 
  plot(railwaysBuffer, col = "red", main = "railwaybuffer", axes=T)
  plot(intersectObjects[[1]], add = TRUE, col = "black") 
  plot(DF$railways, add = TRUE, col = "white") 
  box()
  grid()
  scalebar(d = 1000, label = "1000 kilometers", lwd = 1) 
  legend("topright", legend = intersectObjects[2], bty = "n", title = "City Name")
}

## Answer questions -----------------------------------------------------------
## The city is Utrecht and it's population is 10000

