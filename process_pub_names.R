rm(list = ls())
library(data.table)
#setwd("C:/Anna/MDB_alcohol")

allpubs <- fread("allpubs.csv")
# Convert to lowercase
allpubs[, V2 := tolower(V2)]
# Frequency of each name
allpubs.freq <- allpubs[,.(freq=.N), .(pub.name=V2)]
rm(allpubs)

# Keep only those occurring more than once
allpubs.freq <- allpubs.freq[freq>1,]

allpubs.freq[, one.word := !grepl(" ", pub.name)]
#keep the two words ones, and filter the one word ones - delete those that are very common words and can be street names or other businesses etc
to.delete <- c("angel", "swan", "railway", "trinity", "alexandra", "victoria", "castle", "ship", "albion", "silk", "broadway", "red", "fuel", "nine", "windsor", "home", "olivers", "grove", "trafalgar", "boutique", "pure", "curve", "waterloo")


allpubs.freq[(one.word), keep := !grepl(paste(to.delete, collapse = "|"), pub.name)]

# Vector of unique pub names
pubs <- allpubs.freq[keep | !one.word, pub.name]
# Add "pub", "inn", "tavern", "tap", "malt", "brewery", "arms"
pubs <- c(pubs, c("pub", "inn", "tavern", "tap", "malt", "brewery", "arms"))

# Remove characters that will give us trouble
pubs <- gsub("\\(","", pubs)
pubs <- gsub("\\)","", pubs)
pubs <- gsub("\\[","", pubs)
pubs <- gsub("\\]","", pubs)
pubs <- gsub("\\\\","", pubs)

# Just checking they are unique, plus sorting them
pubs <- unique(sort(pubs))

write(pubs, file="pub_names.csv")

