## run Kraken for Wolbachia

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken
for ID in 380 HG_16 HG_14 HG_17 HG_18 HG_19 HG_21 HG0021 HG0025 HG0028 HG0035 HG29702 HG47203 376 377 378 HG_09 HG_15 HG_16 HG_20 HG0026 HG0027 HG0029 HG0034 HG47203 HG47204 HG47205 CK2 DGRP335 DGRP338 ED2 ED3 ED6N ED10N EZ2 GA125 KN34 KR7 RG3 RG5 RG34 SP80 TZ14 UG5N ZI268 ZO12 ZS11; do

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
    #PBS -l select=1:ncpus=40:mem=200g

    ######## load dependencies #######

    module load Assembly/kraken-2.1.2

    DBNAME=/media/scratch/kraken-2.1.2/db/Wolbachia

    kraken2 \
        --threads 40 \
        --gzip-compressed \
        --paired \
        --report /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/${ID}.report \
        --use-names \
        --db \$DBNAME \
        --classified-out /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/${ID}#.fq \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim/${ID}_1_val_1.fq.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim/${ID}_2_val_2.fq.gz  > /dev/null
    
    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_kraken.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_kraken.qsub

done

## now DGRP335 separately

module load Assembly/kraken-2.1.2
ID=DGRP335
DBNAME=/media/scratch/kraken-2.1.2/db/Wolbachia

kraken2 \
    --threads 100 \
    --gzip-compressed \
    --report /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/${ID}.report \
    --use-names \
    --db $DBNAME \
    --classified-out /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/${ID}.fq \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim/DGRP335_trimmed.fq.gz >/dev/null

pigz -f /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/*.fq

## for samples HG0027 and HG0029 also against supergroups

for ID in HG0027 HG0029; do

    module load Assembly/kraken-2.1.2
    DBNAME=/media/scratch/kraken-2.1.2/db/Supergroups

    kraken2 \
        --threads 40 \
        --gzip-compressed \
        --paired \
        --report /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/${ID}_SG.report \
        --use-names \
        --db $DBNAME \
        --classified-out /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/${ID}_SG#.fq \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim/${ID}_1_val_1.fq.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim/${ID}_2_val_2.fq.gz >/dev/null
done

### Now for Mitochondria

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito
for ID in 380 HG_16 HG_14 HG_17 HG_18 HG_19 HG_21 HG0021 HG0025 HG0028 HG0035 HG29702 HG47203 376 377 378 HG_09 HG_15 HG_16 HG_20 HG0026 HG0027 HG0029 HG0034 HG47203 HG47204 HG47205 CK2 DGRP335 DGRP338 ED2 ED3 ED6N ED10N EZ2 GA125 KN34 KR7 RG3 RG5 RG34 SP80 TZ14 UG5N ZI268 ZO12 ZS11; do

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
    #PBS -l select=1:ncpus=40:mem=200g

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
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim/${ID}_1_val_1.fq.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim/${ID}_2_val_2.fq.gz  > /dev/null
    
    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_kraken_mit.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_kraken_mit.qsub

done

pigz -f /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito/*.fq

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
    
    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/${ID}_kraken_mit.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/${ID}_kraken_mit.qsub

done

pigz /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito/*.fq
