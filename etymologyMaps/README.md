Etymology Maps
========

Python script and resources to generate etymology maps per the ['etymology maps' subreddit](http://www.reddit.com/r/etymologymaps/).

### Contents:
- `Archive`: original Python mapmaking script plus unused files from the [Wiki Utilities](http://www.reddit.com/r/etymologymaps/wiki/index) provided by reddit user [/u/Quoar](http://www.reddit.com/user/Quoar) [update 2014-09-25: the directory appears to have been taken down from [the given link](http://cantat.free.fr/a/languagemap/)];
- `elephant`: dictionary and outputs for my first etymology map on 'elephant';
- `resources`: dictionary template, language codes dictionary, map template;
- `generateMap_v1.py`: my adaptation of Python script written by reddit user [/u/Quoar](http://www.reddit.com/user/Quoar).

### Procedure:
1. make a new directory for your map, i.e. `$ mkdir [yourword]`;
2. make a copy of the `dictionary_template.txt` from the `resources` dir;
3. replace word forms for each language for the word of interest (language codes defined in `resources/language_codes_dictionary.txt`);
4. define fill colours grouped according to etymological stories (colour key/value pairs contained in the Python script);
5. run `$ python generateMap_v1.py [yourword]/dictionary_[yourword].txt`;
6. open the .svg output from `[yourword]/map_[yourword].svg` in [Inkscape](http://www.inkscape.org/en/) or other graphics software;
7. annotate with a title, legend and etymological explanations (best to save as a different filename);
8. export as .png or other image format;
9. upload to [Imgur](http://imgur.com/) and submit link to ['etymology maps' subreddit](http://www.reddit.com/r/etymologymaps/).
