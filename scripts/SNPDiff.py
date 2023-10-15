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
parser.add_option("--groups", dest="GR", help="Input file")
parser.add_option("--output", dest="OUT", help="Output file")


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


GROUPS = d(list)

for l in load_data(options.GR):
    a = l.rstrip().split()
    GROUPS[a[1]].append(a[0])

SNPpos = d(str)

header = True
for l in load_data(options.IN):
    if header:
        length = int(l.rstrip().split()[1])
        header = False
        continue
    a = l.rstrip().split()
    SNPpos[a[0]] = a[1]

SNPgroups = d(lambda: d(list))
for i in range(length):
    for group, v1 in GROUPS.items():
        for sample in v1:
            Nuc = SNPpos[sample][i]
            if Nuc != "N":
                SNPgroups[group][i].append(Nuc)

# print(SNPgroups)

for i in GROUPS.keys():
    for j in GROUPS.keys():
        SNPCount = 0
        for pos in range(length):
            if len(SNPgroups[i][pos]) == 0 or len(SNPgroups[j][pos]) == 0:
                continue
            if not bool(set(SNPgroups[i][pos]) & set(SNPgroups[j][pos])):
                # print(str(pos), i, j, str(set(SNPgroups[i][pos])), str(set(SNPgroups[j][pos])))
                SNPCount += 1
        MinBin = min([len(SNPgroups[i]),
                      len(SNPgroups[j])])
        print(i, j, str(MinBin), str(SNPCount),
              str(SNPCount/MinBin), sep="\t")
