## Pre-processing for Glottolog Data Explorer

library(dplyr)
library(RSQLite)
library(RColorBrewer)


## read csv file downloaded from URL
glott <- read.csv('glottolog_languoids-step1.csv', sep=",")

## make colour palette and match to language status
brewpal <- brewer.pal(length(unique(glott$status)) ,"Accent")
glott$fillcol <- brewpal[glott$status]

## open a new db connection
my_db <- src_sqlite("glotto.sqlite3", create=T)

## populate db with glottolog data
glott_sqlite <- copy_to(my_db, glott, temporary = FALSE, indexes = list("id", "name"))
