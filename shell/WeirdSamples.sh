### is there a double infection?
mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples
bcftools mpileup \
    -Bf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/Wolb_Burkholderia.fna \
    -a AD,DP \
    -d 1000 \
    -r "ENA|AE017196|AE017196.1" \
    -Ou /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/mapping/HG0027.bam |
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
    -Ou /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/mapping/HG0029.bam |
    bcftools call \
        -O z --ploidy 2 \
        -c \
        -v \
        -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/HG0029.vcf.gz


bcftools mpileup \
    -Bf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/Wolb_Burkholderia.fna \
    -a AD,DP \
    -d 1000 \
    -r "ENA|AE017196|AE017196.1" \
    -Ou /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/mapping/380.bam |
    bcftools call \
        -O z --ploidy 2 \
        -c \
        -v \
        -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/380.vcf.gz


## summarise frequencies for 380
gunzip -c /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/380.vcf.gz |
    grep -v '^#' |
    awk '{print $(NF)}' |
    grep '^0/1' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/GT_380.txt

python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/freq.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/GT_380.txt \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/GT_380.freq

## summarise frequencies for HG0027
gunzip -c /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/HG0027.vcf.gz |
    grep -v '^#' |
    awk '{print $(NF)}' |
    grep '^0/1' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/GT_HG0027.txt

python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/freq.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/GT_HG0027.txt \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/GT_HG0027.freq

## summarise frequencies for HG0029
gunzip -c /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/HG0027.vcf.gz |
    grep -v '^#' |
    awk '{print $(NF)}' |
    grep '^0/1' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/GT_HG0027.txt

python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/freq.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/GT_HG0027.txt \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/GT_HG0027.freq


echo '''

library(tidyverse)

DATA.H3=read.table("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/GT_HG0027.freq",
    header=F)

DATA.H13=read.table("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/GT_380.freq",
    header=F)

DATA.H5=read.table("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/GT_HG0029.freq",
    header=F)

colnames(DATA.H3)<-c("MinorFreq")
DATA.H3$Sample <- rep("H3",nrow(DATA.H3))

colnames(DATA.H13)<-c("MinorFreq")
DATA.H13$Sample <- rep("H13",nrow(DATA.H13))

colnames(DATA.H5)<-c("MinorFreq")
DATA.H5$Sample <- rep("H5",nrow(DATA.H5))


DATA.H3.sub<-sample_n(DATA.H3, nrow(DATA.H13))
DATA.H5.sub<-sample_n(DATA.H5, nrow(DATA.H13))


DATA<-rbind(DATA.H3.sub,DATA.H5.sub,DATA.H13)

summary(aov(MinorFreq~Sample,data=DATA))

ggplot(DATA, aes(x=MinorFreq,fill=Sample)) + geom_histogram(aes(y = after_stat(count / sum(count))),binwidth=0.05)+facet_grid(.~Sample)

ggsave("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/GT.pdf")
''' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/GT.r

Rscript /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/GT.r

# now do BLAST search

gunzip -c /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken/HG0027_1.fq.gz | head -400000 |
    sed -n '1~4s/^@/>/p;2~4p' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken_HG0027_1.fa

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
      -query /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken_HG0027_1.fa \
      > /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken_HG0027_1_blastn.txt

''' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken_HG0027_1_blastn.sh

qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken_HG0027_1_blastn.sh

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

cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/BLAST_summary.p* /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Variants

### HOLY S**T, at least H3 looks like Supergroup B Wolbachia ???

cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples

## OK, get the genome of supergroup B wolbachia wMeg.

wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/008/245/065/GCF_008245065.1_ASM824506v1/GCF_008245065.1_ASM824506v1_genomic.fna.gz

gunzip /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/GCF_008245065.1_ASM824506v1_genomic.fna.gz

##now do Kraken

Samples=(377 378 HG0034 HG0027 HG0029 HG_20 HG_09)

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken

for i in ${!Samples[*]}; do
    Sample=${Samples[i]}

    echo ${Sample}

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N Kraken_${Sample}

    ## Redirect output stream to this file.
    #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken/${Sample}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select 50 cores and 300gb of RAM
    #PBS -l select=1:ncpus=50:mem=300g

    ######## load dependencies #######

    module load Assembly/kraken-2.1.2

    DBNAME=/media/scratch/kraken-2.1.2/db/Supergroups

    kraken2 \
        --threads 100 \
        --gzip-compressed \
        --paired \
        --report /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken/${Sample}.report \
        --use-names \
        --db \$DBNAME \
        --classified-out /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken/${Sample}#.fq \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/${Sample}_1.fastq.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/${Sample}_2.fastq.gz  > /dev/null
    
    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${Sample}_SG_kraken.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${Sample}_SG_kraken.qsub

done

pigz /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken/*.fq

## index reference
module load NGSmapper/bwa-0.7.13
pigz /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/SuperGroups.fa
bwa index /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/SuperGroups.fa.gz

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/mapping

Samples=(377 378 HG0034 HG0027 HG0029 HG_20 HG_09)

for i in ${!Samples[*]}; do
    Sample=${Samples[i]}

    echo ${Sample}

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N Annotation_${Species}

    ## Redirect output stream to this file.
    #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/mapping/${Sample}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select a maximum walltime of 2h
    #PBS -l walltime=100:00:00

    ## Select a maximum of 20 cores and 500gb of RAM
    #PBS -l select=1:ncpus=1:mem=30gb

    ### dependenceies

    module load NGSmapper/bwa-0.7.13
    module load NGSmapper/minimap2-2.17
    module load Tools/samtools-1.12

    # bwa mem \
    #     -t 50 \
    #     /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/SuperGroups.fa.gz \
    #     /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken/${Sample}_1.fq.gz \
    #     /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/kraken/${Sample}_2.fq.gz |
    #     samtools view  -F 4 -bh | samtools sort \
    #     >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/mapping/${Sample}.bam


    samtools coverage /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/mapping/${Sample}.bam|
        awk -v ID=${Sample} 'NR>1{print ID"\t"$0}' \
        > /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/mapping/${Sample}_coverages.txt

    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${Sample}_mapping.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${Sample}_mapping.qsub

done

module load Tools/samtools-1.12

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/mapping/*.bam; do

    samtools index $i
    echo $i >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/mapping/bamlist.txt

done

samtools depth -f /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/mapping/bamlist.txt >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/mapping/bamlist.cov

Samples=(wMeg wMelCS)
Starts=(NZ_CP02 w1118)
for i in ${!Samples[*]}; do
    Sample=${Samples[i]}
    Start=${Starts[i]}

    echo ${Sample}

    grep "^${Start}" /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/mapping/bamlist.cov |
        python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/cov_Sliding.py \
            --input - \
            --window 5000 \
            --names H11,H12,H03,H05,H04,H09,H20 \
            >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/mapping/bamlist_${Sample}_1kb.cov

    echo """

library(tidyverse)
DATA=read.table('/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/mapping/bamlist_${Sample}_1kb.cov',header=T)

DATA.long <- DATA %>%
    gather(Sample,ReadDepth, H11:H20)

DATA.long = DATA.long %>%
  group_by(Sample) %>%
  filter(!(abs(ReadDepth - mean(ReadDepth)) > 2*sd(ReadDepth)))

PLOT<-ggplot(DATA.long,aes(x=Pos,y=ReadDepth))+
    geom_bar(stat='identity')+
    facet_wrap(~Sample,ncol=1, strip.position = 'right')+
    theme_bw()+
    xlab('Position')+
    theme(strip.text.y.right = element_text(angle = 0))
     #annotate('rect', xmin=497224, xmax=505755, ymin=-Inf, ymax=Inf,alpha=0.1,fill='blue')


ggsave('/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/mapping/bamlist_${Sample}_1kb.pdf',
    PLOT,
    width=16,
    height=12)

ggsave('/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/mapping/bamlist_${Sample}_1kb.png',
    PLOT,
    width=16,
    height=12)

""" >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/mapping/bamlist_${Sample}_1kb.r

    Rscript /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/mapping/bamlist_${Sample}_1kb.r

done

cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WeirdSamples/mapping/bamlist_*_1kb.p* /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/ReadDepths

## See finish.sh for denovo assembly
