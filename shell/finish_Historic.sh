Samples=(HG0027 HG_09 HG_15 HG_16 HG_20 HG0026 HG47203 HG47204 377 378)
NewName=(H03 H09 HG15 HG16 HG20 H07 H24 H23 H11 H12)

for i in ${!Samples[*]}; do
    Sample=${Samples[i]}
    New=${NewName[i]}
    echo $i ${Sample} ${New}

    mkdir -p /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/${New}/nucmer
    cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/${New}/nucmer

    conda activate mummer-3.23

    ## Use NUCMER to align all Wolbachia-specific contigs agains the reference.
    nucmer \
        -mum \
        -p ${New} \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/AE017196.1_wMel.fa \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/${Sample}/output/${Sample}_ILL.fa

    #combine contigs in order according to showtilingoutput in multifasta files

    delta-filter -q ${New}.delta >${New}.filter.delta

    show-coords -THrcl ${New}.filter.delta >${New}.coords

    show-tiling -i 20.0 -v 20.0 -V 0 -g -1 -R ${New}.filter.delta >${New}.tiling

    python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/CombineContigs.py \
        --tile ${New}.tiling \
        --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/${Sample}/output/${Sample}_ILL.fa \
        >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/${New}/nucmer/${New}.fasta

    python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/Scaffold.py \
        --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/${New}/nucmer/${New}.fasta \
        --Name ${New} |
        python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/SetStart.py \
            --reference /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/AE017196.1_wMel.fa \
            --input - \
            >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/${New}/nucmer/${New}_start.fasta

done

## copy to output and manually edit FASTA header to contain more info
cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/*/nucmer/*_start.fasta /media/inter/mkapun/projects/WolbachiaEvolHist_2023/Genomes

### BUSCO of finished genomes

for i in ${!Samples[*]}; do
    Sample=${Samples[i]}
    New=${NewName[i]}
    echo $i ${Sample} ${New}

    echo """

  #!/bin/sh

  ## name of Job
  #PBS -N BUSCO_${ID}

  ## Redirect output stream to this file.
  #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/refseq/busco/log/Busco_${New}_log.txt

  ## Stream Standard Output AND Standard Error to outputfile (see above)
  #PBS -j oe

  ## Select 50 cores and 200gb of RAM
  #PBS -l select=1:ncpus=50:mem=200g

  ######## load dependencies #######

  source /opt/anaconda3/etc/profile.d/conda.sh
  conda activate busco_5.2.2

  ######## run analyses #######

  ## Go to pwd
  cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/refseq/busco

  busco -i /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/${New}/nucmer/${New}_start.fasta \
       -o ${New}  \
          -m genome  \
             -c 50  \
                -f  \
                   -l rickettsiales_odb10
    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${New}_Busco.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${New}_Busco.qsub

done

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

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WolbGenomes/*/report.tsv; do

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

''' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/CompGenomics/assemblystats.r

Rscript /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/CompGenomics/assemblystats.r
