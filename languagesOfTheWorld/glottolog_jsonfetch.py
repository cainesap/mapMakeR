## parse Glottolog JSON data
import json, urllib2
import pandas as pd

## list of resources
response = urllib2.urlopen('http://glottolog.org/resourcemap.json?rsc=language')
data = json.load(response)


## loop over all languoids, fetch jsondata, make list of dictionaries
nres = len(data['resources'])
print "\n-----\nNumber of rows in resources list: ", nres
counter = 0  # count languoids with lat/long coordinates
#glotto = []  # empty list for languoid dictionaries
IDs = []; NAMEs = []; TYPEs = []; CLASSes = []; LONs = []; LATs = []; STATUSes = []  # empty lists for data
for n in range(0, nres):
    id = data['resources'][n]['id']
    lon = data['resources'][n]['longitude']
    lat = data['resources'][n]['latitude']
    name = data['resources'][n]['name']
    if lon is not None:  # only those resources for which there are lat/long coordinates
        url = 'http://glottolog.org/resource/languoid/id/' + id + '.json'  # now fetch languoid specific data
        langresp = urllib2.urlopen(url)
        langdata = json.load(langresp)
        type = langdata['level']  # 'language' or other?
        status = 'Unknown'  # default endangerment level: find out if info exists
        if 'endangerment' in langdata['jsondata']:
            status = 'Living' if langdata['jsondata']['endangerment'] is None else langdata['jsondata']['endangerment']
        class1 = 'Missing'  # take the first language family classification, if any found
        if len(langdata['classification']) > 0:
            class1 = langdata['classification'][0]['name']
        counter += 1
        print "\n-----\ncount: ", counter
        print "languoid ID: ", id
        print "languoid name: ", name
        print "languoid type: ", type
        print "languoid family: ", class1
        print "latitude: ", lon
        print "longitude: ", lat
        print "status: ", status
        IDs.append(id); NAMEs.append(name); TYPEs.append(type); CLASSes.append(class1); LONs.append(lon); LATs.append(lat); STATUSes.append(status)  # build lists

## check languoid count
print "\n-----\n-----\nTOTAL languoids: ", counter  # how many languoids with lat/long coordinates?

## merge vectors and convert to dataframe
## Pandas commands from: http://nbviewer.ipython.org/urls/bitbucket.org/hrojas/learn-pandas/raw/master/lessons/01%20-%20Lesson.ipynb
glottoData = zip(IDs, NAMEs, TYPEs, CLASSes, LONs, LATs, STATUSes)
glottoDF = pd.DataFrame(data = glottoData, columns = ['id', 'name', 'level', 'family', 'lon', 'lat', 'status'])

## export to csv
glottoDF.to_csv('glottolog_languoids-step1.csv', encoding='utf-8')


## check resources without lat/long coordinates:
#nonlatlong()  # interested in non-lat/long languoids?
def nonlatlong():
    for n in range(0, nres):
        id = data['resources'][n]['id']
        lon = data['resources'][n]['longitude']
        name = data['resources'][n]['name']
        if lon == None:
            url = 'http://glottolog.org/resource/languoid/id/' + id + '.json'  # now fetch languoid specific data
            langresp = urllib2.urlopen(url)
            langdata = json.load(langresp)
            if langdata['level'] == None:
                print "name: ", name
                print "level: none supplied"
            elif langdata['level'] != 'dialect':
                print "name: ", name
                print "level: ", langdata['level']
                status = 'unknown'  # default endangerment level: find out if info exists
                if 'endangerment' in langdata['jsondata']:
                    status = 'unknown' if langdata['jsondata']['endangerment'] is None else langdata['jsondata']['endangerment']
                print "status: ", status
            elif langdata['level'] == 'dialect':
#                print "name: ", name
#                print "level: ", langdata['level']
                continue
            else:
                print "name: ", name
                print "level: unknown"
