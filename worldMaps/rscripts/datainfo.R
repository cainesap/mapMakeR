## build a basemap of the world; inspired by an R-bloggers post by Kristoffer Magnusson http://www.r-bloggers.com/working-with-shapefiles-projections-and-world-maps-in-ggplot/


### here are the URLs etc for the data required by the basemap.R script

cat(paste("You need to download from the following Natural Earth Data URLs:", "http://www.naturalearthdata.com/downloads/110m-physical-vectors/110m-land/ [download 'land']", "http://www.naturalearthdata.com/downloads/110m-cultural-vectors/110m-admin-0-countries/ [download 'countries']", "http://www.naturalearthdata.com/downloads/110m-physical-vectors/110m-graticules/ [download 'all']", "http://www.naturalearthdata.com/downloads/110m-physical-vectors/ [download 'geographic lines']", sep = "\n"))

print("Unzip and place in your 'mapMakeR/worldmaps' directory")

## wait for user input to confirm data is ready
cat("Press [enter] to continue")
line <- readline()
