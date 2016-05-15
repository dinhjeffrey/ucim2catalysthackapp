import csv

counter = 0
with open("C:\Users\James\Documents\GitHub\ucim2catalysthackapp\pplication_versions.csv") as f:
    reader = csv.reader(f)
    a_file = open("C:\Users\James\Documents\GitHub\ucim2catalysthackapp\lappversionscleaned.csv", 'w')
    for i in reader:
        counter+=1;
        if (counter > 10):
            break;
        if (i[5] != "null"):
            temp = ""
            for x in i:
                temp += x+','
            temp.rstrip(',')
            temp += '\n'
            a_file.write(temp)
