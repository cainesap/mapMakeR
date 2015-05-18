Languages of the World
====

Mapping [Glottolog](http://glottolog.org) data.

### Data collection

1. cd to `preprocessing` directory;
2. run `Rscript collect_glottolog_data.R`: controls `glottolog_jsonfetch.py` to fetch 'languoid' data from Glottolog API (you are collecting all 'language' resources: 7619 as of 2015-05-18; this can be changed via the URLs in `glottolog_jsonfetch.py`), saves output to csv file, makes a 2nd copy of csv file with tooltips column (this all takes a while, put the kettle on for a cuppa!);
3. run `Rscript populate_db.R`: creates SQLite database and inserts languoid data to table.


### Shiny App

- `global.R` contains global variables;
- `server.R` loads and prepares data;
- `ui.R` runs the user interface.

For more info on Shiny, see http://shiny.rstudio.com

To run locally, open R from this directory and --
```
library(shiny)
runApp()
```

To deploy to shinyapps.io, you'll need to set up and configure your shinyapps account, then --
```
library(shinyapps)
deployApp(appName = 'appname')  # default is directory name, as in: https://cainesap.shinyapps.io/languagesoftheworld
```


### Leaflet Map

1. open `leafletMap.R`;
2. copy and paste commands to R Console: opens map in default browser;
3. _work in progress!_
