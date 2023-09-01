## Map reads for Wolbachia

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping
module load NGSmapper/bwa-0.7.13

gzip /media/inter/mkapun/projects/DrosoWolbGenomics/data/AE017196.1_wMel.fa

cat /media/inter/mkapun/projects/DrosoWolbGenomics/data/AE017196.1_wMel.fa.gz \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/Burkholderia_cenocepacia.fna.gz \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/Wolb_Burkholderia.fna.gz

## index reference
bwa index /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/Wolb_Burkholderia.fna.gz

for ID in 380 HG_16 HG_14 HG_17 HG_18 HG_19 HG_21 HG0021 HG0025 HG0028 HG0035 HG29702 HG47203 376 377 378 HG_09 HG_15 HG_16 HG_20 HG0026 HG0027 HG0029 HG0034 HG47203 HG47204 HG47205 CK2 DGRP335 DGRP338 ED2 ED3 ED6N ED10N EZ2 GA125 KN34 KR7 RG3 RG5 RG34 SP80 TZ14 UG5N ZI268 ZO12 ZS11 wMelCS wMelCSb; do

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N Annotation_${Species}

    ## Redirect output stream to this file.
    #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/${ID}_log.txt

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
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/Wolb_Burkholderia.fna.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/${ID}_1.fq.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/${ID}_2.fq.gz |
        samtools view  -F 4 -bh | samtools sort \
        >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/${ID}.bam

    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_mapping.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_mapping.qsub

done

## now map also DGRP335
ID=DGRP335
module load NGSmapper/bwa-0.7.13
module load NGSmapper/minimap2-2.17
module load Tools/samtools-1.12

bwa mem \
    -t 50 \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/Wolb_Burkholderia.fna.gz \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/${ID}.fq.gz |
    samtools view -F 4 -bh | samtools sort \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/${ID}.bam

## now map against Mito

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_mito

## index reference
bwa index /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/NC_024511.2_start.fasta

for ID in 380 HG_16 HG_14 HG_17 HG_18 HG_19 HG_21 HG0021 HG0025 HG0028 HG0035 HG29702 HG47203 376 377 378 HG_09 HG_15 HG_16 HG_20 HG0026 HG0027 HG0029 HG0034 HG47203 HG47204 HG47205 CK2 DGRP335 DGRP338 ED2 ED3 ED6N ED10N EZ2 GA125 KN34 KR7 RG3 RG5 RG34 SP80 TZ14 UG5N ZI268 ZO12 ZS11 wMelCS wMelCSb; do

    echo ${ID}
    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N Annotation_${Species}

    ## Redirect output stream to this file.
    #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_mito/${ID}_log.txt

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
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/NC_024511.2_start.fasta \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/${ID}_1.fq.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/${ID}_2.fq.gz |
        samtools view -F 4 -bh | samtools sort \
        >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_mito/${ID}.bam

    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/${ID}_mapping_mit.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/${ID}_mapping_mit.qsub

done

### we further repeated using the wMelCS genome as the reference to test if this results in a reference bias

sh
