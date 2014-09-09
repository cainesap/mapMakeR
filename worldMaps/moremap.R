## having made a basemap of the world, add further shapefile-based plot layers,  http://www.r-bloggers.com/working-with-shapefiles-projections-and-world-maps-in-ggplot/



### 1. EXTRA LAYERS: named countries

## requirement was to 'fill' countries with different colours: because we've used fortify() to model the original lat/long coordinates, we need to keep referring to that spatial model (rather than using geocode() to fetch lat/long and then converting them to the new space, for example; I tried that and it doesn't work because the space is non-linear)
## let's say you have a list of country names that you wish to fill distinctly from the rest of the world; my method (there may be better ones) is first to match the country name (ISO codes are preferable; more on that below), then extract the country's ID from the previously-loaded* Natural Earth countries shapefile by stepping down into the polygon object (thanks to @josh-obrien for his StackOverflow answer to @calvin-cheng's question that showed the way: http://stackoverflow.com/questions/8708681/getting-a-slots-value-of-s4-objects); we can then use that ID to subset the relevant lines of the previously-fortified* countries dataframe
## * see 'basemap.R' script; the object 'world' also comes from this script
query <- 'Brazil'
rowno <- which(countries$name==query)
ID <- countries[rowno, ]@polygons[[1]]@ID
country <- subset(countries_wintri_df, id == ID)
## add country polygon to 'world' ggplot object
newworld <- world + geom_polygon(data = country, aes(long, lat, group = group), fill = "#F5693B")
## incidentally, you could add a label like this
meanlong <- mean(country$long)
meanlat <- mean(country$lat)
newworld1 + geom_text(data = NULL, aes(x = meanlong, y = meanlat, label = query, family = "Georgia", fontface = 3, size = 10, hjust = 0))

## or, you could loop thru a list of countries, building a dataframe of country shapes
querylist <- c('Brazil', 'Botswana', 'Belgium', 'Bangladesh')
countrysubs <- data.frame()
for (query in querylist) {
	rowno <- which(countries$name==query)
	ID <- countries[rowno, ]@polygons[[1]]@ID
	country <- subset(countries_wintri_df, id == ID)
	countrysubs <- rbind(countrysubs, country)
}
newworld2 <- world + geom_polygon(data = countrysubs, aes(long, lat, group = group), fill = "#F5693B")

## in fact, we could use this method to fill Antarctica in white, as is normal
query <- 'Antarctica'
rowno <- which(countries$name==query)
ID <- countries[rowno, ]@polygons[[1]]@ID
antarc <- subset(countries_wintri_df, id == ID)
## add Antarctic polygon to 'world' object, redraw graticles and geographic lines
newworld <- world + geom_polygon(data = antarc, aes(long, lat, group = group), fill = "#FFFFFF") + geom_path(data = grat_wintri_df, aes(long, lat, group = group, fill = NULL), linetype = 1, colour = "#C4C4BE", size = 0.1) + geom_path(data = lines_wintri_nonidl, aes(long, lat, group = group, fill = NULL), linetype = 2, colour = "#F0FFFF", size = 0.25)
## n.b. will use this 'newworld' object as the basemap from now on



### 2. EXTRA LAYERS: named countries filled according to given values

## now let's say you have a series of values accompanying your list of named countries: the task is to fill these countries according to the 'heat' of their values

## our toy data:
values <- c(6, 2, 1, 4)
querydf <- data.frame(querylist, values)
colnames(querydf) <- c("country", "count")

## add the IDs for these countries from the Natural Earth dataset
for (query in querydf$country) {
	rowno <- which(countries$name==query)
	ID <- countries[rowno, ]@polygons[[1]]@ID
	querydf$id[which(querydf$country==query)] <- ID
}

## merge our country df with previously constructed country coordinates df
countrymerged <- merge(countrysubs, querydf, by = "id")
## add a new layer to newworld plot, with the fill dictated by count value
newworld + geom_polygon(data = countrymerged, aes(long, lat, group = group))


