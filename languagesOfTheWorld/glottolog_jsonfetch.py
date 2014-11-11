## parse Glottolog JSON data
import json, urllib2


## list of resources
response = urllib2.urlopen('http://glottolog.org/resourcemap.json?rsc=language')
data = json.load(response)


## loop over all languoids, fetch jsondata, make list of dictionaries
length = len(data['resources']); print(length)  # how many items in resource list
counter = 0  # count languoids with lat/long coordinates
glotto = []  # empty list for languoid dictionaries
for n in range(0, length):
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
        languoid = {'name':name, 'id':id, 'level':type, 'family':class1, 'lon':lon, 'lat':lat, 'status':status}  # languoid dictionary
        glotto.append(languoid)  # append dict to list

print(counter)  # how many languoids with lat/long coordinates?
