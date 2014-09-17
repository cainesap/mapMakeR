## START HERE

## comment these in or out as you wish/need
## n.b. assumes scripts are in 'rscripts' dir and existence of an 'output' dir for saving plots

setwd('.../mapMakeR/worldmaps')  # change working directory to worldmaps (same level as shapefile data)

source('rscripts/prelims.R')  # install packages (commented out) and load libraries
source('rscripts/datainfo.R') # prints URLs required for basemap script
source('rscripts/basemap.R')  ## [ these two scripts could be combined
#source('rscripts/moremap.R')  ## [ but it's unlikely you'd run 'moremap' without manual tinkering, hence it's separated from 'basemap' and commented out as a default
