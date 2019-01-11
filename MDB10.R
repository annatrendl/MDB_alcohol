rm(list = ls())
library(data.table)
library(stringi)
library(lubridate)
#setwd("C:/Anna/MDB_alcohol")
load("MDB10.RData")

#MDB10 <- data.table(MDB10[, c("Transaction.Date", "Transaction.Description")])

#remove those with no info
MDB10 <- MDB10[!(Transaction.Description %in% c("<MDBREMOVED>", "<mdbremoved>", "<mdbremoved> - chq")),]
MDB10[, Transaction.Description := tolower(Transaction.Description)]

nonalcohol <- c("tesco", "stores", "group", "uber", "withdrawal", "sainsb",
                "asda", "coop", "lidl", "aldi", "waitrose", "spencer", "spar",
                "petrol", "shell", "esso", "morrisons", "hotel", "travel","sainsburys",
                "google", "restaurants", "pizza", "starbucks", "next", "superstore",
                "garden", "nandos", "subway", "primark", "greggs", "argos", 
                "superdrug", "costa", "amazon", "internet", "coffee", "cafe","caffe",
                "donalds", "spotify", "smith", "manger", "kfc", "ticket","mcdonalds",
                "boots", "domestic", "food", "grocery","h&m","pharmacy","costco",
                "ikea", "poundland", "cineworld", "lewis", "dental", "debenhams",
                "parking", "wilko", "halfords", "zara", "iceland", "homebase","giffgaff",
                "wagamama", "atm", "fee", "int'l", "mortgage", "weightwatchers",
                "energy", "standing order", "national trust", "steak", "burger king",
                "post office", "lloyds", "virgin active", "fitness", "co-op","virgin media",
                "theatre", "park view nursery", "farm park", "health", "hamburgers","virgin mobile",
                "cinemas", "itunes","amazon.co.uk","itunes.com", "hotel","marketplace",
                "sainsbury's",  "marks&spencer", "lewis", "interest", "morrison","nespresso",
                "water", "mandate", "halifax", "hsbc", "insurance","tfl.gov.uk/cp","hotels",
                "www.just", "lottery", "connect", "paypal", "council", "pets", "tea",
                "www.skybet.com", "vodafone", "barclays", "barclaycard", "tv","newsagent",
                "currys", "bbc", "loan", "restaurant", "netflix.com", "trains","cleaners","cleaner",
                "rail","bargains","oyster", "barclay", "refund", "betfair","eurogarages",
                "warehouse","ocado", "groupon", "chq", "juice", "cashback","hair","hairdressin",
                "holland & barrett", "weight", "holiday inn", "premier inn", "jurys inn",
                "services","service", "takeaway", "foundation", "garage", "flowers", "news",
                "nursery", "shop", "florist", "irish int", "vets", "servic", "souvenir", "car",
                "motors", "crafts", "white rose", "books", "hatch", "mult", "sushi",
                "vetr", "county oak", "park", "farm", "market", "centre", "texaco", "frankie & bennys",
                "store", "murco", "selly oak", "supermarket", "furniture", "cheshire oak", "fish",
                "sandwich", "bakery", "bullring", "bull ring", "bull ring-bir", "motor", "cinema",
                "bengal", "thai", "pull and bear", "clinic", "gallery", "globe london", "ferries",
                "sheilas'", "tyre", "hall", "convenience", "climbing", "chinese", "indian", "collectors",
                "supervalu", "fish", "newsagents", "bells brook", "shoes", "bow bells", "charity",
                "boutique", "movie", "t-mobile", "thank", "specsavers", "save", "usage", "faster",
                "sky", "bill", "life", "tax", "express", "capital", "transfer", "charge", "b365",
                "automated", "retail", "limited", "o2", "bac", "british")


#Using regular expressions would be better, but it takes more than twice as long as using stri_detect_fixed
nonalcohol <- paste0("\\b", nonalcohol, "\\b")
write(nonalcohol, file="noalcohol_keywords.csv")

MDB10[, nonalc := 0]
  for (i in 1:length(nonalcohol)) {
    MDB10[nonalc == 0, nonalc := nonalc + as.numeric(stri_detect_regex(Transaction.Description, nonalcohol[i]))]
    print(i)
  }

#for a 10% sample (26 million), this takes about 40 minutes

