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

done </datasets/newDATA.txt
