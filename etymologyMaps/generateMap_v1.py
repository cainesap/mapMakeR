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
    
    #read the dictionary:
    languages = []
    words     = []
    colors    = []
    
    with open(filename, "r", encoding="utf8") as theDictionary:
        reader = csv.reader(theDictionary)
        for line in reader:
            languages.append( line[0] )
            try:
                words.append( line[1].replace('?',''))
            except:
                words.append( '' )
            try:
                colors.append( line[2] )
            except:
                colors.append( 'grey' )
        
        # Convert English col names to hex
        for i, col in enumerate(colors):
            if col in colorNames:
                colors[i] = colorNames[col]
        
        # Replace each tag in .svg ($eng etc) with the word/colour
        for i,lang in enumerate(languages):
            #print('Language: {} - word: {} - color: {}'.format(lang,words[i],colors[i]))
            #replace the word:
            theMapSource=theMapSource.replace('${}'.format(lang),words[i])
            #replace the color:
            col = lang_col[lang]
            theMapSource=theMapSource.replace('#{}'.format(col),colors[i])
        
        
        # Write output map
        outputMap = filename.replace('dictionary','map').replace('.txt','.svg')
        
        with open(outputMap, 'w', encoding="utf8") as theNewMap:
            theNewMap.write(theMapSource)
