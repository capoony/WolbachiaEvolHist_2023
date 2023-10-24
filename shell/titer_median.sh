PWD=/media/inter/mkapun/projects/WolbachiaEvolHist_2023

module load Tools/samtools-1.12

while read -r ID; do

    i=${PWD}/results/mapping_full/${ID}.bam

    #samtools index $i

    samtools depth $i |
        python ${PWD}/scripts/median_depth.py \
            --input - |
        awk -v ID=$ID 'NR>1{print ID"\t"$0}' >${PWD}/results/titer/Full_coverages_${ID}_median.txt &

done <${PWD}/datasets/AllSamples.txt

cat ${PWD}/results/titer/Full_coverages_*_median.txt | awk '{print $1"\t"$2"\tNA\tNA\tNA\tNA\tNA\t"$3"\tNA\tNA"}' >${PWD}/results/titer/Full_coverages_median.txt

python ${PWD}/scripts/SumReadDepths_median.py \
    --input ${PWD}/results/titer/Full_coverages.txt \
    --median ${PWD}/results/titer/Full_coverages_median.txt \
    --names ${PWD}/data/names.txt \
    --status ${PWD}/data_old/OldStuff/output/ReadDepths/InfStatus.txt \
    >${PWD}/results/titer/Full_coverages_median.summary

echo """

library(tidyverse)
library(scales)
DATA=read.table('${PWD}/results/titer/Full_coverages_median.summary',
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


ggsave('${PWD}/results/titer/Full_coverages_full_median.pdf',
    PLOT,
    width=10,
    height=6)

ggsave('${PWD}/results/titer/Full_coverages_full_median.png',
    PLOT,
    width=10,
    height=6)

""" >${PWD}/results/titer/Full_coverages_median.r

Rscript ${PWD}/results/titer/Full_coverages_median.r

## copy to output folder
mkdir ${PWD}/data_old/OldStuff/output/titer

cp ${PWD}/results/titer/Full_coverages.p* ${PWD}/data_old/OldStuff/output/titer

cp ${PWD}/results/titer/Full_coverages.summary ${PWD}/data_old/OldStuff/output/titer

cp ${PWD}/results/titer/Full_coverages_full.p* ${PWD}/data_old/OldStuff/output/titer
