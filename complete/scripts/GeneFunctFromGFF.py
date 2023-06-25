import sys
from collections import defaultdict as d
from optparse import OptionParser, OptionGroup

#Author: Martin Kapun

#########################################################   HELP   #########################################################################
usage="python %prog --input file --output file "
parser = OptionParser(usage=usage)
group=OptionGroup(parser,'< put description here >')

#########################################################   CODE   #########################################################################

parser.add_option("--gff", dest="GFF", help="Input file")

(options, args) = parser.parse_args()
parser.add_option_group(group)

def load_data(x):
  ''' import data either from a gzipped or or uncrompessed file or from STDIN'''
  import gzip
  if x=="-":
      y=sys.stdin
  elif x.endswith(".gz"):
      y=gzip.open(x,"rt", encoding="latin-1")
  else:
      y=open(x,"r", encoding="latin-1")
  return y

for l in load_data(options.GFF):
    if l.startswith("#"):
        continue
    a=l.rstrip().split("\t")
    if a[2]!="CDS":
        continue
    Start=a[3]
    End=a[4]
    GENE="W"+a[-1].split("cds-W")[1].split(";")[0]
    PROD = a[-1].split("product=")[1].split(";")[0]
    print(GENE, PROD,sep="\t")
