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

bcftools mpileup \
    -Bf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/Wolb_Burkholderia.fna \
    -a AD,DP \
    -d 1000 \
    -r "ENA|AE017196|AE017196.1" \
    -Ou /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/380.bam |
    bcftools call \
        -O z --ploidy 2 \
        -c \
        -v \
        -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/380.vcf.gz

gunzip -c /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/380.vcf.gz |
    grep -v '^#' |
    awk '{print $(NF)}' |
    grep '^0/1' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GT_380.txt

python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/freq.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GT_380.txt \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GT_380.freq

gunzip -c /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/HG0027.vcf.gz |
    grep -v '^#' |
    awk '{print $(NF)}' |
    grep '^0/1' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GT_HG0027.txt

python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/freq.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GT_HG0027.txt \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GT_HG0027.freq

echo '''

library(tidyverse)

DATA.H3=read.table("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GT_HG0027.freq",
    header=F)

DATA.H13=read.table("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GT_380.freq",
    header=F)

colnames(DATA.H3)<-c("MinorFreq")
DATA.H3$Sample <- rep("H3",nrow(DATA.H3))

colnames(DATA.H13)<-c("MinorFreq")
DATA.H13$Sample <- rep("H13",nrow(DATA.H13))

DATA.H3.sub<-sample_n(DATA.H3, nrow(DATA.H13))

DATA<-rbind(DATA.H3.sub,DATA.H13)

t.test(MinorFreq~Sample,data=DATA)

ggplot(DATA, aes(x=MinorFreq,fill=Sample)) + geom_histogram(aes(y = after_stat(count / sum(count))),binwidth=0.05)+facet_grid(.~Sample)

ggsave("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GT.pdf")
''' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GT.r

Rscript /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GT.r

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
      -evalue 1e-50 \
      -max_target_seqs 1 \
      -outfmt "6 qseqid sseqid staxids sscinames slen qlen pident length mismatch gapopen qstart qend sstart send evalue bitscore" \
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
      -evalue 1e-50 \
      -max_target_seqs 1 \
      -outfmt "6 qseqid sseqid staxids sscinames slen qlen pident length mismatch gapopen qstart qend sstart send evalue bitscore" \
      -db /media/scratch/NCBI_nt_DB_210714/nt \
      -query /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/kraken_HG0029_1.fa \
      > /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/kraken_HG0029_1_blastn.txt

''' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/kraken_HG0029_1_blastn.sh

qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/kraken_HG0029_1_blastn.sh

cut -f 2-3 /media/inter/mkapun/projects/SepsidMicroBiome/results/blastn/ASV/qiime.blast \
    >/media/inter/mkapun/projects/SepsidMicroBiome/results/blastn/ASV/qiime.txt

perl /media/inter/mkapun/projects/SepsidMicroBiome/scripts/tax_trace.pl \
    /media/inter/mkapun/projects/SepsidMicroBiome/data/nodes.dmp \
    /media/inter/mkapun/projects/SepsidMicroBiome/data/names.dmp \
    /media/inter/mkapun/projects/SepsidMicroBiome/results/blastn/ASV/qiime.txt \
    /media/inter/mkapun/projects/SepsidMicroBiome/results/blastn/ASV/qiime.tax

echo "featureid" >/media/inter/mkapun/projects/SepsidMicroBiome/results/blastn/ASV/qiime.euk

paste /media/inter/mkapun/projects/SepsidMicroBiome/results/blastn/ASV/qiime.blast \
    /media/inter/mkapun/projects/SepsidMicroBiome/results/blastn/ASV/qiime.tax |
    grep -v "Eukary" | cut -f 1 | uniq >>/media/inter/mkapun/projects/SepsidMicroBiome/results/blastn/ASV/qiime.euk
