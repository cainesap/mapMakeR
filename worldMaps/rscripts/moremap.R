## having made a basemap of the world, add further shapefile-based plot layers, inspired by an R-bloggers post by Kristoffer Magnusson http://www.r-bloggers.com/working-with-shapefiles-projections-and-world-maps-in-ggplot/



### 1. EXTRA LAYERS: named countries

## requirement was to 'fill' countries with different colours: because we've used fortify() to model the original lat/long coordinates, we need to keep referring to that spatial model (rather than using geocode() to fetch lat/long and then converting them to the new space, for example; I tried that and it doesn't work because the space is non-linear)

## let's say you have a particular country that you wish to fill distinctly from the rest of the world; my method (there may be better ones) is first to match the country name (ISO codes are preferable; more on that below), then extract the country's ID from the previously-loaded* Natural Earth countries shapefile by stepping down into the polygon object (thanks to @josh-obrien for his StackOverflow answer to @calvin-cheng's question that showed the way: http://stackoverflow.com/questions/8708681/getting-a-slots-value-of-s4-objects); we can then use that ID to subset the relevant lines of the previously-fortified* countries dataframe
## * see 'basemap.R' script; the object 'world' also comes from this script
query <- 'Brazil'
rowno <- which(countries$name==query)
ID <- countries[rowno, ]@polygons[[1]]@ID
country <- subset(countries_wintri_df, id == ID)

## add country polygon to 'world' ggplot object
newworld1 <- world + geom_polygon(data = country, aes(long, lat, group = group), fill = "#F5693B")

## incidentally, you could add a label like this
meanlong <- mean(country$long)
meanlat <- mean(country$lat)
newworld2 <- newworld1 + geom_text(data = NULL, aes(x = meanlong, y = meanlat, label = query, family = "Georgia", fontface = 3, size = 10, hjust = 0))


## or, you could loop thru a list of countries, building a dataframe of country shapes
querylist <- c('Brazil', 'Botswana', 'Belgium', 'Bangladesh')
countrysubs <- data.frame()
for (query in querylist) {
	rowno <- which(countries$name==query)
	ID <- countries[rowno, ]@polygons[[1]]@ID
	country <- subset(countries_wintri_df, id == ID)
	countrysubs <- rbind(countrysubs, country)
}
newworld3 <- world + geom_polygon(data = countrysubs, aes(long, lat, group = group), fill = "#F5693B")


## in fact, we could use this method to fill Antarctica in (almost-)white, as is normal
query <- 'Antarctica'
rowno <- which(countries$name==query)
ID <- countries[rowno, ]@polygons[[1]]@ID
antarc <- subset(countries_wintri_df, id == ID)

## add Antarctic polygon to 'world' object, redraw graticles and geographic lines
newworld <- world + geom_polygon(data = antarc, aes(long, lat, group = group), fill = "#F0FFFF") + geom_path(data = grat_wintri_df, aes(long, lat, group = group, fill = NULL), linetype = 1, colour = "#C4C4BE", size = 0.1) + geom_path(data = lines_wintri_nonidl, aes(long, lat, group = group, fill = NULL), linetype = 2, colour = "#FFFFFF", size = 0.25)

## n.b. will use this 'newworld' object as the basemap from now on, also saving it as PNG
png(filename = 'output/worldmap_antarctica.png', width = 1200, height = 900)
newworld
dev.off()



## n.b. the above method works fine if you're confident you can match the country name (note the case sensitivity) -- ok for 'Brazil', 'Belgium', etc -- but what about 'Bosnia'? Is it 'Bosnia', 'Bosnia and Herzegovina', 'Bosnia & Herzegovina'? None of these match a 'name' in the 'countries' object. Instead refer to the ISO codes (http://www.iso.org/iso/country_codes.htm, http://en.wikipedia.org/wiki/ISO_3166-1#Current_codes); you can then match by 2-letter code ('iso_a2'), 3-letter code ('iso_a3') or 3-digit numeric code ('iso_n3'), as shown below -- incidentally, Bosnia's exact name is 'Bosnia and Herz.'; who'd have known to search for that?!
iso <- '070'
rowno <- which(countries$iso_n3==iso)
ID <- countries[rowno, ]@polygons[[1]]@ID
bosnia <- subset(countries_wintri_df, id == ID)
countrysubs <- rbind(countrysubs, bosnia)




### 2. EXTRA LAYERS: named countries filled according to given variable

## now let's say you have a series of values accompanying your list of named countries (to which we'll add ISO codes, to be good, given the above discussion)


## the task is to fill these countries according to the 'count' variable

## our toy data:
ISOs <- c('076', '072', '056', '050')
values <- c(6, 2, 1, 4)
querydf <- data.frame(querylist, ISOs, values)
headers <- c("country", "iso", "count")
colnames(querydf) <- headers

## add in the Bosnia data from above
bos <- data.frame('Bosnia and Herz.', '070', 2)
colnames(bos) <- headers
querydf <- rbind(querydf, bos)

## add the IDs for these countries from the Natural Earth dataset; also calculate mean lat/long in the way used for geom_text() above, as a centrepoint for a 'bubble' plot [of course, taking the mean coordinates is a questionable approach since countries are not regular shapes; however, at this scale it's an adequate representation]
for (query in querydf$country) {
	rowno1 <- which(countries$name==query)
	ID <- countries[rowno1, ]@polygons[[1]]@ID
	rowno2 <- which(querydf$country==query)
	querydf$id[rowno2] <- ID
	subs <- subset(countrysubs, id == ID)
	long <- mean(subs$long)
	lat <- mean(subs$lat)
	querydf$long[rowno2] <- long
	querydf$lat[rowno2] <- lat
}

