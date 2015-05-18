## Exploring Glottolog with Python
## from: http://nbviewer.ipython.org/gist/xflr6/9050337/glottolog.ipynb
## via: Robert Forkel <robert_forkel@eva.mpg.de>
import urllib

## Download the RDF export file with Pythons built-in urllib module (docs).
URL = 'http://glottolog.org/static/download/glottolog-language.n3.gz'
filename, headers = urllib.urlretrieve(URL, URL.rpartition('/')[2])

## Load the whole file uncompressed into memory.
#import gzip
#with gzip.open(filename) as fd:
#    data = fd.read()

## Use rdflib (docs) to load the whole graph into memory; This will take a while and fill a couple hundred megabytes of RAM
import rdflib
graph = rdflib.Graph()

with gzip.open(filename) as fd:
    graph.parse(fd, format='n3')

## Querying with RDF query language SPARQL: a SPARQL query that retrieves most of the functional properties of the languoids.
LANGUOIDS = '''
SELECT
  (substr(str(?s), 43) AS ?id) ?label
  (substr(str(?type), 34) AS ?level)
  (substr(str(?broader), 43) AS ?parent)
  (if(bound(?change_note), 1, 0) AS ?obsolete)
  ?status ?iso639 ?latitude ?longitude
WHERE
  { ?s a dcterms:LinguisticSystem ; skos:prefLabel ?label .
    ?s a ?type FILTER (strstarts(str(?type), "http://purl.org/linguistics/gold/"))
    OPTIONAL { ?s skos:broader ?broader }
    OPTIONAL { ?s skos:changeNote ?change_note FILTER (?change_note = "obsolete") }
    OPTIONAL { ?s skos:editorialNote ?status }
    OPTIONAL { ?s lexvo:iso639P3PCode ?iso639 }
    OPTIONAL { ?s geo:lat ?latitude; geo:long ?longitude } }'''


## display some results
from itertools import islice
for row in islice(graph.query(LANGUOIDS), 20):
    print '%s %-24s %-17s %-8s %s %-11s %-4s %-8s %s' % row

## Export to SQLite.
## Create an SQLite database file connecting with sqlite3 (docs). Activate foreign key checks so we notice if something is inconsistent.
import sqlite3
DB = 'glottolog.sqlite3'
db = sqlite3.connect(DB)
db.execute('PRAGMA foreign_keys = ON')
db

## Create a table for the results of the languoids query with some additional sanity checks. Insert the query rows. Count them.
db.execute('''
CREATE TABLE languoid (
  id TEXT NOT NULL PRIMARY KEY,
  label TEXT NOT NULL,
  level TEXT NOT NULL,
  parent TEXT,
  obsolete BOOLEAN NOT NULL,
  status TEXT,
  iso TEXT UNIQUE,
  latitude REAL,
  longitude REAL,
  FOREIGN KEY(parent) REFERENCES languoid(id) DEFERRABLE INITIALLY DEFERRED,
  CHECK (level IN ('LanguageFamily', 'LanguageSubfamily', 'Language', 'Dialect')),
  CHECK (obsolete IN (0, 1)),
  CHECK (status IN ('established', 'spurious', 'spurious retired', 'unattested',
                    'provisional', 'retired'))
)''')

db.executemany('INSERT INTO languoid VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', graph.query(LANGUOIDS))
db.commit()
db.execute('SELECT count(*) FROM languoid').fetchone()

## Languoids may have n alternative labels.
## Create a table for the labels and their language. Retrieve them with SPARQL. Insert the query results into the table. Count rows.
db.execute('''
CREATE TABLE label (
  id TEXT NOT NULL,
  lang TEXT NOT NULL,
  label TEXT NOT NULL,
  PRIMARY KEY (id, lang, label),
  FOREIGN KEY(id) REFERENCES languoid(id)
)''')

LABELS = '''
SELECT
  (substr(str(?s), 43) AS ?id) (lang(?label) AS ?lang) ?label
WHERE
  { ?s a dcterms:LinguisticSystem ; skos:altLabel ?label }'''

