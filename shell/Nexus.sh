## get data

cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/

module load Tools/SRAtools-2.11.2

## obtain and rename read data for all samples from input file
while
    IFS=','
    read -r ID GROUP SRR
do
    ## if not Illumina only convert to FASTQ

    echo """
      fasterq-dump \
        --split-3 \
        -o ${ID} \
        -O reads \
        -e 8 \
        -f \
        -p \
        ${SRR}

      pigz reads/${ID}*
      """ >../shell/${ID}.sh

    sh ../shell/${ID}.sh &

done </media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/newDATA.txt

while
    IFS=','
    read -r ID GROUP SRR
do

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N Kraken_${ID}

    ## Redirect output stream to this file.
    #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/${ID}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select 50 cores and 300gb of RAM
    #PBS -l select=1:ncpus=50:mem=300g

    ######## load dependencies #######

    module load Assembly/kraken-2.1.2

    DBNAME=/media/scratch/kraken-2.1.2/db/Wolbachia

    kraken2 \
        --threads 100 \
        --gzip-compressed \
        --paired \
        --report /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/${ID}.report \
        --use-names \
        --db \$DBNAME \
        --classified-out /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/${ID}#.fq \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/${ID}_1.fastq.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/${ID}_2.fastq.gz  > /dev/null
    
    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_kraken.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_kraken.qsub

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N Kraken_${ID}

    ## Redirect output stream to this file.
    #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito/${ID}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select 50 cores and 300gb of RAM
    #PBS -l select=1:ncpus=50:mem=300g

    ######## load dependencies #######

    module load Assembly/kraken-2.1.2

    DBNAME=/media/scratch/kraken-2.1.2/db/MitoDmel

    kraken2 \
        --threads 50 \
        --gzip-compressed \
        --paired \
        --report /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito/${ID}.report \
        --use-names \
        --db \$DBNAME \
        --classified-out /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito/${ID}#.fq \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/${ID}_1.fastq.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/${ID}_2.fastq.gz  > /dev/null
    
    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_kraken_mito.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_kraken_mito.qsub

done </media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/newDATA.txt

cat /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/holo_dmel_6.12_newWolb.fa.gz \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/Burkholderia_cenocepacia.fna.gz \
    /media/inter/mkapun/projects/DrosoWolbGenomics/data/AE017196.1_wMel.fa.gz \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/holo_dmel_6.12_newWolb_Burk.fa.gz

module load NGSmapper/bwa-0.7.13

bwa index /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/holo_dmel_6.12_newWolb_Burk.fa.gz

while
    IFS=','
    read -r ID GROUP SRR
do

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
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/holo_dmel_6.12_newWolb_Burk.fa.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/${ID}_1.fastq.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/${ID}_2.fastq.gz |
        samtools view  -F 4 -bh | samtools sort \
        >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/${ID}.bam

    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_mapping_full.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_mapping_full.qsub

done </media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/newDATA.txt

while
    IFS=','
    read -r ID GROUP SRR
do

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
    #PBS -l select=1:ncpus=1:mem=300gb

    ### dependenceies


    module load Tools/samtools-1.12

    samtools view -bh 'ENA|AE017196|AE017196.1' /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/${ID}.bam \
    > /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/${ID}.bam

""" >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/filter_${ID}.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/filter_${ID}.qsub

done

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito/*_1.fq.gz; do
    tmp=${i##*/}
    ID=${tmp%_*}
    echo ${ID}
    ID=wMelOctoless
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

    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/${ID}_mapping_mito.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/${ID}_mapping_mito.qsub

done
