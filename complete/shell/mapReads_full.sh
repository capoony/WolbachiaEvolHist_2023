## Map all reads against the hologenome

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full
module load NGSmapper/bwa-0.7.13

## add Burkholderia to Hologenome

cat /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/holo_dmel_6.12.fa.gz \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/Burkholderia_cenocepacia.fna.gz \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/holo_dmel_6.12+Burkh.fa.gz

## index reference
bwa index /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/holo_dmel_6.12+Burkh.fa.gz

for ID in 376 377 378 HG_09 HG_15 HG_16 HG_20 HG0026 HG0027 HG0029 HG0034 HG47203 HG47204 HG47205 380 HG_14 HG_17 HG_18 HG_19 HG_21 HG0021 HG0025 HG0028 HG0035 HG29702 HG47203 CK2 DGRP335 DGRP338 ED2 ED3 ED6N ED10N EZ2 GA125 KN34 KR7 RG3 RG5 RG34 SP80 TZ14 UG5N ZI268 ZO12 ZS11; do

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N map_${ID}

    ## Redirect output stream to this file.
    #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/${ID}_log.txt

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
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/holo_dmel_6.12+Burkh.fa.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim/${ID}_1_val_1.fq.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim/${ID}_2_val_2.fq.gz |
        samtools view  -F 4 -bh | samtools sort \
        >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/${ID}.bam

    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_mapping_full.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_mapping_full.qsub

done

ID=DGRP335
bwa mem \
    -t 100 \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/holo_dmel_6.12+Burkh.fa.gz \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim/DGRP335_trimmed.fq.gz |
    samtools view -F 4 -bh | samtools sort \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/${ID}.bam

Samples=(Re1_full Re3 Re6_full Re10 Ak7_full Ak9_full MEL_full CS POP)

for i in ${!Samples[*]}; do
    Sample=${Samples[i]}

    echo $i ${Sample}

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N map_${Sample}

    ## Redirect output stream to this file.
    #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/${Sample}_log.txt

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
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/holo_dmel_6.12+Burkh.fa.gz \
        /media/inter/mkapun/projects/DrosoWolbGenomics/results/assemblies/${Sample}/data/ONT/${Sample}_ont.fq.gz |
        samtools view -bh | samtools sort \
        >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/${Sample}.bam

    #samtools index /media/inter/mkapun/projects/DrosoWolbGenomics/results/RefMapping/${Sample}.bam

    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${Sample}_mapping_full.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${Sample}_mapping_full.qsub

done
