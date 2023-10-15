module load Tools/samtools-1.12

for ID in 380 HG_16 HG_14 HG_17 HG_18 HG_19 HG_21 HG0021 HG0025 HG0028 HG0035 HG29702 HG47203 376 377 378 HG_09 HG_15 HG_16 HG_20 HG0026 HG0027 HG0029 HG0034 HG47203 HG47204 HG47205 Re1_full Re3 Re6_full Re10 Ak7_full Ak9_full MEL_full CS POP CK2 DGRP335 DGRP338 ED2 ED3 ED6N ED10N EZ2 GA125 KN34 KR7 RG3 RG5 RG34 SP80 TZ14 UG5N ZI268 ZO12 ZS11; do

    i=/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/${ID}.bam

    #samtools index $i

    samtools depth $i |
        python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/median_depth.py \
            --input - |
        awk -v ID=$ID 'NR>1{print ID"\t"$0}' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages_${ID}_median.txt &

done

cat /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages_*_median.txt | awk '{print $1"\t"$2"\tNA\tNA\tNA\tNA\tNA\t"$3"\tNA\tNA"}' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages_median.txt

python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/SumReadDepths_median.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages.txt \
    --median /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages_median.txt \
    --names /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/names.txt \
    --status /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data_old/OldStuff/output/ReadDepths/InfStatus.txt \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages_median.summary

echo """

library(tidyverse)
library(scales)
DATA=read.table('/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages_median.summary',
    header=T)

color <- c('blue3', 'firebrick3','black','white')


DATA\$WolbachiaType <- factor(DATA\$WolbachiaType, levels=c('wMel','wMelCS','wMelPop','None'))

PLOT<-ggplot(DATA,
    aes(x=reorder(ID, WolbTiter),fill=WolbachiaType,y=WolbTiter,col=InfectionStatus))+
    geom_bar(stat='identity')+
    facet_grid(.~Type,scales='free_x',space='free_x')+
    scale_fill_manual(values=color)+
    xlab('Sample ID')+
    ylab('relative Wolbachia titer')+
    theme_bw()+
    geom_hline(yintercept=1,lty=2)+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))+
    scale_y_log10(breaks = trans_breaks(\"log10\", function(x) 10^x)) +
    annotation_logticks(sides=\"l\")  


ggsave('/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages_full_median.pdf',
    PLOT,
    width=10,
    height=6)

ggsave('/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages_full_median.png',
    PLOT,
    width=10,
    height=6)

""" >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages_median.r

Rscript /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages_median.r

## copy to output folder
mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data_old/OldStuff/output/titer

cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages.p* /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data_old/OldStuff/output/titer

cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages.summary /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data_old/OldStuff/output/titer

cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages_full.p* /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data_old/OldStuff/output/titer
