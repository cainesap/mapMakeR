#### languoids data from Glottolog


## DATA
## use rPython to interface to Python and run glottolog data fetch script
## see: http://www.r-bloggers.com/calling-python-from-r-with-rpython/, http://www.r-bloggers.com/rpython-r-interface-to-python/
library(rPython)

## execute data fetch
python.load('glottolog_jsonfetch.py')

## convert Pandas dataframe to list
python.exec('pydict = glottoDF.to_dict(outtype = "list")')

## pass Python dict to R list
r_list <- python.get('pydict')

## convert list to data.frame
r_df <- data.frame(r_list)

## combine lat:long for plotting, and tooltips text
r_df$latlong <- paste(r_df$lat, ":", r_df$lon, sep="")
r_df$tooltip <- paste(r_df$name, "<BR>", r_df$family, "<BR>", r_df$level, "<BR>", r_df$status, sep="")

## save to file
write.csv(r_df, file = '../data/glottolog_languoids-step2.csv')
