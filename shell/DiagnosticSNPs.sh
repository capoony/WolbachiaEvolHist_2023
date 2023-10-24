PWD=/media/inter/mkapun/projects/WolbachiaEvolHist_2023

mkdir ${PWD}/output/Variants

python3 ${PWD}/scripts/DiagnosticSNPs.py \
  --input ${PWD}/results/MergedData/Wolb.vcf.gz \
  --MinCov 2 \
  --output ${PWD}/output/Variants/variants \
  --Variant ${PWD}/data/GT.txt

echo """

library(tidyverse)
library(ggpubr)

DATA=read.table('${PWD}/output/Variants/variants_variants.txt',
    header=T)

DATA=read.table('${PWD}/output/Variants/variants_variants.txt',
header=T)

DATA <-DATA %>%
filter(Sample != 'wYak')

Sums <- DATA %>%
    filter(Sample != 'wYak') %>%
    group_by(Sample,Variant) %>%
    summarize(Sum=n())

PLOT2<-ggplot(Sums,aes(x= forcats::fct_rev(Sample),y=Sum,fill=Variant))+
    geom_bar(stat='identity')+
    theme_bw()+
    scale_fill_manual(values = c( 'blue3','firebrick3'))+
    coord_flip()+ 
    xlab('')+
    theme(legend.position = 'none')

#PLOT2

PLOT=ggplot(DATA)+
  geom_rect(aes(xmin = Pos-1000, xmax = Pos+1000, ymin = 0, ymax = 1,fill=Variant))+
  facet_grid(Sample~.)+
    theme_bw()+
    xlab('Genomic position')+
    scale_fill_manual(values = c( 'blue3','firebrick3'))+
   theme(
        axis.text.y=element_blank(),  #remove y axis labels
        axis.ticks.y=element_blank()  #remove y axis ticks
        )+
  theme(strip.text.y.right = element_text(angle = 0))+ 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) + 
  scale_x_continuous(breaks=seq(0, 1300000, 250000))
#PLOT
PLOT.full=ggarrange(PLOT2,PLOT,ncol=2,widths=c(1,2))

ggsave('${PWD}/output/Variants/variants_dist.pdf',
  PLOT.full,
  width=8,
  height=6)

ggsave('${PWD}/output/Variants/variants_dist.png',
  PLOT.full,
  width=8,
  height=6)

# ggsave('${PWD}/output/Variants/variants_variants.pdf',
#     PLOT,
#     width=9,
#     height=4)

""" >${PWD}/output/Variants/variants_variants.r

Rscript ${PWD}/output/Variants/variants_variants.r

mkdir ${PWD}/results/Umea

module load Tools/bcftools-1.16
module load Tools/samtools-1.12

for i in ${PWD}/data/Wolbachia/*_sort.bam; do
  tmp=${i##*/}
  ID=${tmp%_sort.bam*}
  path=${i%/*}
  #samtools sort $i >${path}/${ID}_sort.bam
  #samtools index ${path}/${ID}_sort.bam

  samtools view -h ${path}/${ID}_sort.bam | sed 's/Wolbachia_pipientis_\[AE017196.1\]/ENA|AE017196|AE017196.1/g' | samtools view -bh >tmp
  mv tmp ${path}/${ID}_sort.bam
  # echo ${path}/${ID}_sort.bam >>${PWD}/data/Wolbachia/bamlist.txt
  # echo $ID >>${PWD}/data/Wolbachia/samplelist.txt
done

bcftools mpileup \
  -Bf ${PWD}/data/db/AE017196.1_wMel.fa \
  -b ${PWD}/data/Wolbachia/bamlist.txt \
  -a AD,DP \
  -Ou |
  bcftools call \
    --ploidy 1 \
    -c \
    -v |
  gzip >${PWD}/data/Wolbachia/Umea.vcf.gz

python ${PWD}/scripts/GTWolbDiagSNPS.py \
  --input ${PWD}/data/Wolbachia/Umea.vcf.gz \
  --Variant ${PWD}/data_old/OldStuff/output/Variants/variants_diag.txt \
  >${PWD}/results/Umea/variants.txt

echo """

library(tidyverse)
library(ggpubr)

DATA=read.table('${PWD}/results/Umea/variants.txt',
    header=T)
Sums <- DATA %>%
    filter(Sample != 'wYak') %>%
    group_by(Sample,Variant) %>%
    summarize(Sum=n())

PLOT2<-ggplot(Sums,aes(x= forcats::fct_rev(Sample),y=Sum,fill=Variant))+
    geom_bar(stat='identity')+
    theme_bw()+
    scale_fill_manual(values = c( 'blue3','firebrick3'))+
    coord_flip()+ 
    xlab('')+
    theme(legend.position = 'none')

#PLOT2

PLOT=ggplot(DATA)+
  geom_rect(aes(xmin = Pos-1000, xmax = Pos+1000, ymin = 0, ymax = 1,fill=Variant))+
  facet_grid(Sample~.)+
    theme_bw()+
    xlab('Genomic position')+
    scale_fill_manual(values = c( 'blue3','firebrick3'))+
   theme(
        axis.text.y=element_blank(),  #remove y axis labels
        axis.ticks.y=element_blank()  #remove y axis ticks
        )+
  theme(strip.text.y.right = element_text(angle = 0))+ 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) + 
  scale_x_continuous(breaks=seq(0, 1300000, 250000))
#PLOT
PLOT.full=ggarrange(PLOT2,PLOT,ncol=2,widths=c(1,2))

ggsave('${PWD}/results/Umea/variants_dist.pdf',
  PLOT.full,
  width=8,
  height=6)

ggsave('${PWD}/results/Umea/variants_dist.png',
  PLOT.full,
  width=8,
  height=6)

""" >${PWD}/results/Umea/variants.r

Rscript ${PWD}/results/Umea/variants.r
