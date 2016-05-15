import csv
from collections import defaultdict
#logdata

#possible headers

data = csv.reader(open("data_small.csv"), delimiter='\t')

for i in data:
    headers = i[0].split(',')
    break;
print(headers)
d = defaultdict(int)
for h in headers:
    d[h] = 0

header_types = {'entry_date':str, 'device_id':int, 'device_os':int, 
        'company_id':int, 'device_entry_id':int, 'log_timestamp':str, 
        'package_name':str, 'application_version': int, 
        'application_version_id': int, 'version': str, 'battery': int, 
        'back_battery': int, 'cpu': int, 'back_cpy':int, 'memory':int, 
        'data_all':int, 'back_data':int, 'data_wifi':int, 
        'data_mobile':int, 'crash_count':int, 'run_time':int, 
        'front_run_time':int, 'code_size':int, 'data_size':int, 
        'cache_size':int, 'other_size':int}

'''
poss_hd = ['entry_date', 'device_id', 'device_os', 'company_id',
           'device_entry_id', 'log_timestamp', 'package_name', 
           'application_version', 'application_version_id', 'version',
           'battery', 'back_battery', 'cpu', 'back_cpy', 'memory', 'data_all', 'back_data', 'data_wifi', 'data_mobile',
           'crash_count', 'run_time', 'front_run_time', 'code_size',
           'data_size', 'cache_size', 'other_size']
'''


counter = 1
with open("data_small.csv") as csvfile: 
    reader = csv.DictReader(csvfile)
    for row in reader:
        if counter >= 50: #change to 50
            break
        counter+=1
        for k in d.keys():
            try:
                if row[k] != None and row[k] != "-1":
                    d[k] += 1
            except:
                pass

for k in d.keys():
    if d[k] < 49:
        headers.remove(k)
        
if headers.count('year'):
    headers.remove('year')
    
if headers.count('month'):
    headers.remove('month')
    
if headers.count('day'):
    headers.remove('day')

print("Headers after dropping column: ", headers)
        
# with open("data_small.csv") as csvfile:
#     with open("test1.csv") as csvfile:
# #     reader = csv.DictReader(csvfile)
#     for row in reader:
        
#         print("hi", row['device_entry_id'])
        
# cr = csv.reader(open("data_small.csv", "rb"))

# for row in cr:
#     print(row)

# import sys
# f = open(sys.argv[1].'rb')
def row_values(row, headers):
    result = []
    for h in headers:
#         result.append("{}:{}".format(h, row[h]))
        result.append(row[h])
    return result

a_file = open("test1.csv", "w")
a_file.write(",".join(headers) + "\n")

with open("data_small.csv") as csvReadFile: 
    reader = csv.DictReader(csvReadFile)
#     with open("test1.csv", "w") as csvWriteFile:
#         writer = csv.DictWriter(csvWriteFile, fieldnames = headers)
#         writer.writeheader()
    for row in reader:
        if row['device_id'] == "NULL" or row['application_version_id'] == "NULL":
            continue
        result = []
        for h in headers:
            if row[h] == "NULL":
                if header_types[h] == int:
                    result.append(-1)
                else:
                    result.append("NULL")
            else:
                result.append(row[h])
        a_file.write(",".join(result)+ "\n")
#             for i in range(len(headers)):
#                 writer.writerow({headers[0]: row[headers[0]], headers[1]: row[headers[1]]})
a_file.close()
