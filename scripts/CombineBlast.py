import sys
from collections import defaultdict as d
from optparse import OptionParser, OptionGroup

# Author: Martin Kapun

#########################################################   HELP   #########################################################################
usage = "python %prog --input file --output file "
parser = OptionParser(usage=usage)
group = OptionGroup(parser, '< put description here >')

#########################################################   CODE   #########################################################################

parser.add_option("--names", dest="NA", help="Input file")
parser.add_option("--input", dest="IN", help="Input file")
parser.add_option("--Number", dest="NO", help="Number of genera")
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


code = d(str)

for l in load_data(options.NA):
    if l.startswith("Libr"):
        continue
    a = l.rstrip().split()
    code[a[0]] = a[1]

Counts = d(lambda: d(int))
MOSTCOMMON = d(int)
for i in code.keys():
    for l in load_data(options.IN+"kraken_"+i+"_blastn.txt"):
        a = l.rstrip().split("\t")
        Counts[code[i]][a[3]] += 1
        MOSTCOMMON[a[3].split(" ")[0]] += 1


NEW = [x for x, y in sorted(
    list(MOSTCOMMON.items()), key=lambda x: x[1], reverse=True)[:int(options.NO)]]
# print(NEW)

print("Sample\tSpecies\tGenus\tCount")

for Sample, v in sorted(Counts.items()):
    for Species, Count in v.items():
        if Species.split(" ")[0] in NEW:
            print(Sample, Species.replace(" ", "_"),
                  Species.split(" ")[0], str(Count), sep="\t")
