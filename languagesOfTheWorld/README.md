boardgamegeek
====

Interactive Shiny app to explore BoardGameGeek data.

Data source: https://github.com/rasmusgreve/BoardGameGeek

Inspiration: http://fivethirtyeight.com/features/designing-the-best-board-game-on-the-planet/

## Contents
- `bgg.sqlite3`: BoardGameGeek data as an SQLite database;
- `boardgamegeek.csv`: download of [`data_w_right_ratings2014-05-02.csv`](https://github.com/rasmusgreve/BoardGameGeek/blob/master/BoardGameGeek/data_w_right_ratings2014-05-02.csv) from @rasmusgreve's GitHub repo;
- `global.R`: global axis variables;
- `populate_db.R`: data pre-processing to convert .csv to .sqlite3;
- `server.R`: works with `ui.R` to define Shiny app;
- `ui.R`: works with `server.R` to define Shiny app.

To run locally, change to the boardgamegeek directory and --
```
library(shiny)
runApp()
```

To deploy to shinyapps.io, you'll need to set up and configure your shinyapps account, then --
```
library(shinyapps)
deployApp()
```
As in: https://cainesap.shinyapps.io/boardgamegeek