db.executemany('INSERT INTO label VALUES (?, ?, ?)', graph.query(LABELS))
db.commit()
db.execute('SELECT count(*) FROM label').fetchone()

## Languoids may have n references.
## Create a table for the references. Retrieve them with SPARQL. Insert the query results into the table. Count.
db.execute('''
CREATE TABLE reference (
  id TEXT NOT NULL,
  reference INTEGER NOT NULL,
  PRIMARY KEY (id, reference),
  FOREIGN KEY(id) REFERENCES languoid(id)
)''')

REFERENCES = '''
SELECT
  (substr(str(?s), 43) AS ?id) (substr(str(?o), 44) AS ?reference)
WHERE
  { ?s a dcterms:LinguisticSystem ; dcterms:isReferencedBy ?o
    FILTER (strstarts(str(?o), "http://glottolog.org/resource/reference/id/")) }'''

db.executemany('INSERT INTO reference VALUES (?, ?)', graph.query(REFERENCES))
db.commit()
db.execute('SELECT count(*) FROM reference').fetchone()

## Building the tree
## The languoids table only specifies the direct parent of each entry. However, we want to be able to traverse the tree and query the whole path.
## As SQLite supports hierarchical queries only with version 3.8.3+, we will use a more general approach and generate a table with all tree paths.
## In other words, we will compute the transitive closure of the parent relation, a.k.a. tree closure table.
## Since we won't use recursion inside the database, we will simply put together a bunch of SQL queries and feed the results back into a new table of our database.
PATH = '''SELECT
  i0 AS child, %(depth)d AS steps, i%(depth)d AS parent, i%(next)d IS NULL AS terminal
FROM (
  SELECT %(select)s
  FROM languoid AS l0
  %(joins)s
) WHERE parent IS NOT NULL'''

def path_query(depth):
    select = ', '.join('l%(step)d.id AS i%(step)d' % {'step': i} for i in range(depth + 2))
    joins = ' '.join('LEFT JOIN languoid AS l%(next)d ON l%(step)d.parent = l%(next)d.id'
        % {'step': i, 'next': i + 1} for i in range(depth + 1))
    return PATH % {'depth': depth, 'next': depth + 1, 'select': select, 'joins': joins}

## The path_query function generates a query for a tree walk of the length given by depth. Note that we will omit zero step (reflexive) walks.
## Each query returns the start glottocode, number of steps, end glottocode and a boolean indicating if there is no grandparent.
## When all paths in the query are terminal, we have arrived at the maximal depth
## Create a table for the results. Insert path walks of increasing depth until all walks have ended. Count the walks.
db.executescript('''
CREATE TABLE tree (
  child TEXT NOT NULL,
  steps INTEGER NOT NULL,
  parent TEXT NOT NULL,
  terminal BOOLEAN NOT NULL,
  PRIMARY KEY (child, steps),
  UNIQUE (child, parent),
  UNIQUE (parent, child),
  FOREIGN KEY (child) REFERENCES languoid (id),
  FOREIGN KEY (parent) REFERENCES languoid (id),
  CHECK (terminal IN (0, 1))
)''')

depth = 1
while True:
    rows = db.execute(path_query(depth)).fetchall()
    if not rows:
        break
    db.executemany('INSERT INTO tree VALUES (?, ?, ?, ?)', rows)
    depth += 1

db.commit()
db.execute('SELECT count(*) FROM tree').fetchone()

## Analysis with pandas
import pandas
languages = pandas.read_sql('''SELECT * FROM languoid
WHERE level="Language" AND NOT obsolete ORDER BY id''', db, index_col='id')
tree = pandas.read_sql('SELECT * FROM tree WHERE terminal', db, index_col='child')
langs = languages.join(tree, how='left', rsuffix='_tree')
langs

## plot languoids
import matplotlib.pyplot as plt

plt.figure(figsize=(12, 6))
plt.axis([-180, 180, -90, 90])
plt.xticks([-180, -90, 0, 90, 180])
plt.yticks([-45, 0, 45])

plt.scatter(langs.longitude, langs.latitude, 1)
print
## or show()
