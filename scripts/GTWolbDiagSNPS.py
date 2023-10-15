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
parser.add_option("--Variant", dest="VA")

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


SNPs = d(lambda: d(str))
for l in load_data(options.VA):
    a = l.rstrip().split()
    if l.startswith("Pos"):
        continue
    SNPs[int(a[0])][a[1]] = "wMelCS"
    SNPs[int(a[0])][a[2]] = "wMel"

print("Sample\tPos\tVariant")
for l in load_data(options.IN):
    if l.startswith("##"):
        continue
    a = l.rstrip().split()

    # get names from headers
    if l.startswith("#"):
        header = [x.split("/")[-1].split("_sort.bam")[0] for x in a[9:]]
        continue

    if (int(a[1])) not in SNPs:
        continue

    # obtain alleles
    REF = a[3]
    ALT = a[4]
    ALLELE = [REF, ALT]

    # ignore tri- and tetra-allelic SNPs
    if len(ALT) > 1 or len(REF) > 1:
        continue

    pops = a[9:]
    for i in range(len(pops)):
        GT, PLi, DP, AD = pops[i].split(":")
        if ALLELE[int(GT)] not in SNPs[int(a[1])]:
            print([header[i], a[1], "NA"])
        else:
            print(header[i], a[1], SNPs[int(a[1])]
                  [ALLELE[int(GT)]], sep="\t")