toadd <- c("inn","arms","arm","bar","bars","tavern","tav","brewhouse","conservative","olde","public house",
           "sports","pub","pubs","social club", "ale", "ales", "tap", "taphouse", "malt", "malthouse","beer",
           "brew", "stag","hound" ,"head", "and crown", "& crown", "crown &", "crown and", "the crown","beerhouse",
           "famous crown", "old crown", "lion", "revolution", "smiths of", "the red", "duke on the green",
           "fox on the green", "the plough", "plough and", "plough &", "windmill", "be at one", "the queen",
           "the queens", "the cock", "and cock", "& cock", "cock &", "cock and", "the black", "oneills",
           "o'neills", "the king", "the kings", "king and", "wheatsheaf", "the george", "admiral nelson",
           "lord nelson", "captain nelson", "the nelson", "walkabout", "rose", "pitcher & piano", "cosy club",
           "the fox", "fox &", "fox and", "and fox", "& fox", "hare", "hen", "raven", "alehouse", "thatch",
           "barrel", "thistle", "oak", "greyhound", "chequers", "alchemist", "botanist", "prince of",
           "the victoria", "the ox", "beehive", "golden bee", "honey bee", "the hop", "goose", "swan",
           "the star", "star and", "star &", "brewers", "and castle", "& castle", "the castle", "the wharf",
           "cross keys", "the cross", "the duke", "the railway", "the mill", "dog and", "horse",
           "the albion", "robin hood", "anchor", "the boat", "boathouse", "the duck", "the ship", "ship and",
           "the kingfisher", "half moon", "free house", "the old", "the bear", "and bear", "smokehouse",
           "smoke house", "the cat", "the shakespeare", "the globe", "crowns", "the cow", "boozy cow",
           "spotted cow", "dun cow", "calf", "wig", "coach", "tree", "the union","trees",
           "earl of", "wheel", "the dolphin", "wellington", "bridge house", "the folly", "marquis",
           "the yard", "royal albert", "smugglers", "queen of", "the engine", "the full moon", "thieves",
           "the shack", "the bank", "the regent", "the temple", "the talbot", "the admiral", "old crown",
           "corner house", "punch bowl", "fire station", "the pit", "the mayflower", "the quay", "queen victoria",
           "the courtyard", "the cambridge", "the dragon", "the hawk", "bunch of grapes", "the snug",
           "sailor", "the social", "waxy o'connors", "waxy oconnors", "harp", "platform","roof","grapes",
           "prospect of whitby", "pheasant", "horses", "blue boar", "squirrel", "smoking goat","the phoenix",
           "thirsty", "the goat", "goat &", "queen adelaide", "the fable", "the pig", "bells", "the fleece",
           "the hope", "foresters", "packhorse","the lighthouse", "hand", "ivy house", "the vault",
           "the navigation", "greene king", "wetherspoon", "wetherspoons", "yates", "yates's", "yatess",
           "hobgoblin", "slug and lettuce", "stonegate", "queen elizabeth", "royal george","stables",
           "seven kings", "hole in the", "angelic", "priory", "dukes", "anthologist", "marquess","taver",
           "cocks", "bull", "cricketers", "distiller", "duchess", "prince albert", "brasserie", "regent",
           "the queens", "the flag", "brewer", "aragon", "woolpack", "rise 46", "the bat", "the mulberry",
           "flying pig", "treehouse", "old mill", "draft house", "hammer & pincers", "minnow", "the sun",
           "wine", "coopers", "under the", "marston", "drinks", "old manor", "spotted", "port royal",
           "yeates", "mudlark", "of kings", "maypole", "willow walk", "cellar", "waggon", "token house")
compound <- c(paste("red", c("light","rover", "deer", "cow", "fox")),
              paste("white", c("hart", "heart", "swan", "rabbit", "cross", "rose", "bear", "house", "lion")),
              paste("the green", c("goose", "dragon", "man")), 
              paste("the royal", c("oak", "exchange", "william", "george", "scot", "standard", "pug", "sun", "barn")),
              paste("black", c("swan", "cock", "friar", "bear", "lion", "boy","heart", "fox", "bear", "dog")), 
              paste(c("lazy","running", "snooty", "hyndland", "stretton"),"fox"))

alcohol <- c(paste0("\\b", c(toadd[!grepl("&", toadd)], compound), "\\b"), toadd[grepl("&", toadd)])
#there's something weird going on with "&" so I'm gonna remove the \\b from these otherwise it doesnt match them

write(alcohol, file="alcohol_keywords.csv")

MDB10[, alc := 0]
  for (i in 1:length(alcohol)) {
    MDB10[nonalc == 0 & alc == 0,  alc := alc + as.numeric(stri_detect_regex(Transaction.Description, alcohol[i]))]
    print(i)
  }

#this takes about 40 mins too
