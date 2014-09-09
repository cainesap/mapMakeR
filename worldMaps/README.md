mapMakeR
========

mapmaking in R; building on work of others [with due credit given]

#### Background
I needed to make a map with several requirements:
  - in R, using ggplot/ggmap if possible, due to familiarity;
  - map of the world with country boundaries;
  - ability to 'fill' in the countries with different colours according to given values;
I was aware of the impressive mapmaking capabilities of [ggplot2](http://ggplot2.org/) (Hadley Wickham) and [ggmap](https://sites.google.com/site/davidkahle/ggmap) (David Kahle & Hadley Wickham), which are just what's needed if you wish to plot spatial data (points, lines, heatmaps, etc) - as in the examples featured and linked to in [this R-bloggers post by Ralph](http://www.r-bloggers.com/google-maps-and-ggmap/) - or if you wish to differentially colour sub-country administrative regions in specific well-resourced areas (data-wise) using shape files - the census tracts of Atlanta, say, as in [this post on Kevin Johnson's blog](http://www.kevjohnson.org/making-maps-in-r-part-2/) (which layers shapefile data, [described in an earlier post](http://www.kevjohnson.org/making-maps-in-r/), on top of a ggmap object). But in trying to scale this latter method [ggmap base layer + shape files] up to a map of the world I encountered several issues, including:  
  - how to fetch a map of the world via ggmap (i.e. layer 1 in the ggplot/'grammar of graphics' method) [more on this below];  
  - how to inform R of the boundaries for all countries (i.e. layer 2) [more on this below];  
  - it's not clear that Google is using the most accurate representation of the world [see 'projection' below].
  

#### Hardware/software
The following procedure was appropriate for Mac OS X 10.9.4 (Mavericks) and [R 3.1.1](http://cran.r-project.org/bin/macosx/) ('Sock it to Me') for Mavericks as of 2014-09-08.  
_Disclaimer_: many of the issues mentioned below may be resolved in due course, in which case some or all of the below may become obsolete/unnecessary/risible; please adjust the procedure accordingly (and/or send me feedback - thanks!)


#### Procedure
* **starting point**: familiarity with [R](http://cran.r-project.org/), [ggplot2](http://ggplot2.org/) and [ggmap](https://sites.google.com/site/davidkahle/ggmap);
* install the following **packages** if need be: `install.packages(c('ggplot2', 'ggmap', 'maptools', 'maps'))`;
  - _n.b._ 'rgeos' and 'rgdal' are also needed for handling spatial data but at time of writing were not available in CRAN for R 3.1.1 (Mavericks); therefore, as resolved by Prof Brian Ripley and announced in [this message](https://stat.ethz.ch/pipermail/r-sig-mac/2014-May/010874.html) to the R-SIG-Mac mailing list, run the following to obtain packages from CRANxtras: `setRepositories(ind = c(1,6)); install.packages(c('rgeos', 'rgdal'))`;
* **map of the world**: ggmap's (`geocode()` ->) `get_map()` -> `ggmap()` functionality is awesome:
  - e.g.1: _continent_ `europe <- get_map(location = 'europe', zoom = 3, maptype = 'terrain', source = 'google', color = 'bw'); ggmap(europe, extent = 'device')`
  - e.g.2: _city_ `cambridge <- get_map(location = 'cambridge, u.k.', zoom = 12, maptype = 'roadmap', source = 'google', color = 'color'); ggmap(cambridge, extent = 'device')`
  - e.g.3: _building_ `pitpump <- get_map(location = 'pitville pump room', zoom = 18, maptype = 'hybrid', source = 'google', color = 'color'); ggmap(pitpump, extent = 'device')`
  - e.g.4: _coordinates_ `lonlat <- geocode(location = 'reykjavik', output = 'latlon'); reyk <- get_map(location = c(lonlat$lon, lonlat$lat), zoom ='auto', maptype = 'terrain', source = 'google'); ggmap(reyk, extent = 'device')`
  - **but**: you cannot obtain a world map from the Google Maps API via ggmap (lowest zoom number is 3, continent-level, after all) and at time of writing the other sources were each out of action for various reasons ('stamen' has been disrupted by some png->jpeg changes and will be fixed in ggmap 2.4, as explained [here](http://stackoverflow.com/questions/23488022/ggmap-stamen-watercolor-png-error) along with a fix that did not work for me; [open street map](http://openstreetmapdata.com/) returned a 503 to `get_map()` in R; whilst 'cloudmade maps' returned a 404 to [the URL given in the ggmap manual](http://maps.cloudmade.com) as it may have moved to subscription only by the look of [this page](http://cloudmade.com/solutions/portals) (?));
  - in addition, ggmap doesn't handle extreme latitudes well, according to [this R-bloggers post by Ram](http://www.r-bloggers.com/r-beginners-plotting-locations-on-to-a-world-map/), which references a [StackOverflow response](http://stackoverflow.com/questions/11201997/world-map-with-ggmap/13222504#13222504) by @cbeleites explaining how to plot a world map in ggmap;
  - as the SO post says the solution involves prior download of a world map in PNG format, though [the given link to BigMap](http://openstreetmap.gryph.de/bigmap.html) is dead (fair enough: the response dates back to Nov 2012);
  - but now we know the method needed: first thing is to locate/generate a PNG world map, and my chosen method is to make the image from a shapefile, as described below...
* [R-bloggers post by Kristoffer Magnusson](http://www.r-bloggers.com/working-with-shapefiles-projections-and-world-maps-in-ggplot/)
* [XKCD](http://xkcd.com/977/)
