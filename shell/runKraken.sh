## run Kraken for Wolbachia
PWD=/media/inter/mkapun/projects/WolbachiaEvolHist_2023

mkdir ${PWD}/results/kraken

while read -r ID; do

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N Kraken_${ID}

    ## Redirect output stream to this file.
    #PBS -o ${PWD}/results/kraken/${ID}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select 50 cores and 300gb of RAM
    #PBS -l select=1:ncpus=40:mem=200g

    ######## load dependencies #######

    module load Assembly/kraken-2.1.2

    DBNAME=/media/scratch/kraken-2.1.2/db/Wolbachia

    kraken2 \
        --threads 40 \
        --gzip-compressed \
        --paired \
        --report ${PWD}/results/kraken/${ID}.report \
        --use-names \
        --db \$DBNAME \
        --classified-out ${PWD}/results/kraken/${ID}#.fq \
        ${PWD}/data/trim/${ID}_1_val_1.fq.gz \
        ${PWD}/data/trim/${ID}_2_val_2.fq.gz  > /dev/null
    
    """ >${PWD}/shell/QSUB/${ID}_kraken.qsub

    sh ${PWD}/shell/QSUB/${ID}_kraken.qsub

done <${PWD}/datasets/AllSamples.txt

## now DGRP335 separately

module load Assembly/kraken-2.1.2
ID=DGRP335
DBNAME=/media/scratch/kraken-2.1.2/db/Wolbachia

kraken2 \
    --threads 100 \
    --gzip-compressed \
    --report ${PWD}/results/kraken/${ID}.report \
    --use-names \
    --db $DBNAME \
    --classified-out ${PWD}/results/kraken/${ID}.fq \
    ${PWD}/data/trim/DGRP335_trimmed.fq.gz >/dev/null

pigz -f ${PWD}/results/kraken/*.fq

## for samples HG0027 and HG0029 also against supergroups

for ID in HG0027 HG0029; do

    module load Assembly/kraken-2.1.2
    DBNAME=/media/scratch/kraken-2.1.2/db/Supergroups

    kraken2 \
        --threads 40 \
        --gzip-compressed \
        --paired \
        --report ${PWD}/results/kraken/${ID}_SG.report \
        --use-names \
        --db $DBNAME \
        --classified-out ${PWD}/results/kraken/${ID}_SG#.fq \
        ${PWD}/data/trim/${ID}_1_val_1.fq.gz \
        ${PWD}/data/trim/${ID}_2_val_2.fq.gz >/dev/null
done

### Now for Mitochondria

mkdir ${PWD}/results/kraken_mito

while read -r ID; do

    echo ${ID}

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N Kraken_${ID}

    ## Redirect output stream to this file.
    #PBS -o ${PWD}/results/kraken_mito/${ID}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select 50 cores and 300gb of RAM
    #PBS -l select=1:ncpus=40:mem=200g

    ######## load dependencies #######

    module load Assembly/kraken-2.1.2

    DBNAME=/media/scratch/kraken-2.1.2/db/MitoDmel

    kraken2 \
        --threads 50 \
        --gzip-compressed \
        --paired \
        --report ${PWD}/results/kraken_mito/${ID}.report \
        --use-names \
        --db \$DBNAME \
        --classified-out ${PWD}/results/kraken_mito/${ID}#.fq \
        ${PWD}/data/trim/${ID}_1_val_1.fq.gz \
        ${PWD}/data/trim/${ID}_2_val_2.fq.gz  > /dev/null
    
    """ >${PWD}/shell/QSUB/${ID}_kraken_mit.qsub

    qsub ${PWD}/shell/QSUB/${ID}_kraken_mit.qsub

done <${PWD}/datasets/AllSamples.txt

pigz -f ${PWD}/results/kraken_mito/*.fq

### now for ONT data

mkdir ${PWD}/results/kraken_mito/ONT
for i in /media/inter/mkapun/projects/DrosoWolbGenomics/results/assemblies/*/data/ONT/*.fq.gz; do

    tmp=${i##*/}
    ID=${tmp%%_ont*}
    echo ${ID}

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N Kraken_${ID}

    ## Redirect output stream to this file.
    #PBS -o ${PWD}/results/kraken_mito/ONT/${ID}_log.txt

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
        --report ${PWD}/results/kraken_mito/ONT/${ID}.report \
        --use-names \
        --db \$DBNAME \
        --classified-out ${PWD}/results/kraken_mito/ONT/${ID}.fq \
        /media/inter/mkapun/projects/DrosoWolbGenomics/results/assemblies/${ID}/data/ONT/${ID}_ont.fq.gz > /dev/null
    
    """ >${PWD}/shell/${ID}_kraken_mit.qsub

    qsub ${PWD}/shell/${ID}_kraken_mit.qsub

done

pigz ${PWD}/results/kraken_mito/*.fq

### test how many reads similar to Supergroup B in samples

mkdir ${PWD}/results/Gryllus/kraken
for ID in HG0027 HG0029 HG0026 HG47205 HG47204; do

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N Kraken_${ID}

    ## Redirect output stream to this file.
    #PBS -o ${PWD}/results/Gryllus/kraken/${ID}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select 50 cores and 300gb of RAM
    #PBS -l select=1:ncpus=50:mem=300g

    ######## load dependencies #######

    module load Assembly/kraken-2.1.2

    DBNAME=/media/scratch/kraken-2.1.2/db/Supergroups

    kraken2 \
        --threads 50 \
        --gzip-compressed \
        --report ${PWD}/results/Gryllus/kraken/${ID}.report \
        --use-names \
        --paired \
        --db \$DBNAME \
        ${PWD}/data/reads/${ID}_1.fastq.gz \
        ${PWD}/data/reads/${ID}_2.fastq.gz > /dev/null
    
    """ >${PWD}/shell/QSUB/${ID}_kraken.qsub

    qsub ${PWD}/shell/QSUB/${ID}_kraken.qsub

done
