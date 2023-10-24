## Map all reads against the hologenome

PWD=/media/inter/mkapun/projects/WolbachiaEvolHist_2023

mkdir ${PWD}/results/mapping_full
module load NGSmapper/bwa-0.7.13

## add Burkholderia to Hologenome

cat ${PWD}/data/holo_dmel_6.12.fa.gz \
    ${PWD}/data/Burkholderia_cenocepacia.fna.gz \
    >${PWD}/data/holo_dmel_6.12+Burkh.fa.gz

## index reference
bwa index ${PWD}/data/holo_dmel_6.12+Burkh.fa.gz

while read -r ID; do

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N map_${ID}

    ## Redirect output stream to this file.
    #PBS -o ${PWD}/results/mapping/${ID}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select a maximum walltime of 2h
    #PBS -l walltime=100:00:00

    ## Select a maximum of 20 cores and 500gb of RAM
    #PBS -l select=1:ncpus=50:mem=300gb

    ### dependenceies

    module load NGSmapper/bwa-0.7.13
    module load NGSmapper/minimap2-2.17
    module load Tools/samtools-1.12

    bwa mem \
        -t 50 \
        ${PWD}/data/holo_dmel_6.12+Burkh.fa.gz \
        ${PWD}/data/trim/${ID}_1_val_1.fq.gz \
        ${PWD}/data/trim/${ID}_2_val_2.fq.gz |
        samtools view  -F 4 -bh | samtools sort \
        >${PWD}/results/mapping_full/${ID}.bam

    """ >${PWD}/shell/QSUB/${ID}_mapping_full.qsub

    sh ${PWD}/shell/QSUB/${ID}_mapping_full.qsub

done <${PWD}/datasets/AllSamples.txt

ID=DGRP335
bwa mem \
    -t 100 \
    ${PWD}/data/holo_dmel_6.12+Burkh.fa.gz \
    ${PWD}/data/trim/DGRP335_trimmed.fq.gz |
    samtools view -F 4 -bh | samtools sort \
    >${PWD}/results/mapping_full/${ID}.bam

Samples=(Re1_full Re3 Re6_full Re10 Ak7_full Ak9_full MEL_full CS POP)

for i in ${!Samples[*]}; do
    Sample=${Samples[i]}

    echo $i ${Sample}

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N map_${Sample}

    ## Redirect output stream to this file.
    #PBS -o ${PWD}/results/mapping/${Sample}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select a maximum walltime of 2h
    #PBS -l walltime=100:00:00

    ## Select a maximum of 20 cores and 500gb of RAM
    #PBS -l select=1:ncpus=100:mem=300gb

    ### dependencies
    module load NGSmapper/minimap2-2.17
    module load Tools/samtools-1.12

    minimap2 -ax map-ont \
        -t 100 \
        ${PWD}/data/holo_dmel_6.12+Burkh.fa.gz \
        /media/inter/mkapun/projects/DrosoWolbGenomics/results/assemblies/${Sample}/data/ONT/${Sample}_ont.fq.gz |
        samtools view -bh | samtools sort \
        >${PWD}/results/mapping_full/${Sample}.bam

    #samtools index /media/inter/mkapun/projects/DrosoWolbGenomics/results/RefMapping/${Sample}.bam

    """ >${PWD}/shell/QSUB/${Sample}_mapping_full.qsub

    qsub ${PWD}/shell/QSUB/${Sample}_mapping_full.qsub

done
