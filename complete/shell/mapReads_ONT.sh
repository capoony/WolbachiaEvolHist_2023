## Map reads for Wolbachia
mkdir /media/inter/mkapun/projects/DrosoWolbGenomics/results/RefMapping

Samples=(Re1_full Re3 Re6_full Re10 Ak7_full Ak9_full MEL_full CS POP)

module load NGSmapper/minimap2-2.17
module load Tools/samtools-1.12
Sample=MEL_full
for i in ${!Samples[*]}; do
    Sample=${Samples[i]}

    echo $i ${Sample}

    minimap2 -ax map-ont \
        /media/inter/mkapun/projects/DrosoWolbGenomics/data/AE017196.1_wMel.fa \
        /media/inter/mkapun/projects/DrosoWolbGenomics/results/assemblies/${Sample}/data/ONT/${Sample}_ont.fq.gz |
        samtools view -bh | samtools sort \
        >/media/inter/mkapun/projects/DrosoWolbGenomics/results/RefMapping/${Sample}.bam

    samtools index /media/inter/mkapun/projects/DrosoWolbGenomics/results/RefMapping/${Sample}.bam

done

## now map against Mito

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_mito

## index reference
bwa index /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/NC_024511.2_start.fasta

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito/ONT/*.fq.gz; do
    tmp=${i##*/}
    ID=${tmp%.fq.gz*}
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


    minimap2 -ax map-ont \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/NC_024511.2_start.fasta  \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito/ONT/${ID}.fq.gz |
        samtools view -bh | samtools sort \
        >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_mito/${ID}.bam

    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_mapping_mito.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_mapping_mito.qsub

done

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_mito/*_complete.bam; do

    tmp=${i##*/}
    ID=${tmp%_complete.bam*}
    echo ${ID}

    mv /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_mito/${ID}_complete.bam /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_mito/${ID}.bam
done
