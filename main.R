## Team Puma
## Jason Davis & Lieven Slenders. 
## January 

# -------------------------------------------------------

## setting working directory
getwd()
# set working directory to you own specifications!!
setwd("D:/workspace/geoscripting/lesson6")
# 
dir.create('data/')
dir.create('R/')
dir.create('output/')


## Load source packages and functions.-------------------
# Load packages.
library(rgdal)
library(sp)


## Points ------------------------------------------------

# coordinates of two points identified in Google Earth, for example:
pnt1_xy <- cbind(5.663849, 51.968941)   # enter your own coordinates
pnt2_xy <- cbind(5.647903, 51.966106)# enter your own coordinates
pnt3_xy <- cbind(51.2, 5.7)
# combine coordinates in single matrix
coords <- rbind(pnt1_xy, pnt2_xy)
coords1 <- rbind(pnt1_xy, pnt2_xy, pnt3_xy)

# make spatial points object
prj_string_WGS <- CRS("+proj=longlat +datum=WGS84")
mypoints <- SpatialPoints(coords, proj4string=prj_string_WGS)

# inspect object
mypoints
class(mypoints)
str(mypoints)

# create and display some attribute data and store in a data frame
mydata <- d



































































ata.frame(cbind(id = c(1,2), 
                           Name = c("my first point", 
                                    "my second point")))

# make spatial points data frame
mypointsdf <- SpatialPointsDataFrame(
  coords, data = mydata, 
  proj4string=prj_string_WGS)


spplot(mypointsdf, zcol="Name", col.regions = c("red", "blue"), 
       xlim = bbox(mypointsdf)[1, ]+c(-0.01,0.01), 
       ylim = bbox(mypointsdf)[2, ]+c(-0.01,0.01),
       scales= list(draw = TRUE))

# coimparison sp - spdf
class(mypointsdf)
plot(mypoints)

## lines  --------------------------------------------------
simple_line <- Line(coords)


lines_obj <- Lines(list(simple_line), "1")


spatlines <- SpatialLines(list(lines_obj), proj4string=prj_string_WGS)

## slot "lines"
line_data <- data.frame(Name = "straight line", row.names="1")
mylinesdf <- SpatialLinesDataFrame(spatlines, line_data)

spplot(mylinesdf, col.regions = "blue", 
       xlim = bbox(mypointsdf)[1, ]+c(-0.01,0.01), 
       ylim = bbox(mypointsdf)[2, ]+c(-0.01,0.01),
       scales= list(draw = TRUE))





## Question: What is the difference between Line and Lines?
# ... 

## Writing and reading spatial vector data using OGR ---------------

library(rgdal)
# write to kml ; below we assume a subdirectory data within the current 
# working directory.
dir.create("data", showWarnings = FALSE) 
writeOGR(mypointsdf, file.path("data","mypointsGE.kml"), ##----- How to make this into a function and run these two objects(points and lines) at once through the "create kml'file function.
         "mypointsGE", driver="KML", overwrite_layer=TRUE)
writeOGR(mylinesdf, file.path("data","mylinesGE.kml"), 
         "mylinesGE", driver="KML", overwrite_layer=TRUE)

## read help on ..
# ?readOGR
# ?writeOGR
# Possible Entries # dsn = Data Source Name
# layer = layername

# First 'add path' in GoogleEarth - draw path - Rmouse on path label- save as 
# https://support.google.com/earth/answer/148072?hl=en
dsn = file.path("data","route.kml")
ogrListLayers(dsn) ## to find out what the layers are
myroute <- readOGR(dsn, layer = ogrListLayers(dsn))
# put both in single data frame
proj4string(myroute) <- prj_string_WGS
names(myroute)
myroute$Description <- NULL # delete Description
mylinesdf <- rbind(mylinesdf, myroute)

# explore... 
mylinesdf
plot(mylinesdf)
spplot(mylinesdf)

## Transformation of coordinate system -----------------------

