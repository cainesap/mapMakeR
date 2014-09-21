scottishIndependenceVote
========

Map of Scottish Councils and vote counts for each in Scottish Independence Referendum, 18th September 2014.

## Contents
- `bdline_gb` dir: district_borough_unitary_region dataset from Ordnance Survey's Boundary-Line product, available for free download via [OS OpenData](http://www.ordnancesurvey.co.uk/opendata/viewer/index.html)
- `makeMap.R` script: loads shapefile and uses the [ggplot](http://ggplot2.org/) package to plot a map of Scotland, with each council filled according to its proportion of 'Yes' votes;
- `scotIndyRefResults.csv`: election counts for each council, downloaded from [City A.M.](http://www.cityam.com/1411046935/who-won-where-how-scottish-councils-voted-independence-referendum-results-map); _note that several council names were changed to match those in the OS shapefile: Aberdeen, Dundee, Glasgow require 'City' suffix; Edinburgh -> 'City of Edinburgh'; Eilean Siar -> 'Na h-Eileanan an Iar'_

## Workings
- the makeMap Rscript should be well commented; if anything's unclear, please contact me [suggested improvements welcome also].
