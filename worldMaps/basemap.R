## build a basemap of the world; inspired by an R-bloggers post by Kristoffer Magnusson http://www.r-bloggers.com/working-with-shapefiles-projections-and-world-maps-in-ggplot/



### 1. FETCH & MANIPULATE DATA

## read shapefile of land polygons using rgdal's readOGR(); default projection is 'longlat'
wmap <- readOGR(dsn = "ne_110m_land", layer = "ne_110m_land")

## now do the same for graticules (the 'grid', or longitude/latitude 'webbing'), bounding box, country borders, geographic lines
grat <- readOGR("ne_110m_graticules_all", layer = "ne_110m_graticules_15") 
bbox <- readOGR("ne_110m_graticules_all", layer = "ne_110m_wgs84_bounding_box") 
countries <- readOGR("ne_110m_admin_0_countries", layer = "ne_110m_admin_0_countries")
lines <- readOGR(dsn = "ne_110m_geographic_lines", layer = "ne_110m_geographic_lines")

## convert to data frame using ggplot's fortify(); I've chosen the 'Winkel-Tripel' projection, but note you have other options (and see XKCD for what your choice says about you ;-) http://xkcd.com/977/)
## this would be the vanilla 'longlat' projection
#wmap_df <- fortify(wmap)
#grat_df <- fortify(grat)
#bbox_df<- fortify(bbox)
#countries_df <- fortify(countries)
## this would be 'Robinson'
#wmap_robin <- spTransform(wmap, CRS("+proj=robin"))
#wmap_df_robin <- fortify(wmap_robin)
#grat_robin <- spTransform(grat, CRS("+proj=robin"))  # reproject graticule
#grat_df_robin <- fortify(grat_robin)
#bbox_robin <- spTransform(bbox, CRS("+proj=robin"))  # reproject bounding box
#bbox_robin_df <- fortify(bbox_robin)
#countries_robin <- spTransform(countries, CRS("+init=ESRI:54030"))
#countries_robin_df <- fortify(countries_robin)
## 'Winkel-Tripel' projection
wmap_wintri <- spTransform(wmap, CRS("+proj=wintri"))
wmap_wintri_df <- fortify(wmap_wintri)
grat_wintri <- spTransform(grat, CRS("+proj=wintri"))
grat_wintri_df <- fortify(grat_wintri)
bbox_wintri <- spTransform(bbox, CRS("+proj=wintri"))
bbox_wintri_df <- fortify(bbox_wintri)
countries_wintri <- spTransform(countries, CRS("+proj=wintri"))
countries_wintri_df <- fortify(countries_wintri)
lines_wintri <- spTransform(lines, CRS("+proj=wintri"))
lines_wintri_df <- fortify(lines_wintri)
## exclude Intl Date Line from geographic lines [because it makes crazy paths!]
lines_wintri_nonidl <- subset(lines_wintri_df, id != "5")


### 2. BUILD PLOT

## create your ggplot 'theme' (i.e. appearance settings; see http://docs.ggplot2.org/current/theme.html); KM chooses a very plain theme with grey background (see blogpost); I've retained the lat/long axes and changed the background colour, font, removed the title .. choose your flavour!
theme_opts <- theme(
  text = element_text(family = 'Georgia', size = 14),
  panel.grid.minor = element_blank(), 
  panel.grid.major = element_blank(), 
  panel.background = element_blank(), 
  plot.background = element_rect(fill="#FCFAF4"), 
  panel.border = element_blank())


## define the plot step-by-step (no need to do it like this; see below for 'all at once' command)
# layer 1: bounding box (edge of the world!), plotted as a polygon, filled light blue, plus axis titles and tick-marks/labels
world1 <- ggplot(bbox_wintri_df, aes(long, lat, group = group)) + geom_polygon(fill = "#BEEBF7") + scale_x_continuous('longitude', breaks = c(-16396891, 0, 16396891), labels = c('-180º', '0º', '180º')) + scale_y_continuous('latitude', breaks = c(-10018754, 0, 10018754), labels = c('-90º', '0º', '90º'))
# layer 2: country shapes, border info for 177 unique IDs (countries), with lakes filled in thanks to logical T/F variable 'hole' (e.g. Caspian Sea), plotted as polygons allowing for land/lake fill colours defined by scale_fill_manual() 'values' [land first, lake second], note also omission of legend using 'guide' parameter
world2 <- world1 + geom_polygon(data = countries_wintri_df, aes(long, lat, group = group, fill = hole)) + scale_fill_manual(values = c("#D5DE9E", "#BEEBF7"), guide = "none")
# layer 3: country borders, drawn as paths
world3 <- world2 + geom_path(data = countries_wintri_df, aes(long, lat, group = group), color = "#FFFFFF", size = 0.1)
# layer 4: add graticules and geographic lines (except Intl Date Line)
world4 <- world3 + geom_path(data = grat_wintri_df, aes(long, lat, group = group, fill = NULL), linetype = 1, colour = "#C4C4BE", size = 0.1) + geom_path(data = lines_wintri_nonidl, aes(long, lat, group = group, fill = NULL), linetype = 2, colour = "#FFFFFF", size = 0.25)
# finally: ensure 1:1 ratio on x/y-axes and apply your theme choices
world5 <- world4 + coord_equal(ratio = 1) + theme_opts

## and the above as single line command:
world <- ggplot(bbox_wintri_df, aes(long, lat, group = group)) + geom_polygon(fill = "#BEEBF7") + scale_x_continuous('longitude', breaks = c(-16396891, 0, 16396891), labels = c('-180º', '0º', '180º')) + scale_y_continuous('latitude', breaks = c(-10018754, 0, 10018754), labels = c('-90º', '0º', '90º')) + geom_polygon(data = countries_wintri_df, aes(long, lat, group = group, fill = hole)) + scale_fill_manual(values = c("#D5DE9E", "#BEEBF7"), guide = "none") + geom_path(data = countries_wintri_df, aes(long, lat, group = group), color = "#FFFFFF", size = 0.1) + geom_path(data = grat_wintri_df, aes(long, lat, group = group, fill = NULL), linetype = 1, colour = "#C4C4BE", size = 0.1) + geom_path(data = lines_wintri_nonidl, aes(long, lat, group = group, fill = NULL), linetype = 2, colour = "#FFFFFF", size = 0.25) + coord_equal(ratio = 1) + theme_opts


## save to file
png(filename = 'worldmap.png', width = 1200, height = 900)
world
dev.off()
