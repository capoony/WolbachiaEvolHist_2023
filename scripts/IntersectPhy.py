import sys
from collections import defaultdict as d
from optparse import OptionParser, OptionGroup

# Author: Martin Kapun

#########################################################   HELP   #########################################################################
usage = "python %prog --input file --output file "
parser = OptionParser(usage=usage)
group = OptionGroup(parser, '< put description here >')

#########################################################   CODE   #########################################################################

parser.add_option("--input", dest="IN", help="Input file")
parser.add_option("--output", dest="OUT", help="Output file")
parser.add_option("--names", dest="NA", help="logical parameter")

(options, args) = parser.parse_args()
parser.add_option_group(group)


def load_data(x):
    ''' import data either from a gzipped or or uncrompessed file or from STDIN'''
    import gzip
    if x == "-":
        y = sys.stdin
    elif x.endswith(".gz"):
        y = gzip.open(x, "rt", encoding="latin-1")
    else:
        y = open(x, "r", encoding="latin-1")
    return y


def intersection(x, y):
    return [value for value in x if value in y]


LIST1 = d(str)
LIST2 = d(str)

File1, File2 = options.IN.split(",")
NAME1, NAME2 = options.NA.split(",")

H = 0
for l in load_data(File1):
    if H == 0:
        H = 1
        continue
    a = l.rstrip().split()
    LIST1[a[0]] = a[1]

H = 0
for l in load_data(File2):
    if H == 0:
        H = 1
        continue
    a = l.rstrip().split()
    LIST2[a[0]] = a[1]

LABELS = intersection(LIST1.keys(), LIST2.keys())

out1 = open(options.OUT+NAME1+".phy", "wt")
out2 = open(options.OUT+NAME2+".phy", "wt")

out1.write(str(len(LABELS))+"\t"+str(len(list(LIST1.values())[0]))+"\n")
for k, v in LIST1.items():
    if k in LABELS:
        out1.write(k+"\t"+v+"\n")

out2.write(str(len(LABELS))+"\t"+str(len(list(LIST2.values())[0]))+"\n")
for k, v in LIST2.items():
    if k in LABELS:
        out2.write(k+"\t"+v+"\n")
