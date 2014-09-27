

library(reshape); library(ggsubplot)


setwd("~/Dropbox/workspace/gitHub/mapMakeR/scottishIndependenceVote/")

socioecon <- read.csv("census2011_release2Cstd/QS611SC.csv", as.is = TRUE)  # 'as.is' prevents read as factors; as characters instead
str(socioecon)

cols <- 2:6
for (col in cols) {
	socioecon[, col] <- as.numeric(gsub(",", "", socioecon[, col]))
}
str(socioecon)
regional <- subset(socioecon, Council != "Scotland")

cols <- 3:6
for (col in cols) {
	newcol <- col + 4
	regional[, newcol] <- regional[, col] / regional[, 2]
}
colnames(regional) <- c("Council.area", "all", "AB", "C1", "C2", "DE", "AB%", "C1%", "C2%", "DE%")
regional[13, 1] <- "City of Edinburgh"
regional[14, 1] <- "Na h-Eileanan an Iar"
str(regional)

molten <- melt(regional, id.vars = "Council.area", measure.vars = c("AB%", "C1%", "C2%", "DE%"))
bars <- ggplot(molten, aes(x = Council.area, y = value, fill = variable)) + geom_bar(stat = "identity", position = "dodge")

## ggsubplot http://cran.r-project.org/web/packages/ggsubplot/ggsubplot.pdf
merged <- merge(results, regional, by = "Council.area")
# load objects (incl testplot) from makemap.R
testplot + geom_subplot2d(aes(long, lat, group = NULL, subplot = geom_bar(aes(variable, value, fill = variable, group = NULL, position = "identity"))), bins = c(15,12), ref = NULL, width = rel(0.8), data = moltmerge)
