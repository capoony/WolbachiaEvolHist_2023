## get data

cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/

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
        -O data/reads \
        -e 8 \
        -f \
        -p \
        ${SRR}

      pigz data/reads/${ID}*
      """ >shell/QSUB/${ID}.sh

  sh shell/QSUB/${ID}.sh &

done <datasets/newDATA2.txt
