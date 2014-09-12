## build a basemap of the world; inspired by an R-bloggers post by Kristoffer Magnusson http://www.r-bloggers.com/working-with-shapefiles-projections-and-world-maps-in-ggplot/


### here are the URLs etc for the data required by the basemap.R script

cat(paste("you need to download from the following Natural Earth Data URLs:", "http://www.naturalearthdata.com/downloads/110m-physical-vectors/110m-land/ [download 'land']", "http://www.naturalearthdata.com/downloads/110m-cultural-vectors/110m-admin-0-countries/ [download 'countries']", "http://www.naturalearthdata.com/downloads/110m-physical-vectors/110m-graticules/ [download 'all']", "http://www.naturalearthdata.com/downloads/110m-physical-vectors/ [download 'geographic lines']", sep = "\n"))

print("unzip and place in your working directory [call setwd() to change working directory], possibly in a subdirectory as I have ['naturalearthdata/']")
