mapMakeR
========

mapmaking in R; building on work of others [with due credit given]

#### Background
I needed to make a map with several requirements:
  - in R, using ggplot/ggmap if possible, due to familiarity;
  - map of the world with country boundaries;
  - ability to 'fill' in the countries with different colours according to given values;
I was aware of the impressive mapmaking capabilities of [ggplot2](http://ggplot2.org/) (Hadley Wickham) and [ggmap](https://sites.google.com/site/davidkahle/ggmap) (David Kahle & Hadley Wickham), which are just what's needed if you wish to plot spatial data (points, lines, heatmaps, etc) - as in the examples featured and linked to in [this R-bloggers post by Ralph](http://www.r-bloggers.com/google-maps-and-ggmap/); Or, if you wish to differentially fill country regions according to a given variable or variables, in specific well-resourced areas (data-wise) using shape files - the census tracts of Atlanta, say, as in [this post on Kevin Johnson's blog](http://www.kevjohnson.org/making-maps-in-r-part-2/) (which layers shapefile data, [described in KJ's earlier post](http://www.kevjohnson.org/making-maps-in-r/), on top of a ggmap object). But in trying to scale this latter method [ggmap base layer + shape files] up to a map of the world I encountered several issues, including:
  - firstly, how to draw a basemap of the world via ggmap (i.e. layer 1 in the ggplot/'grammar of graphics' method) [more on this below];  
  - secondly, how to inform R of the boundaries for all countries and fill those boundaries in with colour (i.e. layer 2) [more on this below];  
  - I was unaware until starting this process that 'projection' is such an important issue in mapmaking: Google, for example, may not be using the most accurate representation of the world [more on this below].
  

#### Hardware/software
The following procedure was appropriate for Mac OS X 10.9.4 (Mavericks) and [R 3.1.1](http://cran.r-project.org/bin/macosx/) ('Sock it to Me') for Mavericks as of 2014-09-10.  
_Disclaimer_: many of the issues mentioned below may be resolved in due course, in which case some or all of it may become obsolete/unnecessary/laughable; please adjust the procedure accordingly (and/or send me feedback - thanks!)  
Similarly, I welcome feedback on improving my Rscripts.


#### Procedure
* **starting point**: familiarity with [R](http://cran.r-project.org/), [ggplot2](http://ggplot2.org/) and [ggmap](https://sites.google.com/site/davidkahle/ggmap);
* install the following **packages** if need be: `install.packages(c('ggplot2', 'ggmap', 'maptools', 'maps'))`;
  - _n.b._ 'rgeos' and 'rgdal' are also needed for handling spatial data but at time of writing were not available in CRAN for R 3.1.1 (Mavericks); therefore, as resolved by Prof Brian Ripley and announced in [this message](https://stat.ethz.ch/pipermail/r-sig-mac/2014-May/010874.html) to the R-SIG-Mac mailing list, run the following to obtain packages from CRANxtras: `setRepositories(ind = c(1,6)); install.packages(c('rgeos', 'rgdal'))`;
* **map of the world**: ggmap's (`geocode()` ->) `get_map()` -> `ggmap()` functionality is awesome:
  - e.g.1: _continent_ `europe <- get_map(location = 'europe', zoom = 3, maptype = 'terrain', source = 'google', color = 'bw'); ggmap(europe, extent = 'device')`
  - e.g.2: _city_ `cambridge <- get_map(location = 'cambridge, u.k.', zoom = 12, maptype = 'roadmap', source = 'google', color = 'color'); ggmap(cambridge, extent = 'device')`
  - e.g.3: _building_ `pitpump <- get_map(location = 'pitville pump room', zoom = 18, maptype = 'hybrid', source = 'google', color = 'color'); ggmap(pitpump, extent = 'device')`
  - e.g.4: _coordinates_ `lonlat <- geocode(location = 'reykjavik', output = 'latlon'); reyk <- get_map(location = c(lonlat$lon, lonlat$lat), zoom ='auto', maptype = 'terrain', source = 'google'); ggmap(reyk, extent = 'device')`
  - **but**: you cannot obtain a world map from the Google Maps API via ggmap (lowest zoom number is 3, continent-level) and at time of writing the other map sources were out of action each for their own reason ('stamen' has been disrupted by some png->jpeg changes and will be fixed in ggmap 2.4, as explained [here](http://stackoverflow.com/questions/23488022/ggmap-stamen-watercolor-png-error) [along with a fix that did not work for me]; [open street map](http://openstreetmapdata.com/) returned a 503 to `get_map()` in R; whilst 'cloudmade maps' returned a 404 to [the URL given in the ggmap manual](http://maps.cloudmade.com) as it may have moved to subscription-only by the look of [this page](http://cloudmade.com/solutions/portals) [?]);
  - in addition, ggmap doesn't handle extreme latitudes well, according to [an R-bloggers post by Ram](http://www.r-bloggers.com/r-beginners-plotting-locations-on-to-a-world-map/);
  - **however**, Ram does reference a [StackOverflow response](http://stackoverflow.com/questions/11201997/world-map-with-ggmap/13222504#13222504) by @cbeleites explaining how to plot a world map in ggmap;
  - as the SO post says the solution involves prior download of a world map in PNG format, though [the given link to BigMap](http://openstreetmap.gryph.de/bigmap.html) is dead (fair enough: the response dates back to Nov 2012);
  - but now we know the method needed: first thing is to locate/generate a PNG world map, and my chosen method is to make the image from a shapefile, in ggplot as it happens (so in fact I don't need to re-load the basemap as a PNG but can instead carry straight on with ggplot layering); however, I've retained a modular approach so that people can load a PNG image from a different source if they prefer; more detail below...
* **Rscripts**: the scripts have been written in a modular fashion such that the various steps can be commented in or out of 'main.R'; the order is as follows:
  - 'prelims.R' loads required libraries and includes `install.packages()` commands (commented out) if needed;
  - 'datainfo.R' simply prints some statements to stdout, giving the user a list of URLs from which to download the required worldmap shapefiles from Natural Earth;
  - 'basemap.R' walks through the necessary steps to build a basemap of the world and save it in PNG format: [1] fetch and manipulate data, [2] build plot, [3] save to file;
  - 'moremap.R' shows how to add extra layers to that basemap: [a] use `geom_polygon` to fill a named country (or list of countries) with a particular colour, [b] use this method to fill Antarctica (almost-)white, [c] matching by ISO country codes, [d] named countries plotted according to a given variable, using `geom_point` to make a 'bubble plot', [e] named countries filled according to a given variable, using a defined palette of colours to indicate value, [f] fill all countries according to the 'mapcolor' variables supplied in the Natural Earth shapefiles;
  - the output of [f] is shown below.
* the above work was hugely influenced by [Kristoffer Magnusson's R-bloggers post]((http://www.r-bloggers.com/working-with-shapefiles-projections-and-world-maps-in-ggplot/));
* further detail and comments are included in each script: you'll find 'main.R' in this top-level directory and it's a good starting point; other scripts are in the 'rscripts' dir, with plots being saved to 'output'

#### Projection
A final comment on 'projection', which is the intriguing topic of how latitudes and longitudes of positions on the surface of a sphere/ellipsoid are transformed into locations on a plane. I had no idea this was such a contentious issue! (But of course it is, once you start looking at maps of the world more closely). For further info, see the [Wikipedia article](http://en.wikipedia.org/wiki/Map_projection).  
Though take note of this [**xkcd** comic](http://xkcd.com/977/) ... and this scene from [_The West Wing_](https://www.youtube.com/watch?v=n8zBC2dvERM)

![map of the world](output/worldmap_tile-all.png)
