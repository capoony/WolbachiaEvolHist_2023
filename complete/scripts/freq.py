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
parser.add_option("--output", dest="OUT", help="Output file")
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

for l in load_data(options.IN):
    a=l.rstrip().split(":")
    #print(a)
    if len(a[-1].split(","))>2:
        continue
    A,B=[int(x) for x in a[-1].split(",")]
    if A+B<5:
        continue
    FREQ=A/(A+B)
    if FREQ>0.5:
        print(1-FREQ)
    else:
        print(FREQ)