## now use geom_point() to add bubbles to the map at the country 'centrepoints', sized by count value, scaled on a colour gradient by count value, with a slight alpha and no legends
bubble1 <- newworld + geom_point(data = querydf, aes(long, lat, size = count, group = NULL, colour = identity(count), alpha = 0.9)) + scale_colour_gradient(low = "#F5A105", high = "#F51D05", guide = "none") + theme(legend.position = 'none')

## and with labels
bubble2 <- bubble1 + geom_text(data = querydf, aes(long, lat, group = NULL, label = country, family = "Georgia", fontface = 3, size = 4, hjust = -0.1, vjust = 0))


## or use geom_polygon() to fill the country boundaries
## merge our country df with previously constructed country coordinates df
countrymerged <- merge(countrysubs, querydf, by = "id")

## add a new layer to newworld plot, with the fill dictated by count value
newworld + geom_polygon(data = countrymerged, aes(long, lat, group = id), fill = count)
## stuck here in getting colours to vary by value: error msg "incompatible lengths for set aesthetics: fill"
# nb it works without interference from newworld baselayer
ggplot(data = countrymerged, aes(long, lat, group = group), fill = count) + geom_polygon() + scale_fill_continuous(low = "#C4C4BE", high = "#E4EBBC")
# WELL IT DID WORK (?!)


## therefore a workaround, a lot more clumsy than the usual ggplot elegance: add a new polygon to the ggplot object foreach country in your list, add the colour from a pre-defined palette

## use grDevices package to create your colour palette; options are rainbow(), heat.colors(), terrain.colors(), topo.colors(), cm.colors()
colpal1 <- heat.colors(max(querydf$count))

## build ggplot object 'nwFillSome', starting from the 'newworld' plot
nwFillSome <- newworld
for (query in querydf$country) {
	rowno1 <- which(countries$name==query)
	ID <- countries[rowno1, ]@polygons[[1]]@ID
	rowno2 <- which(querydf$country==query)
	querydf$id[rowno2] <- ID
	subs <- subset(countrysubs, id == ID)
	nwFillSome <- nwFillSome + geom_polygon(data = subs, aes(long, lat, group = id), fill = colpal1[querydf$count[rowno2]])
}

## see the resulting plot:
#nwFillSome

## n.b. it would be handy to add a legend here, but if i try, using scale_fill_discrete() or scale_fill_manual(), it interferes with the discrete scale from the basemap, re-fills the 'hole'=T/F value with colpal colours, and adds a legend with true/false values accordingly; this is where it would be handy to load the basemap as a PNG, and separate the scales, but my attempt at following the method described here fails: http://stackoverflow.com/questions/11201997/world-map-with-ggmap/13222504#13222504
# library(png); basemap <- readPNG('output/worldmap_antarctica.png'); basemap <- as.raster(apply(basemap, 2, rgb)); class(basemap) <- c('ggmap', 'raster'); ggmap(basemap)
# error message: "Error in data.frame(x = x.major, y = y.range[1]) : 
#  arguments imply differing number of rows: 0, 1"



### 3. EXTRA LAYERS: fill all countries using one of the 'mapcolor' variables in the 'countries' shapefile; i.e. $mapcolor7, $mapcolor8, $mapcolor9, $mapcolor13; I'll use $mapcolor13 in this example

## make colour palette: terrain or topographic seem the most appropriate; n = positive values (as $mapcolor13 has a -99 value for Antarctica)
colpal2 <- terrain.colors(sum(unique(countries$mapcolor13) > 0, na.rm = TRUE))
#colpal2 <- topo.colors(sum(unique(countries$mapcolor13) > 0, na.rm = TRUE))

## this time go right back to 'world2', the bounding box and axes + fill 'hole'=T/F, as the initial plot
nwFillAll <- world2

## then use same looping method as with nwFillSome, this time working through all 177 countries in 'countries_wintri_df'
allsubs <- data.frame()
for (country in countries$name) {
	rowno1 <- which(countries$name==country)
	ID <- countries[rowno1, ]@polygons[[1]]@ID
	subs1 <- subset(countries_wintri_df, id == ID)
	subs2 <- subset(subs1, hole == FALSE)  # deal with 'hole' var
	colval <- countries[rowno1, ]$mapcolor13  # get value
	if (colval > 0) {  ## if fillcolour is positive...
		fillcol <- colpal2[colval]
		nwFillAll <- nwFillAll + geom_polygon(data = subs2, aes(long, lat, group = group), fill = fillcol)
	}
	else {  ## else it is Antarctica, so another way to achieve a whitened south pole, as in 'newworld' above; n.b. $mapcolor13 is the only variable to do this
		nwFillAll <- nwFillAll + geom_polygon(data = subs2, aes(long, lat, group = group), fill = "#F0FFFF")
	}
}

## reinstate the remaining bits of the basemap: country boundaries, graticules + geographic lines, 1:1 ratio + theme options
nwFillAll <- nwFillAll + geom_path(data = countries_wintri_df, aes(long, lat, group = group), color = "#FFFFFF", size = 0.1) + geom_path(data = grat_wintri_df, aes(long, lat, group = group, fill = NULL), linetype = 1, colour = "#C4C4BE", size = 0.1) + geom_path(data = lines_wintri_nonidl, aes(long, lat, group = group, fill = NULL), linetype = 2, colour = "#FFFFFF", size = 0.25) + coord_equal(ratio = 1) + theme_opts

## and plot
#nwFillAll

## and save
png(filename = 'output/worldmap_tiled.png', width = 1200, height = 900)
nwFillAll
dev.off()


## in case the script is run from source()
print("You should now have the following plot objects: newworld1, newworld2, newworld3, newworld", "bubble1", "bubble2", "nwFillSome", "nwFillAll")
