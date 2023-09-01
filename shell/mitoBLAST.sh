
# now do BLAST search

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/blast_Mito

### kraken of trimmed reads


mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito_trimmed

for ID in 380 HG_16 HG_14 HG_17 HG_18 HG_19 HG_21 HG0021 HG0025 HG0028 HG0035 HG29702 HG47203 376 377 378 HG_09 HG_15 HG_16 HG_20 HG0026 HG0027 HG0029 HG0034 HG47203 HG47204 HG47205 CK2 DGRP335 DGRP338 ED2 ED3 ED6N ED10N EZ2 GA125 KN34 KR7 RG3 RG5 RG34 SP80 TZ14 UG5N ZI268 ZO12 ZS11; do

    echo ${ID}

ID=HG0027

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
        --report /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito_trimmed/${ID}.report \
        --use-names \
        --db \$DBNAME \
        --classified-out /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito_trimmed/${ID}#.fq \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim/${ID}_1_val_1.fq.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim/${ID}_2_val_2.fq.gz  > /dev/null
    
    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_kraken_mit.qsub

    sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_kraken_mit.qsub

done


for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito_trimmed/*_1.fq.gz 

do


    tmp=${i##*/}

    ID=${tmp%_1.f*}

    echo  $ID

    gunzip -c /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito_trimmed/${ID}_1.fq.gz | head -400000 |
    sed -n '1~4s/^@/>/p;2~4p' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/blast_Mito/kraken_${ID}_1.fa

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N BLAST_${ID}

    ## Redirect output stream to this file.
    #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/blast_Mito/BLAST_${ID}_log.txt

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
      -query /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/blast_Mito/kraken_${ID}_1.fa \
      > /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/blast_Mito/kraken_${ID}_blastn.txt

""" >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_mito_blastn.sh

qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_mito_blastn.sh

done

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/blast_Mito/AddVisualization
## now visualize BLAST counts 
python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/CombineBlast.py \
    --names /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/NAMES_CORRECT \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/blast_Mito/ \
    > /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/blast_Mito/AddVisualization/BLAST.txt

echo '''

library(tidyverse)

DATA=read.table("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/blast_Mito/AddVisualization/BLAST.txt",
    header=T)


PLOT <- ggplot(DATA,aes(x=Sample,y=Count,fill=Genus,group=Species))+
    geom_bar(position="fill",stat="identity")+
    theme_bw()
PLOT

ggsave(file="/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/blast_Mito/AddVisualization/BLAST.pdf",
    PLOT,
    width=12,
    height=6)

''' > /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/blast_Mito/AddVisualization/BLAST.r

Rscript /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/blast_Mito/AddVisualization/BLAST.r



















gunzip -c /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito/HG0025_1.fq.gz | head -400000 |
    sed -n '1~4s/^@/>/p;2~4p' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/blast_Mito/kraken_HG0025_1.fa


for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito/*_1.fq.gz 

do

    tmp=${i##*/}

    ID=${tmp%_1.f*}

    echo  $ID

    gunzip -c /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken_mito/${ID}_1.fq.gz | head -40000 |
    sed -n '1~4s/^@/>/p;2~4p' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/blast_Mito/kraken_${ID}_1.fa

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N BLAST_${ID}

    ## Redirect output stream to this file.
    #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/blast_Mito/BLAST_${ID}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select a maximum of 20 cores and 200gb of RAM
    #PBS -l select=1:ncpus=10:mem=200gb

    ######## load dependencies #######

    module load Alignment/ncbi-BLAST-2.12.0

    ######## run analyses #######

    blastn \
      -num_threads 10 \
      -evalue 1e-50 \
      -max_target_seqs 1 \
      -outfmt '6 qseqid sseqid staxids sscinames slen qlen pident length mismatch gapopen qstart qend sstart send evalue bitscore' \
      -db /media/scratch/NCBI_nt_DB_210714/nt \
      -query /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/blast_Mito/kraken_${ID}_1.fa \
      > /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/blast_Mito/kraken_${ID}_blastn.txt

""" >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_mito_blastn.sh

qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_mito_blastn.sh


done
gunzip -c /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken/HG0029_1.fq.gz | head -400000 |
    sed -n '1~4s/^@/>/p;2~4p' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken_HG0029_1.fa

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
      -query /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken_HG0029_1.fa \
      > /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken_HG0029_1_blastn.txt

''' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken_HG0029_1_blastn.sh

qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken_HG0029_1_blastn.sh

### now keep only one Hit with sequence similarity > 99%

awk -F "\t" '$7>=99 {print $1"\t"$2"\t"$3"\t"$4}' /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken_HG0027_1_blastn.txt |
    uniq >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken_HG0027_1_blastn_99.txt

awk -F "\t" '$7>=99 {print $1"\t"$2"\t"$3"\t"$4}' /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken_HG0029_1_blastn.txt |
    uniq >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken_HG0029_1_blastn_99.txt

grep 'Wolb' /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken_HG0029_1_blastn_99.txt >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken_HG0029_1_blastn_99_Wolb.txt

grep 'Wolb' /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken_HG0027_1_blastn_99.txt >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken_HG0027_1_blastn_99_Wolb.txt

### then I manually added information on supergroups based on diverse references

echo """

library(tidyverse)
library(gridExtra)

DATA<-read.table("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken_HG0027_1_blastn_99_Wolb.txt",
    header=F,
    sep="\t")

colnames(DATA)<-c("Read","ID","TaxID","Desc","Supergroup")
DATA.sum<-DATA %>%
    group_by(Supergroup,Desc) %>%
    summarise(Count=n())

D3<-    ggplot(DATA.sum,aes(x=Supergroup,
            y=Count,
            col=Desc,
            fill=Supergroup,
            label=Desc))+
        geom_bar(stat="identity",
            )+
            ggtitle("H03")+
        geom_text(position = position_stack(vjust = 0.5))+
        scale_color_manual(values=rep("black",length(unique(DATA.sum$Desc))))+ 
        scale_fill_manual(values=c("#c99f68","#9ac524","#d1d1cd"))+
        guides(colour="none")+
        theme_bw()

DATA<-read.table("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken_HG0029_1_blastn_99_Wolb.txt",
    header=F,
    sep="\t")

colnames(DATA)<-c("Read","ID","TaxID","Desc","Supergroup")
DATA.sum<-DATA %>%
    group_by(Supergroup,Desc) %>%
    summarise(Count=n())

D5<-    ggplot(DATA.sum,aes(x=Supergroup,
            y=Count,
            col=Desc,
            fill=Supergroup,
            label=Desc))+
        geom_bar(stat="identity",
            )+
            ggtitle("H05")+
        geom_text(position = position_stack(vjust = 0.5))+
        scale_color_manual(values=rep("black",length(unique(DATA.sum$Desc))))+ 
        scale_fill_manual(values=c("#c99f68","#9ac524","#d1d1cd"))+
        guides(colour="none")+
        theme_bw()

PLOT<-grid.arrange(D3,D5,ncol=2)

ggsave(file="/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/BLAST_summary.pdf",
    PLOT,
    width=20,
    height=10)


ggsave(file="/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/BLAST_summary.png",
    PLOT,
    width=20,
    height=10)

""" > /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/BLAST_summary.r

Rscript  /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/BLAST_summary.r
