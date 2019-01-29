## GLOTTOLOG DATA EXPLORER

####
## deploy to shinyapps:
# library(rsconnect)
# deployApp(appPrimaryDoc = 'gde_prod.R', appName = 'langmap')
####


## PRELIMS
require(shiny); require(leaflet); require(RColorBrewer); require(DT)

## load Glottolog data
langs <- read.csv('data/glottologLanguoids.csv')
print(paste(nrow(langs), "languoids"))
## remove Paranan-Pahanan para1320 (retired languoid: language split)
langs <- langs[-5258,]
## remove bookkeeping languoids
langs <- subset(langs, family1!="Bookkeeping")
print(paste(nrow(langs), "languoids"))

## order of language status
statusOrder <- c("extinct", "critically endangered", "severely endangered", "definitely endangered", "vulnerable", "safe")
langs$status <- factor(langs$status, levels = statusOrder)

## colours for factor levels: hybrid brew of grey, reverse red-orange-yellow, green)
brew <- c("#969696", rev(brewer.pal(6, "Reds")[4:6]), rev(brewer.pal(6, "PuRd")[3:4]), "#33a02c")
langCols <- colorFactor(brew, langs$status)

## population info from Ethnologue
ethno <- read.csv('data/ethnologue.csv', as.is=T)
colnames(ethno) <- c('ethnoName', 'iso639.3', 'speakers', 'country')
ethno$speakers <- as.numeric(ethno$speakers)
langs <- merge(langs, ethno, by="iso639.3")
langs$newtooltip <- paste0(langs$tooltip, "<br />speakers:", ifelse(is.na(langs$speakers), "unknown", formatC(langs$speakers, big.mar = ",", format = "f", digits = 0)))


## subsetting by status
#other <- subset(langs, grepl("endangered", langs$status)==FALSE)
#unknown <- subset(langs, grepl("Unknown", langs$status))
extinct <- subset(langs, grepl("extinct", langs$status))
endangered <- subset(langs, grepl("endangered", langs$status))
vulnerable <- subset(langs, grepl("vulnerable", langs$status))
safe <- subset(langs, grepl("safe", langs$status))


## SHINY APP

## user interface
ui <- shinyUI(navbarPage("Languages of the world", id="nav",

  ## main map
  tabPanel("Map",
    div(class="outer",
      tags$head(
        # include CSS
        includeCSS("css/styles.css")
      ),
      
      ## the main map
      leafletOutput("glottomap", width="100%", height="100%"),

	  ## count of languoids in view 
	  ## plus option to resize by speaker count
	  absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE, draggable = TRUE, top = "auto", left = 0, 
	    right = "auto", bottom = 0, width = 330, height = "auto",
	    tableOutput("tableInBounds"),
	    verbatimTextOutput("counter"),
	    checkboxInput("popsize", "Resize by number of speakers", FALSE)
      )
    )
  ),
  
  tabPanel("Table",
    sidebarLayout(
      sidebarPanel(
        tags$strong(tags$a(href="http://glottolog.org", target="_blank", "Source: Glottolog")),
        hr(),
        checkboxGroupInput('status', 'Endangerment status',
          rev(statusOrder), selected = rev(statusOrder)),
#        radioButtons('type', 'Type:', c('All', unique(as.character(langs$type)))),
        selectizeInput('family1', 'Language family: level 1',
		  choices = sort(unique(as.character(langs$family1))),
		  multiple = TRUE, options = list(placeholder = 'start typing or select from list', onInitialize = I('function() { this.setValue(""); }'))),
		selectizeInput('family2', 'Language family: level 2',
		  choices = NULL, multiple = TRUE, options = list(placeholder = 'start typing or select from list', onInitialize = I('function() { this.setValue(""); }'))),
        selectizeInput('family3', 'Language family: level 3',
		  choices = NULL, multiple = TRUE, options = list(placeholder = 'start typing or select from list', onInitialize = I('function() { this.setValue(""); }')))
      ),
      mainPanel(
        DT::dataTableOutput("table")
      )
    )
  ),
  
  tabPanel("About",
    navlistPanel(
      tabPanel("Language endangerment",
        includeMarkdown("about/endangerment.md")
      ),
      tabPanel("Credits",
        includeMarkdown("about/credits.md")
      ),
      tabPanel("Contact",
        includeMarkdown("about/contact.md")
      )
    )
  )
))


