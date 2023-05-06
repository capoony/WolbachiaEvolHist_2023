## run Kraken for Wolbachia

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken
for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/*_1.fastq.gz; do

    tmp=${i##*/}
    ID=${tmp%_*}
    echo ${ID}

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

done

pigz /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/*.fq

### Now for Mitochondira

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito
for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/*_1.fastq.gz; do

    tmp=${i##*/}
    ID=${tmp%_*}
    echo ${ID}

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

done

pigz /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito/*.fq

### now for ONT data

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito/ONT
for i in /media/inter/mkapun/projects/DrosoWolbGenomics/results/assemblies/*/data/ONT/*.fq.gz; do

    tmp=${i##*/}
    ID=${tmp%%_ont*}
    echo ${ID}

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N Kraken_${ID}

    ## Redirect output stream to this file.
    #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito/ONT/${ID}_log.txt

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
        --report /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito/ONT/${ID}.report \
        --use-names \
        --db \$DBNAME \
        --classified-out /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito/ONT/${ID}.fq \
        /media/inter/mkapun/projects/DrosoWolbGenomics/results/assemblies/${ID}/data/ONT/${ID}_ont.fq.gz > /dev/null
    
    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/${ID}_kraken_mito.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/${ID}_kraken_mito.qsub

done

pigz /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito/*.fq
