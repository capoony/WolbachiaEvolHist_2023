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


SNPs = d(list)

for l in load_data(options.IN):
    if l.startswith(">"):
        header = l
        continue
    SNPs[header].extend(list(l.rstrip()))

NAMES = SNPs.keys()
C = len(SNPs[list(NAMES)[0]])
for i in range(C):
    COS = []
    NA = []
    for n in NAMES:
        if SNPs[n][i] == "N":
            continue
        COS.append(SNPs[n][i])
        NA.append(n)
    if len(NA) < 3:
        continue
    if len(set(COS)) == 1:
        continue
    for j in list(set(COS)):
        if COS.count(j) == 1:
            I = COS.index(j)
            if "WYAK" not in NA[I]:
                SNPs[NA[I]][i] = "N"

for k, v in SNPs.items():
    print(k+"".join(v))
