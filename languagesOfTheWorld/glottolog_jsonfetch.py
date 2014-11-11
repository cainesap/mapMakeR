## parse Glottolog JSON data

import json, urllib2

## all language data
response = urllib2.urlopen('http://glottolog.org/resourcemap.json?rsc=language')
data = json.load(response)

#try:
# pretty printing of json-formatted string
#print json.dumps(data, sort_keys=True, indent=4)

# print one languoid ID
#print "first languoid ID: ", data['resources'][0]['id']

# loop over all languoids, fetch jsondata, make list of dictionaries
length = len(data['resources'])
print(length)
counter = 0
glotto = []
for n in range(0, length):
    id = data['resources'][n]['id']
    lon = data['resources'][n]['longitude']
    lat = data['resources'][n]['latitude']
    name = data['resources'][n]['name']
    if lon is not None:
        url = 'http://glottolog.org/resource/languoid/id/' + id + '.json'
        langresp = urllib2.urlopen(url)
        langdata = json.load(langresp)
        status = 'Unknown'
        if 'endangerment' in langdata['jsondata']:
            status = 'Living' if langdata['jsondata']['endangerment'] is None else langdata['jsondata']['endangerment']
        counter += 1
        print "\n-----\ncount: ", counter
        print "languoid ID: ", id
        print "languoid name: ", name
        print "latitude: ", lon
        print "longitude: ", lat
        print "status: ", status
        languoid = {'name':name, 'id':id, 'lon':lon, 'lat':lat, 'status':status}
        glotto.append(languoid)

print(counter)

#except (ValueError, KeyError, TypeError):
#    print "JSON format error"
