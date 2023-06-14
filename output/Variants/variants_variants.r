

library(tidyverse)

DATA=read.table("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Variants/variants_variants.txt",
    header=T)

Sums <- DATA %>%
    filter(Sample != "wYak") %>%
    group_by(Sample,Variant) %>%
    summarize(Sum=n())

Plot<-ggplot(Sums,aes(x=Sample,y=Sum,fill=Variant))+
    geom_bar(stat="identity")+
    theme_bw()+
    scale_fill_manual(values = c( "blue3","firebrick3"))

ggsave("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Variants/variants_variants.pdf",
    Plot,
    width=9,
    height=4)


