#!/usr/bin/env python

###############################################################################

# This script takes one argument: the name of a file organized in csv format:

# ara, ?, grey
# aze, alman, yellow
# bel, nyametski, blue
# bos, njemacki, blue
# ...

# which is a list of languages, list of words, and corresponding color.

# It will look for the template map 'resources/europe_template.svg' 
# and replace the names and colors with the csv's info.

# The colors can be given as hexadecimal (#ff00cc) or common English colour names.

###############################################################################

import sys
import csv
from etymap_dicts import lang_col, colorNames

try:
    filename = sys.argv[1]
except:
    filename = 'resources/dictionary_template.txt'

#load the .svg map:
with open('resources/europe_template.svg',"r") as theMap:
    
    theMapSource = theMap.read()
    
    with open(filename, "r", encoding="utf8") as theDictionary:
        reader = csv.reader(theDictionary)
        for line in reader:
            # Grabbing language, word, colour
            lang = line[0]
            try:
                word = line[1].replace('?','')
            except:
                word = ''
            try:
                color = line[2]
            except:
                color = 'grey'
                
            # Convert English col names to hex
            if color in colorNames:
                color = colorNames[color]
            
            # Original map colour to replace (all distinct)
            col = lang_col[lang]
            
            # Replace each tag in .svg ($eng etc) with the word/colour
            theMapSource=theMapSource.replace('${}'.format(lang),word)
            theMapSource=theMapSource.replace('#{}'.format(col),color)
        
        
        # Write output map
        outputMap = filename.replace('dictionary','').replace('.txt','_map.svg')
        
        with open(outputMap, 'w', encoding="utf8") as theNewMap:
            theNewMap.write(theMapSource)
