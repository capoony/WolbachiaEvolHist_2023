PWD=/media/inter/mkapun/projects/WolbachiaEvolHist_2023

mkdir ${PWD}/data/trim

while read -r ID; do

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N trim_galore_${ID}

    ## Redirect output stream to this file.
    #PBS -o ${PWD}/data/trim/${ID}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select 50 cores and 200gb of RAM
    #PBS -l select=1:ncpus=20:mem=200g

    ######## load dependencies #######

    source /opt/anaconda3/etc/profile.d/conda.sh
    conda activate trim-galore-0.6.2

    ## Go to output folder
    cd ${PWD}/data/trim

    ## loop through all FASTQ pairs and trim by quality PHRED 20, min length 30bp and automatically detect & remove adapters

    trim_galore   \
        --paired   \
        --quality 20   \
        --length 30    \
        --cores 20   \
        --fastqc   \
        --gzip   \
        ${PWD}/data/reads/${ID}_1.fastq.gz   \
        ${PWD}/data/reads/${ID}_2.fastq.gz

    """ >${PWD}/shell/QSUB/trim_${ID}.txt

    sh ${PWD}/shell/QSUB/trim_${ID}.txt

done <${PWD}/datasets/AllSamples.txt

## now also sample DGRP335
ID=DGRP335
conda activate trim-galore-0.6.2

## Go to output folder
cd ${PWD}/data/trim
trim_galore \
    --quality 20 \
    --length 30 \
    --cores 20 \
    --fastqc \
    --gzip ${PWD}/data/reads/${ID}.fastq.gz

## unzip FASTQC folders to get readlengths
cd ${PWD}/data/trim

for i in *.zip; do unzip $i; done

## now summarize the lengths
while read -r ID; do
    python ${PWD}/scripts/fastqLengthDist.py \
        --input ${PWD}/data/trim/${ID}_1_val_1_fastqc/fastqc_data.txt \
        --name ${ID} \
        >>${PWD}/data/trim/TrimmedReadLength.summary

done <${PWD}/datasets/AllSamples.txt
