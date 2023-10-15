printf "#ID\trname\tstartpos\tendpos\tnumreads\tcovbases\tcoverage\tmeandepth\tmeanbaseq\tmeanmapq\n" >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages.txt

module load Tools/samtools-1.12

for ID in 380 HG_16 HG_14 HG_17 HG_18 HG_19 HG_21 HG0021 HG0025 HG0028 HG0035 HG29702 HG47203 376 377 378 HG_09 HG_15 HG_16 HG_20 HG0026 HG0027 HG0029 HG0034 HG47203 HG47204 HG47205 Re1_full Re3 Re6_full Re10 Ak7_full Ak9_full MEL_full CS POP CK2 DGRP335 DGRP338 DGRP88 DGRP857 DGRP427 ED2 ED3 ED6N ED10N EZ2 GA125 KN34 KR7 RG3 RG5 RG34 SP80 TZ14 UG5N ZI268 ZO12 ZS11; do

    i=/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/${ID}.bam

    samtools index $i

    samtools coverage $i | awk -v ID=$ID 'NR>1{print ID"\t"$0}' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages_${ID}.txt

done

rm -f /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages.txt
for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages*.txt; do

    if [[ ! $i == *_mean* && ! $i == *_median* ]]; then

        cat $i >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages.txt
    fi
done

## summarize and make a pivot table
python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/SumReadDepths.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages.txt \
    --names /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data_old/OldStuff/output/NAMES_CORRECT \
    --status /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data_old/OldStuff/output/ReadDepths/InfStatus.txt \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages.summary

echo """

library(tidyverse)
library(scales)
DATA=read.table('/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages.summary',
    header=T,
    sep='\t')

color <- c('blue3', 'firebrick3','white','grey')

DATA\$WolbachiaType <- factor(DATA\$WolbachiaType, levels=c('wMel','wMelCS','uninfected','unclear'))

PLOT<-ggplot(DATA,
    aes(x=reorder(ID, WolbTiter),fill=WolbachiaType,y=WolbTiter))+
    geom_bar(stat='identity',col='black')+
    facet_grid(.~Type,scales='free_x',space='free_x')+
    scale_fill_manual(values=color)+
    xlab('Sample ID')+
    ylab('relative Wolbachia titer')+
    theme_bw()+
    geom_hline(yintercept=1,lty=2)+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))+
    scale_y_log10(breaks = trans_breaks(\"log10\", function(x) 10^x)) +
    annotation_logticks(sides=\"l\")  


ggsave('/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages_full.pdf',
    PLOT,
    width=10,
    height=6)

ggsave('/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages_full.png',
    PLOT,
    width=10,
    height=6)

""" >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages.r

Rscript /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages.r

## copy to output folder
mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data_old/OldStuff/output/titer

cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages.p* /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data_old/OldStuff/output/titer

cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages.summary /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data_old/OldStuff/output/titer

cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages_full.p* /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data_old/OldStuff/output/titer

## finally, I manually merged the titer estimates and the dates in Excel and plot accoridng to date.

echo """

library(tidyverse)
library(scales)
library(gridExtra)
library(stringr)

DATA=read.table('/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/titer_dates.txt',
    header=T,
    sep='\t')

color <- c('blue3', 'firebrick3','white','grey')


DATA$WolbachiaType <- factor(DATA$WolbachiaType, levels=c('wMel','wMelCS','uninfected','unclear'))

PLOT.1<-ggplot(DATA,
    aes(x=reorder(ID,Titer),fill=WolbachiaType,y=Titer))+
    geom_bar(stat='identity',color='black')+
    facet_grid(.~Date,scales='free_x',space='free_x')+
    scale_fill_manual(values=color)+
    xlab('Sample ID')+
    ylab('relative Wolbachia titer')+
    theme_bw()+
    geom_hline(yintercept=1,lty=2)+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))+
    scale_y_log10(breaks = trans_breaks('log10', function(x) 10^x)) +
    annotation_logticks(sides='l')  
PLOT.1

PLOT.2<-ggplot(DATA,
    aes(x=reorder(ID,Titer),fill=WolbachiaType,y=Titer))+
    geom_bar(stat='identity',color='black')+
    facet_grid(.~str_wrap(Origin, width = 8),scales='free_x',space='free_x')+
    scale_fill_manual(values=color)+
    xlab('Sample ID')+
    ylab('relative Wolbachia titer')+
    theme_bw()+
    geom_hline(yintercept=1,lty=2)+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))+
    scale_y_log10(breaks = trans_breaks('log10', function(x) 10^x)) +
    annotation_logticks(sides='l') 
PLOT.2

PLOT<-grid.arrange(PLOT.1,PLOT.2,nrow=2)


ggsave('/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages_date_or.pdf',
    PLOT,
    width=24,
    height=12)

ggsave('/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages_date_or.png',
    PLOT,
    width=24,
    height=12)

""" >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages.r

Rscript /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_full/Full_coverages.r
