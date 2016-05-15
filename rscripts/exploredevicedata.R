devices <- read.csv(file = '../M2C Final Data/devices.csv', header = F)
##eliminating null columns#
devices <- devices[,c(1:2,5:9,15,17:25,26,28,30:32)]
colnames(devices) <- c('device_id','parent_id','company_id','device_uuid','device_type_id','device_type','device_os','carrier_name','mcc','mnc','n_mcc','n_mnc','s_mcc','s_mnc','r_mcc','r_mnc','language','latest_post','device_secret','create_date','cpu_info','cpu_max_speed')
for (myColName in colnames(devices)) {
  print(paste(myColName))
}
##dealing with null device values##
deviceid <- devices[,1]
devices <- devices[deviceid[deviceid!='NULL'],]
##deviceid from fact to int##
deviceid <- as.numeric(deviceid)
##checking duplicate values##
notnulldeviceid <- deviceid[deviceid!='NULL']
dupdeviceid <- duplicated(as.numeric(notnulldeviceid))
print(paste('is there are duplicates?'))
print(length(dupdeviceid[dupdeviceid==T])>0)
as.numeric(deviceid)[!duplicated(as.numeric(deviceid))]
as.numeric(deviceid)[duplicated(as.numeric(deviceid))]
##indicates samung, LG, Nexus,HTC etc##
##split this into model & device##
write.csv(notnulldeviceid)
