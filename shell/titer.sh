PWD=/media/inter/mkapun/projects/WolbachiaEvolHist_2023

mkdir ${PWD}/results/titer

module load Tools/samtools-1.12

while read -r ID; do

    i=${PWD}/results/mapping_full/${ID}.bam

    samtools index $i

    samtools coverage $i | awk -v ID=$ID 'NR>1{print ID"\t"$0}' >${PWD}/results/titer/Full_coverages_${ID}.txt

done <${PWD}/datasets/AllSamples.txt

rm -f ${PWD}/results/titer/Full_coverages.txt

printf "#ID\trname\tstartpos\tendpos\tnumreads\tcovbases\tcoverage\tmeandepth\tmeanbaseq\tmeanmapq\n" >${PWD}/results/titer/Full_coverages.txt

for i in ${PWD}/results/titer/Full_coverages*.txt; do

    if [[ ! $i == *_mean* && ! $i == *_median* ]]; then

        cat $i >>${PWD}/results/titer/Full_coverages.txt
    fi
done

## summarize and make a pivot table
python ${PWD}/scripts/SumReadDepths.py \
    --input ${PWD}/results/titer/Full_coverages.txt \
    --names ${PWD}/datasets/NAMES_CORRECT \
    --status ${PWD}/datasets/InfStatus.txt \
    >${PWD}/results/titer/Full_coverages.summary

echo """

library(tidyverse)
library(scales)
DATA=read.table('${PWD}/results/titer/Full_coverages.summary',
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


ggsave('${PWD}/results/titer/Full_coverages_full.pdf',
    PLOT,
    width=10,
    height=6)

ggsave('${PWD}/results/titer/Full_coverages_full.png',
    PLOT,
    width=10,
    height=6)

""" >${PWD}/results/titer/Full_coverages.r

Rscript ${PWD}/results/titer/Full_coverages.r

## copy to output folder
mkdir ${PWD}/data_old/OldStuff/output/titer

cp ${PWD}/results/mapping_full/Full_coverages.p* ${PWD}/data_old/OldStuff/output/titer

cp ${PWD}/results/mapping_full/Full_coverages.summary ${PWD}/data_old/OldStuff/output/titer

cp ${PWD}/results/mapping_full/Full_coverages_full.p* ${PWD}/data_old/OldStuff/output/titer

## finally, I manually merged the titer estimates and the dates in Excel and plot accoridng to date.

echo """

library(tidyverse)
library(scales)
library(gridExtra)
library(stringr)

DATA=read.table('${PWD}/results/titer/titer_dates.txt',
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


ggsave('${PWD}/results/titer/Full_coverages_date_or.pdf',
    PLOT,
    width=24,
    height=12)

ggsave('${PWD}/results/titer/Full_coverages_date_or.png',
    PLOT,
    width=24,
    height=12)

""" >${PWD}/results/titer/Full_coverages.r

Rscript ${PWD}/results/titer/Full_coverages.r
