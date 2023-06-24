import sys
from collections import defaultdict as d
from optparse import OptionParser, OptionGroup

#Author: Martin Kapun

#########################################################   HELP   #########################################################################
usage="python %prog --input file --output file "
parser = OptionParser(usage=usage)
group=OptionGroup(parser,'< put description here >')

#########################################################   CODE   #########################################################################

parser.add_option("--input", dest="IN", help="Input file")
parser.add_option("--name", dest="NA", help="Output file")
parser.add_option("--logical", dest="log", help="logical parameter",action="store_true")
parser.add_option("--param", dest="param", help="numerical parameter",default=1)

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

TOTAL=[]
TOTALC=[]
Test=0
for l in load_data(options.IN):
    if l.startswith("#Length"):
        Test=1
        continue
    if l.startswith(">>END"):
        Test=0
        continue
    if Test==1:
        a=l.rstrip().split()
        LE=sum([int(x) for x in a[0].split("-")])/2
        I=float(a[-1])
        TOTAL.append(LE*I)
        TOTALC.append(I)

print(options.NA+"\t"+str(sum(TOTAL)/sum(TOTALC)))


