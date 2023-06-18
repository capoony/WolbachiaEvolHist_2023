mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Variants

python3 /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/DiagnosticSNPs.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb_new.vcf.gz \
    --MinCov 2 \
    --output /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Variants/variants \
    --Variant /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/GT.txt

echo '''



library(tidyverse)
library(ggpubr)



DATA=read.table("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Variants/variants_variants.txt",
    header=T)

DATA=read.table("D:/GitHub/WolbachiaEvolHist_2023/output/Variants/variants_variants.txt",
header=T)

DATA <-DATA %>%
filter(Sample != "wYak")

Sums <- DATA %>%
    filter(Sample != "wYak") %>%
    group_by(Sample,Variant) %>%
    summarize(Sum=n())

PLOT2<-ggplot(Sums,aes(x= forcats::fct_rev(Sample),y=Sum,fill=Variant))+
    geom_bar(stat="identity")+
    theme_bw()+
    scale_fill_manual(values = c( "blue3","firebrick3"))+
    coord_flip()+ 
    xlab("")+
    theme(legend.position = "none")

#PLOT2

PLOT=ggplot(DATA)+
  geom_rect(aes(xmin = Pos-1000, xmax = Pos+1000, ymin = 0, ymax = 1,fill=Variant))+
  facet_grid(Sample~.)+
    theme_bw()+
    xlab("Genomic position")+
    scale_fill_manual(values = c( "blue3","firebrick3"))+
   theme(
        axis.text.y=element_blank(),  #remove y axis labels
        axis.ticks.y=element_blank()  #remove y axis ticks
        )+
  theme(strip.text.y.right = element_text(angle = 0))+ 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) + 
  scale_x_continuous(breaks=seq(0, 1300000, 250000))
#PLOT
PLOT.full=ggarrange(PLOT2,PLOT,ncol=2,widths=c(1,2))

ggsave("D:/GitHub/WolbachiaEvolHist_2023/output/Variants/variants_dist.pdf",
  PLOT.full,
  width=8,
  height=6)

ggsave("D:/GitHub/WolbachiaEvolHist_2023/output/Variants/variants_dist.png",
  PLOT.full,
  width=8,
  height=6)

ggsave("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Variants/variants_variants.pdf",
    Plot,
    width=9,
    height=4)

''' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Variants/variants_variants.r

Rscript /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Variants/variants_variants.r
