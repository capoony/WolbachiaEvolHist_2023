mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/*_1.fq.gz; do
    tmp=${i##*/}
    ID=${tmp%_*}
    echo ${ID}

    echo """
    /media/inter/pipelines/AutDeNovo/AutDeNovo.sh \
        Name=${ID} \
        OutputFolder=/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/${ID} \
        Fwd=/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/${ID}_1.fq.gz \
        Rev=/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/${ID}_2.fq.gz \
        threads=50 \
        RAM=200 \
        RAMAssembly=500 \
        decont=no \
        SmudgePlot=no \
        BuscoDB=rickettsiales_odb10 \
        Trimmer=TrimGalore \
        MinReadLen=35 \
        BaseQuality=20 
    
    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_denovo.sh

    sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_denovo.sh &

done

### now compare BUSCO results

mkdir -p /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_summaries

cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo

find -iname "*short_summary.*.txt" -exec cp "{}" /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_summaries \;

source /opt/anaconda3/etc/profile.d/conda.sh
conda activate busco_5.2.2

python3.9 /opt/anaconda3/envs/busco_5.2.2/bin/generate_plot.py \
    -wd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_summaries

## Wolb Spec stats for 


for i in /media/inter/mkapun/projects/DrosoWolbGenomics/results/WolbGenomes/*/Genomes/Wolbachia.fa.gz

do

x=${i%%/Genomes/*}
ID=${x##*/}

  #!/bin/sh

  ## name of Job
  #PBS -N QUAST_Ak7_full

  ## Redirect output stream to this file.
  #PBS -o /media/inter/mkapun/projects/DrosoWolbGenomics/results/assemblies/Ak7_full/log/Quast_Ak7_full_log.txt

  ## Stream Standard Output AND Standard Error to outputfile (see above)
  #PBS -j oe

  ## Select 64 cores and 64gb of RAM
  #PBS -l select=1:ncpus=64:mem=64g

  ######## load dependencies #######

  module load Assembly/Quast-5.1.0rc1

  ######## run analyses #######

  ## Go to pwd
  cd /media/inter/pipelines/AutDeNovo

  quast.py   \
  --output-dir /media/inter/mkapun/projects/DrosoWolbGenomics/results/WolbGenomes/${ID}  \
  --threads 64   \
  --eukaryote   \
  -f   $i




### Combine Stats

printf "ID\tType\tValue\n" >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/summary.txt

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/*/results/AssemblyQC/Quast/report.tsv; do

    ID=$(grep "^Assembly" $i | awk -F "\t" '{print $2}')
    grep -v "^# contigs (" $i | grep "^# contigs" | awk -v ID=$ID -F "\t" '{print ID"\tContigs\t"$2}' >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/summary.txt
    grep -v "^Total length (" $i | grep "^Total length" | awk -v ID=$ID -F "\t" '{print ID"\tLength\t"$2}' >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/summary.txt
    grep "^Largest contig" $i | awk -v ID=$ID -F "\t" '{print ID"\tLargest\t"$2}' >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/summary.txt
    grep "^GC (%)" $i | awk -v ID=$ID -F "\t" '{print ID"\tGC\t"$2}' >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/summary.txt
    grep "^N50" $i | awk -v ID=$ID -F "\t" '{print ID"\tN50\t"$2}' >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/summary.txt
    grep "^N90" $i | awk -v ID=$ID -F "\t" '{print ID"\tN90\t"$2}' >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/summary.txt

done

for i in /media/inter/mkapun/projects/DrosoWolbGenomics/results/WolbGenomes/*/report.tsv; do

    x=${i%%/report*}
    ID=${x##*/}*

    grep -v "^# contigs (" $i | grep "^# contigs" | awk -v ID=$ID -F "\t" '{print ID"\tContigs\t"$2}' >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/summary.txt
    grep -v "^Total length (" $i | grep "^Total length" | awk -v ID=$ID -F "\t" '{print ID"\tLength\t"$2}' >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/summary.txt
    grep "^Largest contig" $i | awk -v ID=$ID -F "\t" '{print ID"\tLargest\t"$2}' >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/summary.txt
    grep "^GC (%)" $i | awk -v ID=$ID -F "\t" '{print ID"\tGC\t"$2}' >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/summary.txt
    grep "^N50" $i | awk -v ID=$ID -F "\t" '{print ID"\tN50\t"$2}' >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/summary.txt
    grep "^N90" $i | awk -v ID=$ID -F "\t" '{print ID"\tN90\t"$2}' >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/summary.txt

done

echo '''

library(tidyverse)

DATA=read.table("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/summary.txt",
    header=T)


DATA.spread <- DATA %>% 
    spread(Type,Value)

write.table(file="/media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/CompGenomics/assemblystats.txt",
DATA.spread,
quote=F,
row.names=F)