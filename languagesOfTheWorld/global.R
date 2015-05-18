## list of language families for filter

library(dplyr)
library(RSQLite)


## Fetch data from database pre-populated by the 'populate_db.R' script
glottdb <- src_sqlite("data/glotto.sqlite3")  # db connection
glottbl <- tbl(glottdb, "glott")  # load 'glott' table from db
glott_langs <- filter(glottbl) %>% select(id, family)
origdf <- as.data.frame(glott_langs)
fams <- '[all]'
fams <- append(fams, sort(unique(origdf$family)))
famvars <- fams
names(famvars) <- fams
