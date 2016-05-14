devices <- read.csv(file = '../M2C Sample/devices.csv', header = F)
##dealing with null device values##
deviceid[deviceid=='NULL']
##deviceid from fact to int##
deviceid <- as.numeric(deviceid)
##checking duplicate values##
as.numeric(deviceid)[!duplicated(as.numeric(deviceid))]
as.numeric(deviceid)[duplicated(as.numeric(deviceid))]
##indicates samung, LG, Nexus,HTC etc##
##split this into model & device##
devicename <- devices$V8



