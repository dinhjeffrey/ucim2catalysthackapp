from numpy import genfromtxt
import csv

counter = 0
with open("C:\Users\James\Documents\GitHub\ucim2catalysthackapp\ppusage9_2015.csv") as f:
    reader = csv.reader(f)
    a_file = open("C:\Users\James\Documents\GitHub\ucim2catalysthackapp\usageappcleaned.csv", 'w')
    for i in reader:
        counter+=1;
        if (counter > 8000):
            break;
        if ((i[5] != "null") and (i[10] != "-1")):
            temp = ""
            for x in i[:7]:
                temp += x+','
            for x in i[10:]:
                temp += x+','
            temp.rstrip(',')
            temp += '\n'
            a_file.write(temp)


#my_data = genfromtxt("C:\Users\James\Documents\GitHub\ucim2catalysthackapp\mobileinfonov.csv", delimiter = ',')
