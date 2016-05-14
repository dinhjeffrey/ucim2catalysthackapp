#simple file 
setwd('~/Documents/uci-hackathon-app/rscripts/')
list.files('.')
getwd()
apps <- read.csv(file = '../M2C Sample/application_versions.csv', header=F, nrow=10000)
str(apps)
#rename columns
colnames(apps)[1] <- 'application_version_id'
colnames(apps)[1:2] <- c('application_version_id','package_name')
#column selection
appid <- apps$V1
appid <- apps[,1]
appid <- apps[,c('application_version_id','package_name')]
#row selection
#is.na
#is.null
#for this data set null is actually 'NULL'
approw <- apps[apps$application_version_id==25926880,]
approw <- apps[apps$application_version_id=='NULL',]
#seeing sample data for first 10 columns
head(appid,10)
