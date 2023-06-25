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

State=""
Gene=d(str)

OutDict={
"Sugar":open(options.OUT+".Sugar","wt"),
"Align":open(options.OUT+".alignment","wt"),
"GFF":open(options.OUT+".gff","wt"),
"FA":open(options.OUT+".fa","wt")
}

OutDict["Sugar"].write("query_name\tquery_id\tquery_start\tquery_end\tquery_strand\ttarget_id\ttarget_start\ttarget_end\ttarget_strand\tscore\tquery_length\ttarget_length\n")
for l in load_data(options.IN):
    if l.startswith("Command") or l.startswith("host") or l.startswith("vulgar"):
        continue
    if len(l.rstrip())==0 and State!="Align":
        continue
    if l.startswith("C4 Alignment:"):
        State="Align"
    if l.startswith("# --- START OF GFF DUMP ---"):
        State="GFF"
    if l.startswith("#"):
        continue
    if l.strip().startswith("Query:"):
        a=l.strip().split(": ")
        if len(a)==3:
            ID=a[1].split()[0]
            Gene=a[2].replace(" ","_")
        else:
            A=a[1].split()
            ID=A[0]
            Gene="_".join(A[1:])
    if l.startswith("sugar"):
        A=l.split(": ")[1]
        a=A.rstrip().split()
        LENQ=str(abs(int(a[1])-int(a[2]))*3)
        LENT=str(abs(int(a[-3])-int(a[-4])))
        OutDict["Sugar"].write(Gene+"\t"+"\t".join(a)+"\t"+LENQ+"\t"+LENT+"\n")
        continue
    if State=="GFF" and "gene_id 0" in l:
        l=l.replace("gene_id 0","gene_id "+Gene)
    if l.startswith(">"):
        State="FA"
    if State!="":
        OutDict[State].write(l)

    

