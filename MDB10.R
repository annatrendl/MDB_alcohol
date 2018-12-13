rm(list = ls())
library(data.table)
library(stringi)
library(lubridate)
#setwd("C:/Anna/MDB_alcohol")
load("MDB10.RData")
#load("MDB10random.RData")

# MDB10_all <- MDB10
# #select random sample
# MDB10 <- MDB10_all[sample.int(nrow(MDB10_all),1000000),]
# save(MDB10, file = "MDB10random.RData")

#get pubs dataset
allpubs <- data.table(read.csv("allpubs.csv", header = FALSE))
#convert to lowercase
allpubs[, V2 := tolower(V2)]
#frequency of each name
allpubs <- allpubs[,.N, .(V2)]
#keep the ones that 
allpubs <- allpubs[N>1,]
allpubs[, twowords := grepl(" ", V2)]
#keep the two words ones, and filter the one word ones - delete those that are very common words 
#and can be street names or other businesses etc
todelete <- c("angel", "swan", "railway", "trinity", "alexandra", "victoria", "castle", "ship",
              "albion", "silk", "broadway", "red", "fuel", "nine", "windsor", "home", "olivers",
              "grove", "trafalgar", "boutique", "pure", "curve", "waterloo")
allpubs[twowords == FALSE, keep := !grepl(paste(todelete, collapse = "|"), V2)]

#unique pub names, plus add "pub", "inn", "tavern", "tap", "malt", "brewery", "arms", 
pubs <- c(allpubs[twowords == TRUE,V2], allpubs[keep == TRUE,V2],
          "pub", "inn", "tavern", "tap", "malt", "brewery", "arms")
#remove characters that will give us trouble
pubs <- gsub("\\(","", pubs)
pubs <- gsub("\\)","", pubs)
pubs <- gsub("\\[","", pubs)
pubs <- gsub("\\]","", pubs)
pubs <- gsub("\\\\","", pubs)
#add space before and after
#pubs <- paste0("\\<",pubs,"\\>")



# I have 52k pub names and  1 million unique transactions
# so try to filter out very common entries that are dre defo not alcohol related to reduce computation time
#  words <- unique_transactions_all$description
# # #get rid of numbers
#  words <- gsub("1|2|3|4|5|6|7|8|9|0|,|-", "", words)
#  words <- unique(words)
#  frequency <- data.table(table(unlist(strsplit(words, split = " "))))
#  frequency <- frequency[order(-N)]
# based on the inspection of the first 500, we can use these words to filter out
# non alcohol related purchases

nonalcohol <- c("tesco", "stores", "group", "uber", "withdrawal", "sainsb",
                "asda", "coop", "lidl", "aldi", "waitrose", "spencer", "spar",
                "petrol", "shell", "esso", "morrisons", "hotel", "travel",
                "google", "restaurants", "pizza", "starbucks", "next", "superstore",
                "garden", "nandos", "subway", "primark", "greggs", "argos", 
                "superdrug", "costa", "amazon", "internet", "coffee", "cafe","caffe",
                "donalds", "spotify", "smith", "manger", "kfc", "ticket","mcdonalds",
                "boots", "domestic", "food", "grocery","h&m","pharmacy",
                "ikea", "poundland", "cineworld", "lewis", "dental", "debenhams",
                "parking", "wilko", "halfords", "zara", "iceland", "homebase",
                "wagamama", " atm ", " fee ", "int'l", "mortgage", "weightwatchers",
                "energy", "standing order", "national trust", "steak", "burger king",
                "post office", "lloyds", "virgin active", "fitness", "co-op",
                "theatre", "park view nursery", "farm park", "health", "hamburgers",
                "cinemas", "itunes","amazon.co.uk","itunes.com", "hotel","marketplace",
                "sainsbury's",  "marks&spencer", "lewis", "interest", "morrison",
                "water", "mandate", "halifax", "hsbc", "insurance","tfl.gov.uk/cp",
                "www.just", "lottery", "connect", "paypal", "council", "pets",
                "www.skybet.com", "vodafone", "barclays", "barclaycard", "tv",
                "currys", "bbc", "loan", "restaurant", "netflix.com", "trains",
                "rail","bargains","oyster", "barclay", "refund", "betfair",
                "warehouse","ocado")
#only match entire words
nonalcohol <- paste0("\\b", nonalcohol, "\\b")
pubs <-  paste0("\\b", pubs, "\\b")

####################NON-ALCOHOL FLAG###########################
#create non-alcohol flag, we can exclude these when matching the pub names
#MDB10[, nonalc := stri_detect_regex(Transaction.Description, paste(nonalcohol, collapse = "|"))]
#150 seconds with 1 million

MDB10[, nonalc := 0]
  system.time(
    for (i in 1:length(nonalcohol)) {
    MDB10[nonalc == 0, nonalc := nonalc + as.numeric(stri_detect_regex(Transaction.Description, nonalcohol[i]))]
    #print(i)
  })
#55 seconds with 1 million - 3 times faster


####################ALCOHOL FLAG###########################


#create alcohol flag for subset of data
# system.time(MDB10[nonalc == 0, 
#                    alco := stri_detect_regex(Transaction.Description,paste(pubs, collapse = "|"))])
#  MDB10[is.na(alco), alco := 1]
#282 seconds with 100k entries
#47 minutes with 1 million

MDB10[, alc := 0]
system.time(
for (i in 1:length(pubs)) {
  MDB10[nonalc == 0 & alc == 0, alc := alc + as.numeric(stri_detect_regex(Transaction.Description, pubs[i]))]
print(i)
})

#119 seconds with 100k entries
#1232.05 (21 minutes) seconds with 1 million entries
#demonstrate that it is the same result
#all.equal(as.numeric(MDB10$alco), MDB10$alc)

save(MDB10, file="MDB10_alc.RData")
