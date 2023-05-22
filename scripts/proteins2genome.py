import sys
from collections import defaultdict as d
from optparse import OptionParser, OptionGroup
import os

# Author: Martin Kapun

#########################################################   HELP   #########################################################################
usage = "python %prog --input file --output file "
parser = OptionParser(usage=usage)
group = OptionGroup(parser, "< put description here >")

#########################################################   CODE   #########################################################################

parser.add_option("--input", dest="IN", help="Input file")
parser.add_option("--names", dest="NA", help="Input file")
parser.add_option("--exclude", dest="EX", help="Input file")

(options, args) = parser.parse_args()
parser.add_option_group(group)


def load_data(x):
    """ import data either from a gzipped or or uncrompessed file or from STDIN"""
    import gzip

    if x == "-":
        y = sys.stdin
    elif x.endswith(".gz"):
        y = gzip.open(x, "rt", encoding="latin-1")
    else:
        y = open(x, "r", encoding="latin-1")
    return y


SeqHash = d(lambda: d(list))
Taxa = d(int)
Genes = d(int)
EXC = options.EX.split(",")


NAME = d(str)
for l in load_data(options.NA):
    a = l.rstrip().split(",")
    NAME[a[0]] = a[1]


for file in os.listdir(options.IN):
    Gene = file.split("_")[0]
    f = os.path.join(options.IN, file)
    C = 0
    for l in load_data(f):
        if l.startswith(">"):
            ID = l.split("|")[0][1:]
            Taxa[ID]
            C += 1
            continue
        if C == 1:
            Genes[Gene] += len(l.rstrip())
        SeqHash[ID][Gene].append(l.rstrip())


for Tax, v in sorted(SeqHash.items()):
    if Tax in EXC:
        continue
    Seq = []
    for Gene, L in sorted(Genes.items()):
        if Gene not in v:
            Seq.extend(L * ["-"])
        else:
            Seq.extend(v[Gene])
    print(">" + NAME[Tax])
    print("".join(Seq))