## server
server <- function(input, output, session) {

  ## initial world map (include circle markers to set bounds, then discard)
  output$glottomap <- renderLeaflet({
    leaflet() %>%
      #addTiles() %>%
      #addProviderTiles("NASAGIBS.ViirsEarthAtNight2012") %>%
      #addProviderTiles("Esri.NatGeoWorldMap") %>%
      addProviderTiles("Stamen.Watercolor") %>%
      addProviderTiles("Stamen.TonerLabels") %>%
      addProviderTiles("Stamen.TonerLines") %>%
      # n.b. implicit lat/long coordinates
      addCircleMarkers(data = langs, color = ~langCols(status), stroke = TRUE, weight = 3, opacity = 0.8, fillOpacity = 0.5, radius = 7, group = "other") %>%
	  clearMarkers() %>%
      addLegend("topright", pal = colorFactor(brew, langs$status), values = langs$status, opacity = 0.8, title = "Endangerment status<br/>(source: <a href=\"http://glottolog.org\" target=\"_blank\">Glottolog</a>/UNESCO)") %>%
      addLayersControl(
        overlayGroups = c("extinct", "endangered", "vulnerable", "safe"),
	options = layersControlOptions(collapsed = FALSE)
      )
  })
  
  ## watch for map zoom level (starts at 2)
  mapzoom <- reactive({
    input$glottomap_zoom
  })
  
  observe({
  	## make stroke and radius contingent on map zoom
 	req(mapzoom())
  	strokeWeight <- as.numeric(mapzoom())*0.8
  	circleRadius <- as.numeric(mapzoom())*1.5
  	popCircleRadius <- as.numeric(mapzoom())*0.5

	## if 'popsize' ticked, use speaker counts to size languoids
  	if (input$popsize) {
	  leafletProxy("glottomap") %>%
	    clearMarkers() %>%
#	    addCircleMarkers(data = unknown, color = ~langCols(status), stroke = TRUE, weight = strokeWeight, opacity = 0.5, fillOpacity = 0.4, radius = ~log(speakers)+popCircleRadius, popup = ~newtooltip, group = "unknown") %>%
        addCircleMarkers(data=safe, color = ~langCols(status), stroke = TRUE, weight = strokeWeight, opacity = 0.4, fillOpacity = 0.3, radius = ~log(speakers)+popCircleRadius, popup = ~newtooltip, group = "safe") %>%
        addCircleMarkers(data = vulnerable, color = ~langCols(status), stroke = TRUE, weight = strokeWeight, opacity = 0.5, fillOpacity = 0.4, radius = ~log(speakers)+popCircleRadius, popup = ~newtooltip, group = "vulnerable") %>%
        addCircleMarkers(data = endangered, color = ~langCols(status), stroke = TRUE, weight = strokeWeight, opacity = 0.5, fillOpacity = 0.4, radius = ~log(speakers)+popCircleRadius, popup = ~newtooltip, group = "endangered") %>%
        addCircleMarkers(data = extinct, color = ~langCols(status), stroke = TRUE, weight = strokeWeight, opacity = 0.5, fillOpacity = 0.4, radius = ~log(speakers)+popCircleRadius, popup = ~newtooltip, group = "extinct")
  	} else {  # else size proportional to zoom level
	  leafletProxy("glottomap") %>%
	    clearMarkers() %>%
#	    addCircleMarkers(data = unknown, color = ~langCols(status), stroke = TRUE, weight = strokeWeight, opacity = 0.5, fillOpacity = 0.4, radius = circleRadius, popup = ~newtooltip, group = "unknown") %>%
        addCircleMarkers(data=safe, color = ~langCols(status), stroke = TRUE, weight = strokeWeight, opacity = 0.4, fillOpacity = 0.3, radius = circleRadius, popup = ~newtooltip, group = "safe") %>%
        addCircleMarkers(data = vulnerable, color = ~langCols(status), stroke = TRUE, weight = strokeWeight, opacity = 0.5, fillOpacity = 0.4, radius = circleRadius, popup = ~newtooltip, group = "vulnerable") %>%
        addCircleMarkers(data = endangered, color = ~langCols(status), stroke = TRUE, weight = strokeWeight, opacity = 0.5, fillOpacity = 0.4, radius = circleRadius, popup = ~newtooltip, group = "endangered") %>%
        addCircleMarkers(data = extinct, color = ~langCols(status), stroke = TRUE, weight = strokeWeight, opacity = 0.5, fillOpacity = 0.4, radius = circleRadius, popup = ~newtooltip, group = "extinct")
    }
  })

  ## keep count of languoids in view
  langsInBounds <- reactive({
    if (is.null(input$glottomap_bounds))
      return(langs[FALSE,])
      bounds <- input$glottomap_bounds
      latRng <- range(bounds$north, bounds$south)
      lngRng <- range(bounds$east, bounds$west)

    subset(langs,
      lat >= latRng[1] & lat <= latRng[2] &
        long >= lngRng[1] & long <= lngRng[2])
  })

  ## print number of languoids in view
  output$counter <- renderPrint({ cat(paste(nrow(langsInBounds()), "in view")) })
  
  ## proportional status counts for reactive table
  props <- function(x) round(as.numeric(nrow(subset(langsInBounds(), status==x)) / nrow(langsInBounds()))*100, 3)
  output$tableInBounds <- renderTable({
    langprops <- unlist(lapply(rev(statusOrder), props))
    df <- data.frame(langprops, rev(statusOrder))
    colnames(df) <- c("%", "status")
    df
  })

  ## DT for Table tab
  output$table <- DT::renderDataTable({DT::datatable({
    data <- langs[, c(4, 11, 6:8)]  # select columns for DT (name, status, 3 family levels)
    if (!is.null(input$status)) {
      data <- data[data$status %in% input$status,]
    }
#    if (input$type != "All") {
#      data <- data[data$type == input$type,]
#    }
	if (length(input$family1) > 0) {
      if (length(input$family2) > 0) {
      	if (length(input$family3) > 0) {
      	  data <- data[data$family3 %in% input$family3,]
      	} else {
      	  data <- data[data$family2 %in% input$family2,]
      	  updateSelectizeInput(session, "family3", choices = sort(unique(as.character(data$family3))), server = TRUE)
      	}
      } else {
      	data <- data[data$family1 %in% input$family1,]
      	updateSelectizeInput(session, "family2", choices = sort(unique(as.character(data$family2))), server = TRUE)
      	updateSelectizeInput(session, "family3", choices = NULL, server = TRUE)
      }
    } else {
      updateSelectizeInput(session, "family2", choices = NULL, server = TRUE)
      updateSelectizeInput(session, "family3", choices = NULL, server = TRUE)
    }
    data}, rownames = FALSE, extensions = 'Buttons', options = list(orderClasses = TRUE, lengthMenu = c(10, 20, 50, 100, 1000), pageLength = 10, dom = 'lfrtipB', buttons = c('copy', 'csv', 'excel', 'pdf', 'print')))
  })
  
}



## run application
shinyApp(ui, server)






## histogram
#output$histo <- renderPlot({ggplot(data = langs, aes(x = status)) + geom_histogram(aes(fill = status)) + scale_x_discrete("") + scale_fill_manual(values = brew) + scale_y_continuous("langs") + theme_bw() + theme(legend.position = 'none', axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))})

  ## draw histogram of languoid statuses (in view)
#  output$histog <- renderPlot({
    # If no zipcodes are in view, don't plot
#    if (nrow(langsInBounds()) == 0)
#      return(NULL)
#	ggplot(data = langsInBounds(), aes(x = status)) + geom_histogram(aes(fill = status)) + scale_x_discrete("") + scale_fill_manual(values = brew) + scale_y_continuous("langs") + theme_bw() + theme(legend.position = 'none', axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
#  })


#      tags$div(id = "cite", 
#        hr()
#        tableOutput("values")
#        verbatimTextOutput("counter")
#      )
