### download data

cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data

module load Tools/NCBIedirect

## get table with all IDs for Project
esearch -db sra -query PRJNA945389 | efetch -format runinfo >runinfo.csv

## select most important columns
cat runinfo.csv | cut -f 1,12,29 -d , | sed "s/ /_/g" >run_sample_name.csv

#### Then manually add info for 10 more Illumina data with Wolb reads

module load Tools/SRAtools-2.11.2

## obtain and rename read data for all samples from input file
while
    IFS=','
    read -r SRR ID Species
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

done <run_sample_name.csv
