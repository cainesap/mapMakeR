library(leaflet)

m = leaflet() %>% addTiles()

#setwd('~/Dropbox/workspace/gitHub/mapMakeR/languagesOfTheWorld/')

langs <- read.csv('glottolog_languoids-step2.csv')

cols <- rainbow(length(levels(langs$status)), alpha = NULL)
langs$colours <- cols[unclass(langs$status)]

m %>% addCircles(data = langs, lat = ~ lat, lng = ~ lon, color = ~ colours)
