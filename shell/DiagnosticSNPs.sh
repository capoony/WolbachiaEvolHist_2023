mkdir /Volumes/HTCTFTCAM/WolbachiaEvolHist_2023/output/Variants

python3 /Volumes/HTCTFTCAM/WolbachiaEvolHist_2023/scripts/DiagnosticSNPs.py \
    --input /Volumes/HTCTFTCAM/WolbachiaEvolHist_2023/Wolb.vcf.gz \
    --MinCov 2 \
    --output /Volumes/HTCTFTCAM/WolbachiaEvolHist_2023/output/Variants/variants \
    --Variant /Volumes/HTCTFTCAM/WolbachiaEvolHist_2023/GT.txt

echo '''

library(tidyverse)

DATA=read.table("/Volumes/HTCTFTCAM/WolbachiaEvolHist_2023/output/Variants/variants_variants.txt",
    header=T)

Sums <- DATA %>%
    filter(Sample != "wYak") %>%
    group_by(Sample,Variant) %>%
    summarize(Sum=n())

Plot<-ggplot(Sums,aes(x=Sample,y=Sum,fill=Variant))+
    geom_bar(stat="identity")+
    theme_bw()+
    scale_fill_manual(values = c( "blue3","firebrick3"))

ggsave("/Volumes/HTCTFTCAM/WolbachiaEvolHist_2023/output/Variants/variants_variants.pdf",
    Plot,
    width=9,
    height=4)

''' >/Volumes/HTCTFTCAM/WolbachiaEvolHist_2023/output/Variants/variants_variants.r

Rscript /Volumes/HTCTFTCAM/WolbachiaEvolHist_2023/output/Variants/variants_variants.r
