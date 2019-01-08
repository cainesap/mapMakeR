## parse Glottolog JSON data

## PRELIMS
# libs
import json, urllib2
import pandas as pd

# vars
withgeoCount = 0  # count languoids with lat/long coordinates
nongeoCount = 0  # count languoids without lat/long coordinates
maxclass = 0  # what's the longest classification?
NONGEOs = []; IDs = []; NAMEs = []; TYPEs = []; CLASS1s = []; CLASS2s = []; CLASS3s = []; LONGs = []; LATs = []; STATUSes = []; TTIPs = []; ISOs = []  # empty lists for data

## procedure for those languoids with geo-coordinates
def withlatlong(langID, lon, lat, name, langdata, langtype, withgeoCount, maxclass):
    withgeoCount += 1
    langstatus = langdata['status']
#    langstatus = 'Unknown'  # default endangerment level: find out if info exists
#    if 'endangerment' in langdata['jsondata']:
#        langstatus = 'Living' if langdata['jsondata']['endangerment'] is None else langdata['jsondata']['endangerment']
    class1 = 'Unknown'  # take the 1st language family classification, if any found
    if len(langdata['classification']) > 0:
        class1 = langdata['classification'][0]['name']
    classlist = 'family:' + class1  # start class list for tooltip
    class2 = '-'  # and the 2nd, if found
    if len(langdata['classification']) > 1:
        class2 = langdata['classification'][1]['name']
        classlist += ',' + class2
    class3 = '-'  # and the 3rd, if found
    if len(langdata['classification']) > 2:
        class3 = langdata['classification'][2]['name']
        classlist += ',' + class3
    if len(langdata['classification']) > maxclass:
        maxclass = len(langdata['classification'])
    if 'iso639-3' in langdata:
        iso = langdata['iso639-3']
    else:
        iso = 'none'
    tooltip = "<strong><a href=\"http://glottolog.org/resource/languoid/id/" + langID + "\" target=\"_blank\">" + name + "</a></strong><br />" + classlist + "<br />type:<em>" + langtype + "</em><br />status:<em>" + langstatus + "</em>"
    print "withgeo: ", withgeoCount, name, langtype, iso
    print "family: ", class1, class2, class3
    print "lat/long: ", lon, lat; print "status: ", langstatus
    IDs.append(langID); NAMEs.append(name); TYPEs.append(langtype); CLASS1s.append(class1); CLASS2s.append(class2); CLASS3s.append(class3); LONGs.append(lon); LATs.append(lat); STATUSes.append(langstatus); TTIPs.append(tooltip); ISOs.append(iso)  # build lists
    return withgeoCount, maxclass

## and for those without geo-coordinates
def nonlatlong(nongeoCount, langID, name, langtype):
    nongeoCount += 1
    NONGEOs.append(langtype)
    print "nongeo: ", nongeoCount, name, langtype
    return nongeoCount

## closing print actions
def finishUp():
    print "\n-----\n-----\nLanguoids with geo-coords: ", withgeoCount  # how many languoids with lat/long coordinates?
    print "\n-----\n-----\nLanguoids w/o geo-coords: ", nongeoCount  # how many languoids without lat/long coordinates?
    from collections import Counter
    print(Counter(NONGEOs))
    print "\n-----\n-----\nMax classification: ", maxclass  # languoid with longest classification?

    ## merge vectors and convert to dataframe
    ## Pandas commands from: http://nbviewer.ipython.org/urls/bitbucket.org/hrojas/learn-pandas/raw/master/lessons/01%20-%20Lesson.ipynb
    glottoData = zip(IDs, ISOs, NAMEs, TYPEs, CLASS1s, CLASS2s, CLASS3s, LONGs, LATs, STATUSes, TTIPs)
    glottoDF = pd.DataFrame(data = glottoData, columns = ['id', 'iso639-3', 'name', 'type', 'family1', 'family2', 'family3', 'long', 'lat', 'status', 'tooltip'])

    ## export to csv
    glottoDF.to_csv('shinyApp/data/glottologLanguoids.csv', encoding='utf-8')



## MAIN

## [1] list of Glottolog language resources (save to file)
response = urllib2.urlopen('http://glottolog.org/resourcemap.json?rsc=language')
data = json.load(response)
with open('glottologResourceMap.json', 'w') as outfile:
    json.dump(data, outfile)
outfile.close()

## [2] loop over all languoids, fetch jsondata, make list of dictionaries
nres = len(data['resources'])
print "\n-----\nNumber of rows in resources list: ", nres
for n in range(0, nres):
    langID = data['resources'][n]['id']
    lon = data['resources'][n]['longitude']
    lat = data['resources'][n]['latitude']
    name = data['resources'][n]['name']
    url = 'http://glottolog.org/resource/languoid/id/' + langID + '.json'  # now fetch languoid specific data
    langresp = urllib2.urlopen(url)
    langdata = json.load(langresp)
    langtype = langdata['level']  # 'language' or other?
    print "\n-----\nlanguoid ID: ", langID
    if lon is not None:
        (withgeoCount, maxclass) = withlatlong(langID, lon, lat, name, langdata, langtype, withgeoCount, maxclass)  # only those resources for which there are lat/long coordinates
    else:
        nongeoCount = nonlatlong(nongeoCount, langID, name, langtype)  # interested in non-lat/long languoids?

## [3] the end: print statements and print to file
finishUp()
