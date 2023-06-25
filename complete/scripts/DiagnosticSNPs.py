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
parser.add_option("--output", dest="out", help="Input file")
parser.add_option("--MinCov", dest="MC",
                  help="numerical parameter", default=4)
parser.add_option("--Variant", dest="VA",
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


DiaOut = open(options.out+"_diag.txt", "wt")
VaOut = open(options.out+"_variants.txt", "wt")
DiaOut.write("Pos\twMelCS\twMel\n")
VaOut.write("Sample\tPos\tVariant\n")
VA = d(str)
for l in load_data(options.VA):
    a = l.rstrip().split()
    VA[a[0]] = a[1]

Positions = d(str)
for l in load_data(options.IN):
    if l.startswith("##"):
        continue
    a = l.rstrip().split()

    # get names from headers
    if l.startswith("#"):
        header = [x.split("/")[-1].split(".bam")[0] for x in a[9:]]
        continue

    # obtain alleles
    REF = a[3]
    ALT = a[4]
    ALLELE = [REF, ALT]

    # ignore tri- and tetra-allelic SNPs
    if len(ALT) > 1 or len(REF) > 1:
        continue

    pops = a[9:]

    TestGT = []
    VaGT = d(list)
    TYPE = d(str)

    for i in range(len(header)):
        if header[i] not in VA:
            continue
        GT, PLi, DP, AD = pops[i].split(":")

        if GT == "0":
            A = 0
            B = 1
        else:
            A = 1
            B = 0

        # obtain GTs, note that the REF PL is the second and the ALT Pl is the first in the list, thus we need to switch the order first, how confusing...
        PL = PLi.split(",")[::-1]

        # only consider GT if (1) the read-depth > than MC, (2) the Posterior Likelihood of the GT is > 50 and the PL of the other (non-called) GT is < 30 otherwise mark as ambiguous
        if int(DP) >= int(options.MC) and int(PL[A]) > 50 and int(PL[B]) < 30:
            VaGT[VA[header[i]]].append(GT)
            TestGT.append(GT)

    if len(TestGT) != len(VA):
        continue

    if len(list(set(VaGT["wMel"]))) == 1 and len(list(set(VaGT["wMelCS"]))) == 1 and VaGT["wMelCS"][0] != VaGT["wMel"][0]:
        TYPE[VaGT["wMelCS"][0]] = "wMelCS"
        TYPE[VaGT["wMel"][0]] = "wMel"
        DiaOut.write(a[1]+"\t"+ALLELE[int(VaGT["wMelCS"][0])] +
                     "\t"+ALLELE[int(VaGT["wMel"][0])]+"\n")
    else:
        continue

    # loop through all samples
    for i in range(len(header)):
        if header[i] in VA:
            continue

        GT, PLi, DP, AD = pops[i].split(":")

        if GT == "0":
            A = 0
            B = 1
        else:
            A = 1
            B = 0

        # obtain GTs, note that the REF PL is the second and the ALT Pl is the first in the list, thus we need to switch the order first, how confusing...
        PL = PLi.split(",")[:: -1]

        # only consider GT if (1) the read-depth > than MC, (2) the Posterior Likelihood of the GT is > 50 and the PL of the other (non-called) GT is < 30 otherwise mark as ambiguous
        if int(DP) >= int(options.MC) and int(PL[A]) > 50 and int(PL[B]) < 30:
            VaOut.write(header[i]+"\t"+a[1]+"\t"+TYPE[GT]+"\n")