# define CRS object for RD projection
prj_string_RD <- CRS("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +towgs84=565.2369,50.0087,465.658,-0.406857330322398,0.350732676542563,-1.8703473836068,4.0812 +units=m +no_defs")

# perform the coordinate transformation from WGS84 to RD
mylinesRD <- spTransform(mylinesdf, prj_string_RD)
plot(mylinesRD, col = c("red", "blue"))
box()

## calculate length of lines -------------------------------------------------------------------------

library(rgeos)

mylinesdf$length <- gLength(mylinesRD, byid=T)
mylinesdf$length

# Explore in Google Earth - back to WGS84 
mylinesRD_WGS84 <- spTransform(mylinesRD, prj_string_WGS)

writeOGR(mylinesRD_WGS84, file.path("data","mylinesRD_WGS84.kml"), 
         "mylinesRD_WGS84", driver="KML", overwrite_layer=TRUE)

## Polygons --------------------------------------------------------------

# perform the coordinate transformation from WGS84 (i.e. not a projection) to RD (projected)"
# this step is necessary to be able to measure objectives in 2D (e.g. meters)
(mypointsRD <- spTransform(mypointsdf, prj_string_RD))

pnt1_rd <- coordinates(mypointsRD)[1,]
pnt2_rd <- coordinates(mypointsRD)[2,]



# make circles around points, with radius equal to distance between points
# define a series of angles going from 0 to 2pi
ang <- pi*0:200/100

circle1x <- pnt1_rd[1] + cos(ang) * mylinesdf$length[1]
circle1y <- pnt1_rd[2] + sin(ang) * mylinesdf$length[1]
circle2x <- pnt2_rd[1] + cos(ang) * mylinesdf$length[1]
circle2y <- pnt2_rd[2] + sin(ang) * mylinesdf$length[1] 
c1 <- cbind(circle1x, circle1y)
c2 <- cbind(circle2x, circle2y)

plot(c2, pch = 19, cex = 0.2, col = "red", ylim = range(circle1y, circle2y), xlim = range(circle1x, circle2x))
points(c1, pch = 19, cex = 0.2, col = "blue")
points(mypointsRD, pch = 3, col= "darkgreen")


# Iterate through some steps to create SpatialPolygonsDataFrame object
circle1 <- Polygons(list(Polygon(cbind(circle1x, circle1y))),"1")
circle2 <- Polygons(list(Polygon(cbind(circle2x, circle2y))),"2")
spcircles <- SpatialPolygons(list(circle1, circle2), proj4string=prj_string_RD)
circledat <- data.frame(mypointsRD@data, row.names=c("1", "2"))
circlesdf <- SpatialPolygonsDataFrame(spcircles, circledat)

plot(circlesdf, col = c("gray60", "gray40"))
plot(mypointsRD, add = TRUE, col="red", pch=19, cex=1.5)
plot(mylinesRD, add = TRUE, col = c("green", "yellow"), lwd=1.5)

spplot(circlesdf, zcol="Name", col.regions=c("gray60", "gray40"), 
       sp.layout=list(list("sp.points", mypointsRD, col="red", pch=19, cex=1.5), 
                      list("sp.lines", mylinesRD, lwd=1.5)))
# understand how spplot works
spplot(circlesdf, zcol="Name", col.regions=c("gray60", "gray40"))

## buffer, intersect, difference --------------------------------------------

library(rgeos)
## Expand the given geometry to include the area within the specified width with specific styling options.
buffpoint <- gBuffer(mypointsRD[1,], width=mylinesdf$length[1], quadsegs=2)
mydiff <- gDifference(circlesdf[1,], buffpoint)

plot(circlesdf[1,], col = "red")
plot(buffpoint, add = TRUE, lty = 3, lwd = 2, col = "blue")

gArea(mydiff) ## what is the area of the difference?
plot(mydiff, col = "red")

myintersection <- gIntersection(circlesdf[1,], buffpoint)
plot(myintersection, col="blue")

gArea(myintersection)
print(paste("The difference in area =", round(100 * gArea(mydiff) / 
                                                gArea(myintersection),2), "%"))