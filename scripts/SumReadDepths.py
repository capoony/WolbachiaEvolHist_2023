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
parser.add_option("--names", dest="NA",
                  help="numerical parameter", default=1)
parser.add_option("--status", dest="ST",
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


Aut = d(list)
X = d(float)
WolDepth = d(float)
WolCov = d(float)
MitoDepth = d(float)

Autosomes = ["2L", "2R", "3L", "3R"]
ONT = ["Re1_full", "Re3", "Re6_full", "Re10",
       "Ak7_full", "Ak9_full", "MEL_full", "CS", "POP", "CK2", "DGRP335", "DGRP338", "ED2", "ED3", "ED6N", "ED10N", "EZ2", "GA125", "KN34", "KR7", "RG3", "RG5", "RG34", "SP80", "TZ14", "UG5N", "ZI268", "ZO12", "ZS11", "DGRP857", "DGRP88", "DGRP427", "DGRP370", "DGRP646", "wMelCS", "wMelCSb"]

TYPE = ["wMel", "wMelCS", "wMel", "wMelCS",
        "wMel", "wMel", "wMel", "wMelCS", "wMelCS", "wMel", "wMelCS", "wMelCS", "wMel", "wMel", "wMel", "wMel", "wMel", "wMel", "wMel", "wMel", "wMel", "wMel", "wMel", "wMel", "wMel", "wMel", "wMel", "wMel", "wMel", "uninfected", "uninfected", "uninfected", "wMel", "wMel", "wMelCS", "wMelCS"]


RECENT = dict(zip(*[ONT, TYPE]))

# print(RECENT)

NAME = d(str)
for l in load_data(options.NA):
    a = l.rstrip().split()
    NAME[a[0]] = a[1]

STATUS = d(str)
for l in load_data(options.ST):
    a = l.rstrip().split()
    STATUS[a[0]] = a[1]

header = ["ID", "rname", "startpos", "endpos", "numreads",
          "covbases", "coverage", "meandepth", "meanbaseq", "meanmapq"]
for l in load_data(options.IN):
    a = l.rstrip().split()
    if len(a) != 10:
        continue
    if a[1] in Autosomes:
        Aut[a[0]].append(float(a[-3]))
    if a[1] == "X":
        X[a[0]] = float(a[-3])
    if a[1] == "W_pipientis":
        WolDepth[a[0]] = float(a[-3])
        WolCov[a[0]] = float(a[-4])
    if a[1] == "mitochondrion_genome":
        MitoDepth[a[0]] = float(a[-3])

print("ID\tType\tWolbachiaType\tInfectionStatus\tAut\tX\tMito\tWolb\tWolbCov\tWolbTiter")
for k in sorted(list(Aut.keys())):
    if k in RECENT:
        Type = "Recent"
        WType = RECENT[k]
        print(k.split("_full")[0], Type, WType, STATUS[k], str(median(Aut[k])), str(X[k]), str(MitoDepth[k]), str(
            WolDepth[k]), str(WolCov[k]), str(WolDepth[k]/(sum(Aut[k])/len(Aut[k]))), sep="\t")
    else:
        Type = "Museum"
        if STATUS[k] == "infected":
            WType = "wMelCS"
        else:
            WType = STATUS[k]
        print(NAME[k], Type, WType, STATUS[k], str(median(Aut[k])), str(X[k]), str(MitoDepth[k]), str(
            WolDepth[k]), str(WolCov[k]), str(WolDepth[k]/(sum(Aut[k])/len(Aut[k]))), sep="\t")
