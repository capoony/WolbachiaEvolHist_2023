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
parser.add_option("--names", dest="NA", help="Input file")
parser.add_option("--window", dest="WI", help="Input file")
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


names = options.NA.split(",")
print("Pos\t"+"\t".join(names))
Cov = d(list)
window = int(options.WI)
Pos = 0
for l in load_data(options.IN):
    a = l.rstrip().split()
    pops = a[2:]
    if round(int(a[1])/window, 0) > Pos:
        PL = []
        for i in range(len(pops)):
            if len(Cov[i]) == 0:
                PL.append("NA")
            else:
                PL.append(str(sum(Cov[i])/len(Cov[i])))
        print(str(Pos*window)+"\t"+"\t".join(PL))
        Pos = round(int(a[1])/window, 0)
        Cov = d(list)
    for i in range(len(pops)):
        Cov[i].append(int(pops[i]))

PL = []
for i in range(len(pops)):
    if len(Cov[i]) == 0:
        PL.append("NA")
    else:
        PL.append(str(sum(Cov[i])/len(Cov[i])))
print(str(Pos*window)+"\t"+"\t".join(PL))
