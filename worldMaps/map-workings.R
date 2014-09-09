library(ggmap)



## simple map of Europe using ggmap: http://cran.r-project.org/web/packages/ggmap/ggmap.pdf, http://journal.r-project.org/archive/2013-1/kahle-wickham.pdf, http://www.r-bloggers.com/google-maps-and-ggmap/
europe <- get_map(location = 'europe', zoom = 3, maptype = 'terrain', source = 'google', color = 'color')
euromap <- ggmap(europe, extent = 'device')



## plot points on world map using ggplot2: http://www.r-bloggers.com/r-beginners-plotting-locations-on-to-a-world-map/
library(maptools)
library(maps)
# list of cities, fetch lat/long coordinates
visited <- c("SFO", "Chennai", "London", "Melbourne", "Johannesbury, SA")
ll.visited <- geocode(visited)
visit.x <- ll.visited$lon
visit.y <- ll.visited$lat
# create a layer of borders and prep ggplot object
mp <- NULL
mapWorld <- borders("world", colour="gray50", fill="gray50")
mp <- ggplot() + mapWorld
# layer the cities on top
mp <- mp + geom_point(aes(x=visit.x, y=visit.y) ,color="blue", size=3) 
mp



## try to do the same using ggmap, solving extreme latitudes problem: http://stackoverflow.com/questions/11201997/world-map-with-ggmap/13222504#13222504
require("ggmap")
library("png")
zoom <- 2
map <- readPNG(sprintf ("mapquest-world-%i.png", zoom))
map <- as.raster(apply(map, 2, rgb))
# cut map to what I really need
pxymin <- LonLat2XY(-180,73,zoom+8)$Y # zoom + 8 gives pixels in the big map
pxymax <- LonLat2XY(180,-60,zoom+8)$Y # this may or may not work with google zoom values
map <- map[pxymin:pxymax,]
# set bounding box
attr(map, "bb") <- data.frame(ll.lat = XY2LonLat (0, pxymax + 1, zoom+8)$lat, ll.lon = -180, ur.lat = round (XY2LonLat (0, pxymin, zoom+8)$lat), ur.lon = 180)
class(map) <- c("ggmap", "raster")
ggmap(map) + geom_point(data = data.frame (lat = runif (10, min = -60 , max = 73), lon = runif (10, min = -180, max = 180)))



## trying to figure out shape file processing: http://www.kevjohnson.org/making-maps-in-r/
euroshp <- readShapeSpatial("~/Downloads/NUTS_2010_60M_SH/data/NUTS_BN_60M_2010.shp")
eurofort <- fortify(euroshp)
euromap + geom_polygon(data = eurofort, aes(x = long, y = lat, group = group), fill = group)



## -> stamen: wait for ggmap v2.4 for png/jpeg fix
## or see: http://stackoverflow.com/questions/23488022/ggmap-stamen-watercolor-png-error
#google <- get_googlemap(location = 'europe', zoom = 3)
#bbox <- as.numeric(attr(google, 'bb'))[c(2, 1, 4, 3)]
#names(bbox) <- c('left', 'bottom', 'right', 'top')
#stamen <- get_stamenmap(bbox, zoom = 3)
#ggmap(stamen)
