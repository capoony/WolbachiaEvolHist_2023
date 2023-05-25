## Map reads for Wolbachia

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full
module load NGSmapper/bwa-0.7.13

## index reference
bwa index /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/holo_dmel_6.12.fa.gz

for ID in 376 377 378 HG_09 HG_15 HG_16 HG_20 HG0026 HG0027 HG0029 HG0034 HG47203 HG47204 HG47205; do

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
    #PBS -l select=1:ncpus=100:mem=300gb

    ### dependenceies

    module load NGSmapper/bwa-0.7.13
    module load NGSmapper/minimap2-2.17
    module load Tools/samtools-1.12

    bwa mem \
        -t 100 \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/holo_dmel_6.12.fa.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/${ID}_1.fastq.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/${ID}_2.fastq.gz |
        samtools view  -F 4 -bh | samtools sort \
        >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/${ID}.bam

    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_mapping_full.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_mapping_full.qsub

done

printf "#ID\trname\tstartpos\tendpos\tnumreads\tcovbases\tcoverage\tmeandepth\tmeanbaseq\tmeanmapq\n" >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages.txt

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/*.bam; do

    tmp=${i##*/}
    ID=${tmp%.*}

    samtools coverage $i | awk -v ID=$ID 'NR>1{print ID"\t"$0}' >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages.txt

done
