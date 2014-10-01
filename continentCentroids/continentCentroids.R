## prompted by Simon Redfern's (probably casual) post on Twitter, https://twitter.com/Sim0nRedfern/status/516785006107426816, mentioning the centre of Eurasia, a quick Google search for the answer was unsuccessful. So how to calculate it?

## firstly, fetch a map of the world via the 'rworldmap' package and merge countries by 'continent' var (source: http://stackoverflow.com/a/20150341/829256)

library(rworldmap); library(rgeos); library(maptools)
sPDF <- getMap()

# what happens to centroid if we exclude Greenland (GL) and Iceland (IS) from 'Eurasia', per: https://twitter.com/Sim0nRedfern/status/517149762714607616 and https://twitter.com/Sim0nRedfern/status/517150243415420928
sPDF$continent[which(sPDF$ISO_A2=="GL")] <- "North America"
sPDF$continent[which(sPDF$ISO_A2=="IS")] <- "North America"

# make merged polygons by continent
cont <-
    sapply(levels(sPDF$continent),
           FUN = function(i) {
               ## Merge polygons within a continent
               poly <- gUnionCascaded(subset(sPDF, continent==i))
               ## Give each polygon a unique ID
               poly <- spChFIDs(poly, i)
               ## Make SPDF from SpatialPolygons object
               SpatialPolygonsDataFrame(poly,
                   data.frame(continent=i, row.names=i))
           },
           USE.NAMES=TRUE)
## Bind the 6 continent-level SPDFs into a single SPDF
cont <- Reduce(spRbind, cont)

## You now have a shapefile of the world organised by continent, that you can visualise like so:
data.frame(cont)
plot(cont, col=heat.colors(nrow(cont)))


## next, to calculate the centre-of-mass centroids for each continent, use gCentroid() from the 'rgeos' package (source: http://gis.stackexchange.com/a/43558)
trueCentroids = gCentroid(cont, byid = TRUE)

## and print data frame / plot map with triangles at centroids
print(trueCentroids)
plot(cont)
points(trueCentroids,pch=2)

## 1. without Greenland/Iceland adjustment, this leads you to the following Google Map: https://www.google.co.uk/maps/place/50%C2%B001'19.8%22N+70%C2%B019'47.9%22E/@50.022154,70.32997,3z/data=!4m2!3m1!1s0x0:0x0

## 2. with Greenland/Iceland adjustment, it is: https://www.google.co.uk/maps/place/47%C2%B030'49.4%22N+81%C2%B043'42.4%22E/@47.513733,81.72844,3z/data=!4m2!3m1!1s0x0:0x0