library(leaflet)

m = leaflet() %>% addTiles()

langs <- read.csv('data/glottolog_languoids-step2.csv')

cols <- rainbow(length(levels(langs$status)), alpha = NULL)
langs$colours <- cols[unclass(langs$status)]

m %>% addCircles(data = langs, lat = ~ lat, lng = ~ lon, color = ~ colours)
