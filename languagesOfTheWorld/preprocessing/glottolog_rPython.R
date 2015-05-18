#### languoids data from Glottolog


## DATA
## use rPython to interface to Python and run glottolog data fetch script
## see: http://www.r-bloggers.com/calling-python-from-r-with-rpython/, http://www.r-bloggers.com/rpython-r-interface-to-python/
library(rPython)

## execute data fetch
python.load('glottolog_jsonfetch.py')

## convert Pandas dataframe to list
python.exec('pydict = glottoDF.to_dict(orient = "list")')

## pass Python dict to R list
r_list <- python.get('pydict')

## convert list to data.frame
r_df <- data.frame(r_list)

## combine lat:long for plotting, and tooltips text
r_df$latlong <- paste(r_df$lat, ":", r_df$lon, sep="")
r_df$tooltip <- paste(r_df$name, "<BR>", r_df$family, "<BR>", r_df$level, "<BR>", r_df$status, sep="")

## save to file
write.csv(r_df, file = '../data/glottolog_languoids-step2.csv')


## PLOTS
## googleVis map
#library(googleVis)
#glottomap <- gvisMap(r_df, "latlong", "tooltip", options = list(showTip = TRUE, showLine = TRUE, enableScrollWheel = TRUE, mapType = 'terrain', useMapTypeControl = TRUE))
#plot(glottomap)

## ggplot map
library(ggplot)
p <- ggplot(data = r_df, aes(x = lon, y = lat))
p <- p + geom_point(aes(colour = status))


# to plotly
library(devtools)
install_github("ropensci/plotly")
library(plotly)
pltly <- plotly(username="cainesap", key = "sro8ldmw6o")
pltly$ggplotly(p)


# set up separate trace for each status
statuses <- unique(r_df$status)
traces <- list()
for (st in statuses) {
    subs <- subset(r_df, status == st)
    lons <- subs$lon
    lats <- subs$lat
    ttips <- subs$tooltip
    trace <- list(x = lons, y = lats, mode = 'markers', text = ttips, type = 'scatter')
    traces[[length(traces)+1]] <- trace
}
# hide legend: https://plot.ly/~cainesap/12
#layout <- list(showlegend = FALSE)
#resp <- pltly$plotly(traces, kwargs = list(layout = layout))
# or work out way to change trace names: https://plot.ly/~cainesap/13
resp <- pltly$plotly(traces)
print(resp$url)
# add worldmap baselayer?
# facetting by family?
# zoom and pan?

# map package
mp <- ggplot() + borders('world', colour = 'gray80', fill = 'gray80') + theme_bw()
pltly$ggplotly(mp)
mpdata <- pltly$get_figure('cainesap', 14)


langmap <- pltly$get_figure('cainesap', 3)
worldmap <- pltly$get_figure('cainesap', 14)

langmap$data[[1]]$text  <- subset(r_df, status == 'Critically endangered')$tooltip
langmap$data[[2]]$text  <- subset(r_df, status == 'Definitely endangered')$tooltip
langmap$data[[3]]$text  <- subset(r_df, status == 'Extinct')$tooltip
langmap$data[[4]]$text  <- subset(r_df, status == 'Living')$tooltip
langmap$data[[5]]$text  <- subset(r_df, status == 'Severely endangered')$tooltip
langmap$data[[6]]$text  <- subset(r_df, status == 'Unknown')$tooltip
langmap$data[[7]]$text  <- subset(r_df, status == 'Vulnerable')$tooltip

#newmap <- list(langmap, worldmap)

resp <- pltly$plotly(langmap$data)
