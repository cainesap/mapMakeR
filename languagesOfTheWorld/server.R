## SERVER for Glottolog Data Explorer
## from https://github.com/hrbrmstr/ggvis-maps/blob/master/R/ggvis-maps.R
## see also http://shiny.rstudio.com/gallery/movie-explorer.html


## Required libraries; use install.packages() if needed
library(ggvis)
library(dplyr)
library(RSQLite)

library(rgdal)
library(rgeos)
library(magrittr)
library(RColorBrewer)
library(data.table)
library(maptools)


## Fetch data from database pre-populated by the 'populate_db.R' script
glottdb <- src_sqlite("glotto.sqlite3")  # db connection
#glottbl <- tbl(glottdb, "glott")  # load 'glott' table from db
glott_langs <- tbl(glottdb, "glott")  # load 'glott' table from db
#glott_langs <- filter(glottbl) %>% select(id, name, level, family, lon, lat, status)


## Fetch worldmap and convert to df
world <- readOGR("/Users/apcaines/Downloads/ne_50m_admin_0_countries.geojson", layer="OGRGeoJSON")
world <- world[!world$iso_a3 %in% c("ATA"),]
world <- spTransform(world, CRS("+proj=wintri"))
map_w <- ggplot2::fortify(world, region="iso_a3")


## Server commands, to run app in conjunction with 'ui.R'
shinyServer(function(input, output, session) {

  ## Fetch max/min lat/long for plot axes
  origdf <- as.data.frame(glott_langs)
  minx <- min(origdf$lon)
  maxx <- max(origdf$lon)
  miny <- min(origdf$lat)
  maxy <- max(origdf$lat)


  ## Filter the data, reacting according to user input
  langs <- reactive({
    # convert glott_langs object to data.frame
    g <- as.data.frame(glott_langs)

    # any language status filters, otherwise all
    if (!is.null(input$status) && input$status != "") {
      langstatus <- input$status
      g <- subset(g, status %in% langstatus)
    }

    # any language family filters, otherwise all
    if (!is.null(input$family) && input$family != "" && input$family != "[all]") {
      langfam <- input$family
      g <- subset(g, family %in% langfam)
    }

    # filter by language name, if in the input
    if (!is.null(input$langname) && input$langname != "") {
      namesearch <- paste0("%", input$langname, "%")
      g <- g %>% filter(name %like% namesearch)
    }

    # return data.frame 'g'
     coordinates(g) <- ~lon+lat
     as.data.frame(SpatialPointsDataFrame(spTransform(
     SpatialPoints(g, CRS("+proj=longlat")), CRS("+proj=wintri")),
     g@data))

  })

  ## Function for generating tooltips, used below on mouse hover
  lang_tooltip <- function(x) {
    if (is.null(x)) return(NULL)
    if (is.null(x$id)) return(NULL)
    if (grepl("[A-Z]+", x$id, perl = TRUE)) return(NULL)  # deal with country codes as id (returns empty tooltips)

    # pick out the game with this ID
    glott_langs <- isolate(langs())
    lang <- glott_langs[glott_langs$id == x$id, ]

    # the format and layout of the text in the tooltip
    paste0("<b>", lang$name, "</b><br>",
      "family: ", lang$family, "<br>",
      "status: ", lang$status, "<br>"
    )
  }

  ## Convert datapoints to correct projection
#  coordinates(langs) <- ~lon+lat
#  langs <- as.data.frame(SpatialPointsDataFrame(spTransform(
#  SpatialPoints(langs, CRS("+proj=longlat")), CRS("+proj=wintri")),
#  langs@data))

  ## Reactive visualisation using ggvis
  vis <- reactive({
#    langs %>%
#    ggvis(x = ~lon, y = ~lat) %>%
#    layer_points(size := 50, size.hover := 200,
#      fillOpacity := 0.2, fillOpacity.hover := 0.5,
#      fill = ~status, stroke = 1, key := ~id) %>%
#    add_tooltip(lang_tooltip, "hover") %>%
#    scale_numeric("x", domain = c(minx, maxx)) %>%
#    scale_numeric("y", domain = c(miny, maxy)) %>%
#    add_legend("fill") %>% hide_legend("stroke")


#     xextra <- (max(langs$lon) - min(langs$lon))*0.1
#     minxx <- min(lang$lon) - xextra
#     maxx <- max(lang$lon) + xextra
#     yextra <- (max(langs$lat) - min(langs$lat))*0.1
#     minxy <- min(lang$lat) - yextra
#     maxy <- max(lang$lat) + yextra

     map_w %>%
     group_by(group, id) %>%
     ggvis(~long, ~lat) %>%
     layer_paths(fill := "white", stroke := "#252525", strokeOpacity := 0.5, strokeWidth := 0.25) %>%
     layer_points(data = langs, x = ~lon, y = ~lat, fill = ~status, stroke = 1, size := 50,
       fillOpacity := 0.2, fillOpacity.hover := 0.5, key := ~id) %>%
     add_tooltip(lang_tooltip, "hover") %>%
#     scale_numeric("x", domain = c(minx, maxx)) %>%
#     scale_numeric("y", domain = c(miny, maxy)) %>%
     add_legend("fill") %>% hide_legend("stroke") %>%
     hide_axis("x") %>% hide_axis("y") %>%
     set_options(width=900, height=500, keep_aspect=TRUE)
  })

  ## Plot
  vis %>% bind_shiny("plot1")

  ## Number of languages in the current dataset [reactive]
  output$n_langs <- renderText({ nrow(langs()) })

})
