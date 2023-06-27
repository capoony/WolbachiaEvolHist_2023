### download data

cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data

module load Tools/NCBIedirect

## get table with all IDs for Project
esearch -db sra -query PRJNA945389 | efetch -format runinfo >runinfo.csv

## select most important columns
cat runinfo.csv | cut -f 1,12,29 -d , | sed "s/ /_/g" >run_sample_name.csv

## manually add two samples of wMelCS and wMelCSb

## obtain and rename read data for all samples from input file
module load Tools/SRAtools-2.11.2

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
