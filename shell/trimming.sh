mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim

for ID in 380 HG_16 HG_14 HG_17 HG_18 HG_19 HG_21 HG0021 HG0025 HG0028 HG0035 HG29702 HG47203 376 377 378 HG_09 HG_15 HG_16 HG_20 HG0026 HG0027 HG0029 HG0034 HG47203 HG47204 HG47205 CK2 DGRP335 DGRP338 ED2 ED3 ED6N ED10N EZ2 GA125 KN34 KR7 RG3 RG5 RG34 SP80 TZ14 UG5N ZI268 ZO12 ZS11; do

    echo """
#!/bin/sh

## name of Job
#PBS -N trim_galore_${ID}

## Redirect output stream to this file.
#PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim/${ID}_log.txt

## Stream Standard Output AND Standard Error to outputfile (see above)
#PBS -j oe

## Select 50 cores and 200gb of RAM
#PBS -l select=1:ncpus=20:mem=200g

######## load dependencies #######

source /opt/anaconda3/etc/profile.d/conda.sh
conda activate trim-galore-0.6.2

## Go to output folder
cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim

## loop through all FASTQ pairs and trim by quality PHRED 20, min length 85bp and automatically detect & remove adapters

trim_galore   \
    --paired   \
    --quality 20   \
    --length 30    \
    --cores 20   \
    --fastqc   \
    --gzip   \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/${ID}_1.fastq.gz   \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/${ID}_2.fastq.gz

""" >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/trim_${ID}.txt

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/trim_${ID}.txt

done

## now add FASTQC for recent samples also
module load Tools/FastQC-0.11.9
cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim

for ID in CK2 DGRP335 DGRP338 ED2 ED3 ED6N ED10N EZ2 GA125 KN34 KR7 RG3 RG5 RG34 SP80 TZ14 UG5N ZI268 ZO12 ZS11; do

    mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim/${ID}

    fastqc \
        --noextract \
        --nogroup \
        -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim/${ID} \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim/${ID}_1_val_1.fq.gz &

done

## now also sample DGRP335
ID=DGRP335
conda activate trim-galore-0.6.2

## Go to output folder
cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim
trim_galore \
    --quality 20 \
    --length 30 \
    --cores 20 \
    --fastqc \
    --gzip /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/${ID}.fastq.gz

## unzip FASTQC folders to get readlengths
cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim

for i in *.zip; do unzip $i; done

for ID in 380 HG_16 HG_14 HG_17 HG_18 HG_19 HG_21 HG0021 HG0025 HG0028 HG0035 HG29702 HG47203 376 377 378 HG_09 HG_15 HG_16 HG_20 HG0026 HG0027 HG0029 HG0034 HG47203 HG47204 HG47205 CK2 DGRP335 DGRP338 ED2 ED3 ED6N ED10N EZ2 GA125 KN34 KR7 RG3 RG5 RG34 SP80 TZ14 UG5N ZI268 ZO12 ZS11; do

    python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/fastqLengthDist.py \
        --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim/${ID}_1_val_1_fastqc/fastqc_data.txt \
        --name ${ID} \
        >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/TrimmedReadLength.summary

done

for ID in CK2 DGRP335 DGRP338 ED2 ED3 ED6N ED10N EZ2 GA125 KN34 KR7 RG3 RG5 RG34 SP80 TZ14 UG5N ZI268 ZO12 ZS11; do

    #unzip /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim/${ID}/${ID}_1_val_1_fastqc.zip
    python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/fastqLengthDist.py \
        --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim/${ID}_1_val_1_fastqc/fastqc_data.txt \
        --name ${ID} \
        >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/TrimmedReadLength.summary
done
