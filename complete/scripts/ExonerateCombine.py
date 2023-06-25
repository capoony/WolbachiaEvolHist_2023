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

(options, args) = parser.parse_args()
parser.add_option_group(group)


def parseFASTA(x):
    ''' Parse FASTA string '''


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


GeneCount = d(lambda: d(int))
FASTA = d(lambda: d(str))

# >HG_16_WP_007549057.1_MULTISPECIES: hypothetical protein[Wolbachia]_NODE_54_length_7302_cov_4.566505_(3521-3689)
# F0F1_ATP_synthase_subunit_C_[Wolbachia]	WP_006014985.1	0	75	.	contig_551	5315	5540 + 359 225 225

L = 0


for file in load_data(options.IN):
    L += 1
    for l in load_data(file.rstrip()):
        if l.startswith(">"):
            sample = l[1:].split("_WP_")[0]
            gene = l.split(".1_")[1].split("[")[0]
            GeneCount[gene][sample] += 1
            if gene in FASTA[sample] or not "membrane" in gene:
                Block = 1
            else:
                Block = 0

            continue
        if Block == 0:
            FASTA[sample][gene] += l.strip()

exclude = d(str)
# for gene, v in GeneCount.items():
#     for sample, count in v.items():
#         if count > 1:
#             exclude[gene]

for sample, v in sorted(FASTA.items()):
    SEQ = ""
    for gene, seq in sorted(v.items()):
        #print(len(GeneCount[gene]), L)
        if gene in exclude or len(GeneCount[gene]) < 15:
            continue
        SEQ += seq
    if SEQ == "":
        continue
    print(">"+sample)
    print(SEQ)
