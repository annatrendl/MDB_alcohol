rm(list = ls())
library(data.table)
library(stringi)
library(lubridate)
setwd("C:/Anna/MDB_alcohol")
load("MDB10.RData")

# MDB10_all <- MDB10
# #select random sample
# MDB10 <- MDB10_all[sample.int(nrow(MDB10_all),100000),]
# save(MDB10, file = "MDB10random.RData")

#get pubs dataset
allpubs <- data.table(read.csv("allpubs.csv", header = FALSE))
allpubs[, V2 := tolower(V2)]
allpubs[, twowords := grepl(" ", V2)]
allpubs <- allpubs[,.N, .(V2)]
allpubs <- allpubs[N>1,]

#get unique transactions. we'll create an alcohol flag for these and then merge them back to the original dataset
#unique_transactions_all <- data.table(description = unique(MDB10$Transaction.Description))

#unqiue pub names
pubs <- unique(allpubs[twowords == TRUE,V2])
#remove characters that will give us trouble
pubs <- gsub("\\(","", pubs)
pubs <- gsub("\\)","", pubs)
pubs <- gsub("\\[","", pubs)
pubs <- gsub("\\]","", pubs)
pubs <- gsub("\\\\","", pubs)
#add space before and after
#pubs <- paste("", pubs, "")



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

#create non-alcohol flag, we can exclude these when matching the pub names
unique_transactions_all[, nonalc := stri_detect_regex(description, paste(nonalcohol, collapse = "|"))]
#create alcohol flag for subset of data
unique_transactions_all[nonalc == FALSE, alc := stri_detect_regex(description, paste(pubs, collapse = "|"))]
#set alcohol = false for the nonalc = true entries
unique_transactions_all[is.na(alc), alc := FALSE]

#merge it back with the alcohol flag
MDB10 <- merge(MDB10, unique_transactions_all[, c("description", "alc")], by.x = "Transaction.Description",
               by.y = "description", all.x = TRUE)

MDB10[, Transaction.Date := ymd(Transaction.Date)]

save.image("MDB10.RData")









