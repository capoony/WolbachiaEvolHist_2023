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
parser.add_option("--gff", dest="GFF", help="Input file")
parser.add_option("--Name", dest="NA", help="Output file")
parser.add_option("--EXName", dest="EN", help="Output file")



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


NAME = d(str)
for l in load_data(options.EN):
    a = l.rstrip().split(",")
    NAME[a[0]] = a[1]

GenePos=d(tuple)
Function = d(str)
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
    GenePos[GENE]=(Start,End)
    Function[GENE]=PROD
    #print(GENE, Start, End)

START=0
Type=d(str)

for l in load_data(options.IN):
    if l.strip()=="":
        continue
    if l.lstrip().startswith("C4"):
        Test=0
        continue
    if l.lstrip().startswith("Query:"):
        if START == 0:
            START=1
        else:
            #print(AL)
            if "***" in AL[3]:
                Type[ID]="PrematureStop"
            elif "#" in AL[3]:
                Type[ID] = "FrameShift"
            elif Comp==0:
                Type[ID] = "Incomplete"
            else:
                Type[ID] = "Complete"
        ID=l.lstrip().split(": ")[1].split()[0]
        continue
    if l.lstrip().startswith("Query range:"):
        Sq=int(l.split(": ")[1].split(" ->")[0])
        Eq = int(l.split("-> ")[1])
        Lq=abs(Eq-Sq)
        AL=d(str)
        C=1
        continue
    if l.lstrip().startswith("Target range:"):
        St = int(l.split(": ")[1].split(" ->")[0])
        Et = int(l.split("-> ")[1])
        Lt=abs(Et-St)
        #print(Lq,Lt)
        if 3*Lq == Lt:
            Comp=1
        else:
            Comp=0
        Test = 1
        AL = d(str)
        C = 1
        continue
    if Test==1:
        if C==1:
            #print("TEST",l)
            LEN=len(l)
            Start = l.index(": ")+2
            End =l.rindex(": ")
            AL[C]+=l[Start:End].rstrip()
            C+=1
            continue
        if C==2:
            AL[C] += l[Start:End].rstrip()
            C += 1
            continue
        if C == 3:
            AL[C] += l[Start:End].rstrip()
            C += 1
            continue
        if C == 4:
            AL[C] += l[Start:End].rstrip()
            C =1
            continue

for k,v in sorted(GenePos.items()):
    if k in Type:
        print(NAME[options.NA], k, "\t".join(
            v), Type[k], sep="\t")
    else:
        print(NAME[options.NA],k,"\t".join(v),"Missing",sep="\t")