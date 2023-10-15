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
parser.add_option("--logical", dest="log",
                  help="logical parameter", action="store_true")
parser.add_option("--param", dest="param",
                  help="numerical parameter", default=1)

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


def median(x):
    ''' calculate median '''
    mid = int(len(x)/2)
    sort = sorted(x)
    if len(x) == 0:
        return "NA"
    if len(x) % 2 == 0:
        lower = sort[mid-1]
        upper = sort[mid]
        return (float(lower)+float(upper))/2.0
    else:
        return sort[mid]


CH = ""
for l in load_data(options.IN):
    a = l.rstrip().split()
    if CH == "":
        CH = a[0]
        POS = int(a[1])
        Counts = []
    elif CH != a[0]:
        # Counts.extend([0]*abs(POS-len(Counts)))
        print(CH+"\t"+str(median(Counts)))
        Counts = []
        CH = a[0]
    Counts.append(int(a[-1]))

print(CH+"\t"+str(median(Counts)))
