### is there a double infection?
mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027
bcftools mpileup \
    -Bf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/Wolb_Burkholderia.fna \
    -a AD,DP \
    -d 1000 \
    -r "ENA|AE017196|AE017196.1" \
    -Ou /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/HG0027.bam |
    bcftools call \
        -O z --ploidy 2 \
        -c \
        -v \
        -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/HG0027.vcf.gz

gunzip -c /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/HG0027.vcf.gz |
    grep -v '^#' |
    awk '{print $(NF)}' |
    grep '^0/1' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GT.txt

python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/freq.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GT.txt \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GT.freq

# now do BLAST search

gunzip -c /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/HG0027_1.fq.gz |
    sed -n '1~4s/^@/>/p;2~4p' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/kraken_HG0027_1.fa

echo '''
    #!/bin/sh

    ## name of Job
    #PBS -N BLASTN_Yeti

    ## Redirect output stream to this file.
    #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/BLAST_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select a maximum of 20 cores and 200gb of RAM
    #PBS -l select=1:ncpus=100:mem=200gb

    ######## load dependencies #######

    module load Alignment/ncbi-BLAST-2.12.0

    ######## run analyses #######

    blastn \
      -num_threads 100 \
      -evalue 1e-100 \
      -outfmt "6 qseqid sseqid sscinames slen qlen pident length mismatch gapopen qstart qend sstart send evalue bitscore" \
      -db /media/scratch/NCBI_nt_DB_210714/nt \
      -query /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/kraken_HG0027_1.fa \
      > /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/kraken_HG0027_1_blastn.txt

''' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/kraken_HG0027_1_blastn.sh

qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/kraken_HG0027_1_blastn.sh

gunzip -c /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/HG0029_1.fq.gz |
    sed -n '1~4s/^@/>/p;2~4p' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/kraken_HG0029_1.fa

echo '''
    #!/bin/sh

    ## name of Job
    #PBS -N BLASTN_Yeti

    ## Redirect output stream to this file.
    #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/BLAST_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select a maximum of 20 cores and 200gb of RAM
    #PBS -l select=1:ncpus=100:mem=200gb

    ######## load dependencies #######

    module load Alignment/ncbi-BLAST-2.12.0

    ######## run analyses #######

    blastn \
      -num_threads 100 \
      -evalue 1e-100 \
      -outfmt "6 qseqid sseqid sscinames slen qlen pident length mismatch gapopen qstart qend sstart send evalue bitscore" \
      -db /media/scratch/NCBI_nt_DB_210714/nt \
      -query /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/kraken_HG0029_1.fa \
      > /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/kraken_HG0029_1_blastn.txt

''' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/kraken_HG0029_1_blastn.sh

qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/kraken_HG0029_1_blastn.sh

echo '''

library(tidyverse)

DATA=read.table("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GT.freq",
    header=F)

colnames(DATA)<-c("MinorFreq")

ggplot(DATA, aes(x=MinorFreq)) + geom_histogram(binwidth=0.02)

ggsave("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GT.pdf")
'''
