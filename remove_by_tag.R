library(data.table)

MDB.alcohol <- fread("data_alcohol_matches_uniq.csv")

MDB.alcohol[, nonalc := 0]
MDB.alcohol[!(Auto.Purpose.Tag.Name %in% c("Cash", "No Tag", "Lunch or Snacks","Alcohol", "Dining and drinking", "Dining or Going Out") & 
        Manual.Tag.Name %in% c("Cash", "No Tag", "Lunch or Snacks","Alcohol", "Dining and drinking", "Dining or Going Out")), nonalc := 1]

MDB.alcohol <- MDB.alcohol[nonalc==0,]

save(MDB.alcohol, file="MDB_alcohol.RData")


