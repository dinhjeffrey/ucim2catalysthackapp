setwd("/Users/aweng/Documents/ucim2catalysthackapp")
library(plyr)
carrier <- read.csv("carriers.csv", header = FALSE, sep = ",")
names(carrier)<- c("V1" = "mcc", "V2" = "mnc" , "V3" = "carrier_name")
#View(carrier)


dcarrier <- carrier[!carrier$mnc=='',]
dcarrier <- carrier[!carrier$carrier_name == '',]
View (dcarrier)

