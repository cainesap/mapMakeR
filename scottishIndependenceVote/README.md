scottishIndependenceVote
========

Map of Scottish Councils and vote counts for each in Scottish Independence Referendum, 18th September 2014.

## Contents
- `bdline_gb` dir: district_borough_unitary_region dataset from Ordnance Survey's Boundary-Line product, available for free download via [OS OpenData](http://www.ordnancesurvey.co.uk/opendata/viewer/index.html)
- `makeMap.R` script: loads shapefile and uses the [ggplot](http://ggplot2.org/) package to plot a map of Scotland, with each council filled according to its proportion of 'Yes' votes;
- `referendumResults.csv`: election counts for each council, downloaded from [City A.M.](http://www.cityam.com/1411046935/who-won-where-how-scottish-councils-voted-independence-referendum-results-map); _note that several council names were changed to match those in the OS shapefile: Aberdeen, Dundee, Glasgow require 'City' suffix; Edinburgh -> 'City of Edinburgh'; Eilean Siar -> 'Na h-Eileanan an Iar'_
- `scottishIndyRef2014.svg|.png`: plot output from the above.

## Workings
- the makeMap Rscript should be well commented; if anything's unclear, please contact me [suggested improvements welcome also].

## Room for improvement
If I could, I'd improve the following [feedback welcome]:
1. simplify the plot object, presumably by manipulation of or extraction from the OS shapefile; the level of detail is more than necessary and slows up plotting considerably [10 mins usually!]
2. add a legend for the label numbers: could not figure out a way to associate a legend with `geom_text()` either through `scales` or `guides`; [atm being added posthoc in Preview] -> `scottishIndyRef2014_annotated(-cropped).png`
3. move the Shetland Isles down into an inset box, thereby allowing more space for plotting the rest of Scotland; [not yet done but would like to use Inkscape .. import of .svg file currently causes almost immediate meltdown though, presumed link to point (1)?]
