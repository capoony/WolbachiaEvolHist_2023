## Map reads for Wolbachia
PWD=/media/inter/mkapun/projects/WolbachiaEvolHist_2023

mkdir ${PWD}/results/mapping
module load NGSmapper/bwa-0.7.13

gzip /media/inter/mkapun/projects/DrosoWolbGenomics/data/AE017196.1_wMel.fa

cat /media/inter/mkapun/projects/DrosoWolbGenomics/data/AE017196.1_wMel.fa.gz \
    ${PWD}/data/Burkholderia_cenocepacia.fna.gz \
    >${PWD}/data/Wolb_Burkholderia.fna.gz

## index reference
bwa index ${PWD}/data/Wolb_Burkholderia.fna.gz

while read -r ID; do

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N Annotation_${Species}

    ## Redirect output stream to this file.
    #PBS -o ${PWD}/results/mapping/${ID}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select a maximum walltime of 2h
    #PBS -l walltime=100:00:00

    ## Select a maximum of 20 cores and 500gb of RAM
    #PBS -l select=1:ncpus=50:mem=100gb

    ### dependenceies

    module load NGSmapper/bwa-0.7.13
    module load NGSmapper/minimap2-2.17
    module load Tools/samtools-1.12

    bwa mem \
        -t 50 \
        ${PWD}/data/Wolb_Burkholderia.fna.gz \
        ${PWD}/results/kraken/${ID}_1.fq.gz \
        ${PWD}/results/kraken/${ID}_2.fq.gz |
        samtools view  -F 4 -bh | samtools sort \
        >${PWD}/results/mapping/${ID}.bam

    """ >${PWD}/shell/QSUB/${ID}_mapping.qsub

    qsub ${PWD}/shell/QSUB/${ID}_mapping.qsub

done <${PWD}/datasets/AllSamples.txt

## now map also DGRP335
ID=DGRP335
module load NGSmapper/bwa-0.7.13
module load NGSmapper/minimap2-2.17
module load Tools/samtools-1.12

bwa mem \
    -t 50 \
    ${PWD}/data/Wolb_Burkholderia.fna.gz \
    ${PWD}/results/kraken/${ID}.fq.gz |
    samtools view -F 4 -bh | samtools sort \
    >${PWD}/results/mapping/${ID}.bam

## now map against Mito

mkdir ${PWD}/results/mapping_mito

## index reference
bwa index ${PWD}/data/db/NC_024511.2_start.fasta

while read -r ID; do

    echo ${ID}
    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N Annotation_${Species}

    ## Redirect output stream to this file.
    #PBS -o ${PWD}/results/mapping_mito/${ID}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select a maximum walltime of 2h
    #PBS -l walltime=100:00:00

    ## Select a maximum of 20 cores and 500gb of RAM
    #PBS -l select=1:ncpus=20:mem=100gb

    ### dependenceies

    module load NGSmapper/bwa-0.7.13
    module load NGSmapper/minimap2-2.17
    module load Tools/samtools-1.12

    bwa mem \
        -t 20 \
        ${PWD}/data/db/NC_024511.2_start.fasta \
        ${PWD}/results/kraken/${ID}_1.fq.gz \
        ${PWD}/results/kraken/${ID}_2.fq.gz |
        samtools view -F 4 -bh | samtools sort \
        >${PWD}/results/mapping_mito/${ID}.bam

    """ >${PWD}/shell/${ID}_mapping_mit.qsub

    qsub ${PWD}/shell/${ID}_mapping_mit.qsub

done <${PWD}/datasets/AllSamples.txt
