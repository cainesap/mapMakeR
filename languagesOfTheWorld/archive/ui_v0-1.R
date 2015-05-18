## UI for Glottolog Data Explorer
## from 
## see also 


## Required library; use install.packages() if necessary
library(ggvis)


## Javascript for the dropdown menu
actionLink <- function(inputId, ...) {
  tags$a(href='javascript:void',
         id=inputId,
         class='action-button',
         ...)
}


## UI
shinyUI(fluidPage(

  ## TITLE
  titlePanel("Glottolog Data Explorer"),

  ## NEW ROW
  fluidRow(

    ## LH COLUMN
    column(3,

      ## AXIS CHOICES

      ## FILTERS PANEL
      wellPanel(
        h4("Filters"),
        checkboxGroupInput("status", label = "language status",
	  choices = list("living" = "Living", "vulnerable" = "Vulnerable", "critically endangered" = "Critically endangered",
	  "definitely endangered" = "Definitely endangered", "severely endangered" = "Severely endangered",
	  "extinct" = "Extinct", "unknown" = "Unknown")),
	selectInput("family", "language famil(y|ies)", famvars, selected = '[all]')
#        checkboxGroupInput("family", label = "language family",
#	  choices = list("Austronesian" = "Austronesian"))
      )
    ),

    ## RH COLUMN
    column(9,

      ## INFO PANEL
      wellPanel(
        span("Number of languages selected:", textOutput("n_langs"),
        tags$small(paste0(
          "There are a total of 7428 languages in this dataset."))
        )
      ),

      ## PLOTS PANEL
      ggvisOutput("plot1"),
      wellPanel(
        textInput("langname", "Name contains (e.g. Arabic, Chinese, Swahili, Yoruba)")
      ),

      wellPanel(
        span(
  	  "inspiration: ", tags$a(href="http://fivethirtyeight.com/features/designing-the-best-board-game-on-the-planet/", "@ollie on FiveThirtyEight"),
	  " | ",
  	  "data source: ", tags$a(href="https://github.com/rasmusgreve/BoardGameGeek", "@rasmusgreve on GitHub"),
	  " | ",
  	  "code: ", tags$a(href="https://github.com/cainesap/boardgamegeek", "@cainesap on GitHub"),
	  " | ",
	  "original design: ", tags$a(href="http://shiny.rstudio.com/gallery/movie-explorer.html", "@garrettgman's Shiny Movie Explorer")
        )
      )

    )
  )
))
