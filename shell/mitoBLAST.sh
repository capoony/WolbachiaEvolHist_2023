# now do BLAST search
PWD=/media/inter/mkapun/projects/WolbachiaEvolHist_2023

mkdir ${PWD}/results/blast_Mito

### kraken of trimmed reads

mkdir ${PWD}/results/kraken_mito_trimmed

while read -r ID; do

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
        --report ${PWD}/results/kraken_mito_trimmed/${ID}.report \
        --use-names \
        --db \$DBNAME \
        --classified-out ${PWD}/results/kraken_mito_trimmed/${ID}#.fq \
        ${PWD}/data/trim/${ID}_1_val_1.fq.gz \
        ${PWD}/data/trim/${ID}_2_val_2.fq.gz  > /dev/null
    
    """ >${PWD}/shell/QSUB/${ID}_kraken_mit.qsub

    sh ${PWD}/shell/QSUB/${ID}_kraken_mit.qsub

done <${PWD}/datasets/AllSamples.txt

for i in ${PWD}/results/kraken_mito_trimmed/*_1.fq.gz; do

    tmp=${i##*/}

    ID=${tmp%_1.f*}

    echo $ID

    gunzip -c ${PWD}/results/kraken_mito_trimmed/${ID}_1.fq.gz | head -400000 |
        sed -n '1~4s/^@/>/p;2~4p' >${PWD}/results/blast_Mito/kraken_${ID}_1.fa

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N BLAST_${ID}

    ## Redirect output stream to this file.
    #PBS -o ${PWD}/results/blast_Mito/BLAST_${ID}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select a maximum of 20 cores and 200gb of RAM
    #PBS -l select=1:ncpus=10:mem=200gb

    ######## load dependencies #######

    module load Alignment/ncbi-BLAST-2.12.0

    ######## run analyses #######

    blastn \
      -num_threads 100 \
      -evalue 1e-50 \
      -max_target_seqs 1 \
      -outfmt '6 qseqid sseqid staxids sscinames slen qlen pident length mismatch gapopen qstart qend sstart send evalue bitscore' \
      -db /media/scratch/NCBI_nt_DB_210714/nt \
      -query ${PWD}/results/blast_Mito/kraken_${ID}_1.fa \
      > ${PWD}/results/blast_Mito/kraken_${ID}_blastn.txt

""" >${PWD}/shell/QSUB/${ID}_mito_blastn.sh

    qsub ${PWD}/shell/QSUB/${ID}_mito_blastn.sh

done

mkdir ${PWD}/results/blast_Mito/AddVisualization
## now visualize BLAST counts
python ${PWD}/scripts/CombineBlast.py \
    --names ${PWD}/data/NAMES_CORRECT \
    --input ${PWD}/results/blast_Mito/ \
    --Number 3 \
    >${PWD}/results/blast_Mito/AddVisualization/BLAST.txt

echo '''

library(tidyverse)

DATA=read.table("${PWD}/results/blast_Mito/AddVisualization/BLAST.txt",
    header=T)

DATA.prop<-DATA %>%
    group_by(Sample,Genus)%>%
    summarize(n=sum(Count)) %>%
    mutate(freq=n/sum(n))

write.table(DATA.prop,
    "${PWD}/results/blast_Mito/AddVisualization/BLAST_stats.txt",
    quote=F,
    row.names=F)

PLOT <- ggplot(DATA,aes(x=Sample,y=Count,fill=Genus,group=Species))+
    geom_bar(position="fill",stat="identity")+
    theme_bw()
PLOT

ggsave(file="${PWD}/results/blast_Mito/AddVisualization/BLAST.pdf",
    PLOT,
    width=12,
    height=6)

''' >${PWD}/results/blast_Mito/AddVisualization/BLAST.r

Rscript ${PWD}/results/blast_Mito/AddVisualization/BLAST.r
