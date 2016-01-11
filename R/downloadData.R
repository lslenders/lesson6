## Jason Davis& Lieven Slenders
## Assignment Lesson 6 
## 11-1-2016


#---------------------------------------------------------
## reading spatial vector data ---------------------------
#---------------------------------------------------------


library(rgdal)


# for help -> ?readOGR
# dsn = Data Source Name
dsn = file.path("data","route.kml")
ogrListLayers(dsn)    # to to read out the shp into spatial object.
myroute <- readOGR(dsn, layer = ogrListLayers(dsn))


## [ still working on: stopped here]
# put both in single data frame
proj4string(myroute) <- prj_string_WGS
names(myroute)
myroute$Description <- NULL # delete Description
mylinesdf <- rbind(mylinesdf, myroute)

# explore... 
mylinesdf
plot(mylinesdf)
spplot(mylinesdf)
