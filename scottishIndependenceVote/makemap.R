## make a map of Scottish councils, with gradient fill according to proportional yes/no vote in Scottish Independence Referendum 2014



### [0] PRELIMINARIES
## install packages if necessary
# install.packages('ggplot2', 'ggmap', 'maptools', 'maps', 'RColorBrewer', 'scales')
# setRepositories(ind = c(1,6)); install.packages(c('rgeos', 'rgdal'))  # downloads packages from CRANxtras as provided by Prof Brian Ripley for Mac Mavericks OS [see https://stat.ethz.ch/pipermail/r-sig-mac/2014-May/010874.html]

## load packages
library(ggplot2); library(ggmap); library(maptools); library(maps); library(rgeos); library(rgdal); library(grDevices); library(RColorBrewer); library(scales)

## change working directory
setwd("~/Dropbox/workspace/gitHub/mapMakeR/scottishIndependenceVote/")



### [1] FETCH & MANIPULATE DATA

## read Boundary Lines shapefile downloaded from Ordnance Survey OpenData: http://www.ordnancesurvey.co.uk/opendata/viewer/index.html
osmap <- readOGR(dsn = "bdline_gb", layer = "district_borough_unitary_region")
osmap_transf <- spTransform(osmap, CRS("+proj=tmerc"))
osmap_df <- fortify(osmap_transf)


## election data from City A.M. website http://www.cityam.com/1411046935/who-won-where-how-scottish-councils-voted-independence-referendum-results-map; n.b. with some name replacements to match OS Council names [see README]
results <- read.csv("scotIndyRefResults.csv")

## match each council to shapefile data and build a 'scotland' data frame
councils <- results$Council.area
scotland <- data.frame()
for (council in councils){
	## build df subset
	shpno <- which(osmap$NAME == council)
	dfID <- shpno - 1  # minus one from shapefile rowno
	counshp <- subset(osmap_df, id == dfID)
	scotland <- rbind(scotland, counshp)
	## add id to results.csv
	rowno <- which(results$Council.area == council)
	results$id[rowno] <- dfID
	## get label point values from shpfile
	longlat <- osmap_transf@polygons[[shpno]]@labpt
	results$long[rowno] <- longlat[1]
	results$lat[rowno] <- longlat[2]
}
results$Voters <- results$Yes + results$No
print(results)



### [2] MAKE PLOT

## set 'theme' options for ggplot
theme_opts <- theme(
  text = element_text(family = 'Georgia', size = 14),
  panel.grid.minor = element_blank(), 
  panel.grid.major = element_blank(), 
  panel.background = element_blank(), 
  plot.background = element_blank(),
  axis.line = element_blank(),
  axis.text.x = element_blank(),
  axis.text.y = element_blank(),
  axis.ticks = element_blank(),
  axis.title.x = element_blank(),
  axis.title.y = element_blank(),
  plot.background = element_rect(fill="#FFFFFF"), 
  panel.border = element_blank())

## vote values & colour palette
## we'll use the max number of colours for a sequential Brewer scale (9) though first making 8 'YESunits' to 'bin' the yes vote values with the appropriate palette colour
cols <- 8
maxYES <- max(results$Yes..)
minYES <- min(results$Yes..)
YESunit <- (maxYES - minYES) / cols
colpal <- brewer.pal(cols + 1, 'Reds')

## basemap of country borders
scotmap <- ggplot(data = scotland, aes(x = long, y = lat, group = group)) + geom_path(color = "#F0FFFF", size = 0.1)

## for each council, subset the data frame and add a geom_polygon to 'scotmap' object
for (ID in results$id) {
	## subset scotland data frame and reduce to hole=T only
	rowno <- which(results$id == ID)
	council <- results$Council.area[rowno]
	counshp1 <- subset(scotland, id == ID)
	counshp2 <- subset(counshp1, hole == FALSE)
	## identify fill colour based on 'Yes..' (proportion of yes votes); number of YESunits from minimum plus 1, to nearest integer (i.e. min = 1, max = 9)
	YES <- results$Yes..[rowno]
	councol <- round((YES - minYES) / YESunit) + 1
	counpal <- colpal[councol]
	## print info line to console and add to 'scotmap'
	print(paste(council, ID, YES, counpal))
	scotmap <- scotmap + geom_polygon(data = counshp2, aes(x = long, y = lat, group = group), fill = counpal)
}

## final plot bits
scotmap <- scotmap + geom_text(data = results, aes(x = long, y = lat, label = Council.area, group = NULL, family = "Georgia", size = 10)) + geom_point(data = results, aes(x = long, y = lat, group = NULL, size = Voters, colour = Turnout)) + scale_colour_gradient(low = "#A5C1F2", high = "#0A5EF0") + scale_size_area(labels = comma) + coord_equal(ratio = 1) + theme_opts

## render in console / save to file; WARNING: plotting takes a long time! [approx 10mins on my machine; iMac 2.7GHz, 8GB mem; probably a way to simplify the shapefiles, please get back to me if so]
system.time(print(scotmap))

png(filename = 'scottishIndyRef2014.png', width = 1200, height = 900)
scotmap
dev.off()

svg(filename = 'scottishIndyRef2014.svg')
scotmap
dev.off()


## test area
#ggplot(data = counshp2, aes(x = long, y = lat, group = group), fill = counpal) + geom_polygon() + geom_point(data = results, aes(x = long, y = lat, group = NULL, size = Voters, colour = Turnout)) + scale_colour_gradient(low = "#A5C1F2", high = "#0A5EF0") + scale_size_area(labels = comma) + coord_equal(ratio = 1) + theme_opts
