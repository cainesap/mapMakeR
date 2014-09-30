## prompted by Simon Redfern's (probably casual) post on Twitter, https://twitter.com/Sim0nRedfern/status/516785006107426816, mentioning the centre of Eurasia, a quick Google search for the answer was unsuccessful. So how to calculate it?

## firstly, fetch a map of the world via the 'rworldmap' package and merge countries by 'continent' var (source: http://stackoverflow.com/a/20150341/829256)

library(rworldmap); library(rgeos)
sPDF <- getMap()
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


## all of which leads you to the following Google Map: https://www.google.co.uk/maps/place/50%C2%B001'19.8%22N+70%C2%B019'47.9%22E/@50.022154,70.32997,3z/data=!4m2!3m1!1s0x0:0x0

## N.B. the above calculations include Greenland in the continent of Eurasia
