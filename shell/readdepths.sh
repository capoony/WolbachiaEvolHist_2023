mkdir -p /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/ReadDepths/log

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/*; do

    ID=${i##*/}

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N Kraken_${ID}

    ## Redirect output stream to this file.
    #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/ReadDepths/${ID}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select 50 cores and 300gb of RAM
    #PBS -l select=1:ncpus=50:mem=300g

    ######## load dependencies #######

    module load Assembly/kraken-2.1.2

    DBNAME=/media/scratch/kraken-2.1.2/db/DrosoWolb 

    kraken2 \
        --threads 100 \
        --gzip-compressed \
        --paired \
        --report /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/ReadDepths/${ID}.report \
        --use-names \
        --db \$DBNAME \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/${ID}_1.fastq.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/${ID}_2.fastq.gz  > /dev/null
        
    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_cov.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_cov.qsub

done

module load Tools/samtools-1.12

samtools depth -f /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/bamlist_Wolb_stringent.txt >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/ReadDepths/WolbStringent.cov

python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/cov_Sliding.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/ReadDepths/WolbStringent.cov \
    --window 1000 \
    --Syn /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/names.txt \
    --names 377,378,380,HG0026,HG0027,HG0034,HG0029,HG_09,HG_15,HG_16,HG_20,HG47203,HG47204,wMelCS,wMelCSb,wMel_donor,wMel_Indiana,wMel_run1,Re1_full,Re3,Re6_full,Re10,Ak7_full,Ak9_full,MEL_full,CS,POP \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/ReadDepths/WolbStringent_1kb.cov

echo '''

library(tidyverse)
DATA=read.table("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/ReadDepths/WolbStringent_1kb.cov",header=T)

DATA.long <- DATA %>%
    gather(Sample,ReadDepth, Sweden_Lund_1800_377:wMelCSPOP_LabStrain_Gulbenkian)

PLOT<-ggplot(DATA.long,aes(x=Pos,y=ReadDepth))+
    geom_bar(stat="identity")+
    facet_wrap(~Sample,ncol=1,scales="free_y", strip.position = "right")+
    theme_bw()+
    xlab("Position")+
    theme(strip.text.y.right = element_text(angle = 0))+
     annotate("rect", xmin=497224, xmax=505755, ymin=-Inf, ymax=Inf,alpha=0.1,fill="blue")


ggsave("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/ReadDepths/WolbStringent_1kb.pdf",
    PLOT,
    width=16,
    height=12)

''' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/ReadDepths/WolbStringent_1kb.r

Rscript /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/ReadDepths/WolbStringent_1kb.r

module load Tools/samtools-1.12

printf " #ID\trname\tstartpos\tendpos\tnumreads\tcovbases\tcoverage\tmeandepth\tmeanbaseq\tmeanmapq\n" >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb_coverages.txt

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/*.bam; do

    tmp=${i##*/}
    ID=${tmp%.*}

    samtools coverage $i | awk -v ID=$ID 'NR>1{print ID"\t"$0}' >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb_coverages.txt

done

Samples=(Re1_full Re3 Re6_full Re10 Ak7_full Ak9_full MEL_full CS POP)

for i in ${!Samples[*]}; do
    Sample=${Samples[i]}

    samtools coverage /media/inter/mkapun/projects/DrosoWolbGenomics/results/RefMapping/${Sample}.bam |
        awk -v ID=${Sample} 'NR>1{print ID"\t"$0}' >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb_coverages.txt

done

sed 's/\t/|/g' /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb_coverages.txt | awk '{print "|"$0"|"}' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Wolb_coverages.txt
