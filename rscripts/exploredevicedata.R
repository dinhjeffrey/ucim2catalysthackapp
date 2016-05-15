devices <- read.csv(file = '../M2C Final Data/devices.csv', header = F)
##eliminating null columns#
devices <- devices[,c(1:2,5:9,15,17:25,26,28,30:32)]
colnames(devices) <- c('device_id','parent_device_id','company_id','device_uuid','device_type_id','device_type','device_os','carrier_name','mcc','mnc','n_mcc','n_mnc','s_mcc','s_mnc','r_mcc','r_mnc','language','latest_post','device_secret','create_date','cpu_info','cpu_max_speed')
for (myColName in colnames(devices)) {
  print(paste(myColName))
}
##dealing with null device values##
deviceid <- devices$device_id
deviceid <- as.character(deviceid)
deviceid <- as.numeric(deviceid)
devices$device_id <- deviceid
devices <- devices[!is.na(devices$device_id),]
##replace all null values within integer columns##
parentid <- devices$parent_device_id
parentid <- as.character(parentid)
parentid <- as.numeric(parentid)
parentid[is.na(parentid)] <- -1
devices$parent_device_id <- parentid
##*nc connections##
for (myColName in c('mcc','mnc','n_mcc','n_mnc','s_mcc','s_mnc','r_mcc','r_mnc')) {
  nc <- devices[,myColName]
  nc <- as.character(nc)
  nc <- as.numeric(nc)
  nc[is.na(nc)] <- -1
  devices[,myColName] <- nc
}
# levels(parentid)[levels(parentid)=='NULL'] <- -1
# parentid[parentid==''] <- -1
# parentid[parentid=='NULL'] <- -1
devices$parent_device_id <- parentid
##deviceid from fact to int##
deviceid <- as.numeric(deviceid)
##checking duplicate values##
dupdeviceid <- duplicated(as.numeric(notnulldeviceid))
print(paste('is there are duplicates?'))
print(length(dupdeviceid[dupdeviceid==T])>0)
##indicates samung, LG, Nexus,HTC etc##
##split this into model & device##
write.csv(devices,file = '../cleandata/cleaneddevices.csv', row.names = F) 