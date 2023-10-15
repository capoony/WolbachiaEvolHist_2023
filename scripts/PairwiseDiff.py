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
parser.add_option("--group1", dest="GI", help="Output file")
parser.add_option("--group2", dest="GJ", help="Output file")
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


G1 = []
G2 = []
for l in load_data(options.IN):
    if l.startswith(">"):
        header = l.rstrip()[1:]
        continue
    if header in option.GI.split(","):
        G1.append(l.rstrip())
    elif header in options.GJ.split(","):
        G2.append(l.rstrip())

G1zip = list(zip(*G1))
G2zip = list(zip(*G2))

for i in range(len(G1zip)):
    print(bool(set([x for x in G1zip if x != "N"]) &
               set([x for x in G2zip if x != "N"])))
