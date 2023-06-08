cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db

curl -O https://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/Wolbachia_endosymbiont_of_Drosophila_melanogaster/latest_assembly_versions/GCF_000008025.1_ASM802v1/GCF_000008025.1_ASM802v1_protein.faa.gz

gunzip /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/GCF_000008025.1_ASM802v1_protein.faa.gz

mkdir -p /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Annotation/log

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/*_1.fq.gz; do
  tmp=${i##*/}
  Species=${tmp%_*}
  echo ${Species}
  echo """

    #!/bin/sh

    ## name of Job
    #PBS -N Annotation_${Species}

    ## Redirect output stream to this file.
    #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Annotation/log/${Species}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select a maximum walltime of 2h
    #PBS -l walltime=100:00:00

    ## Select a maximum of 20 cores and 500gb of RAM
    #PBS -l select=1:ncpus=2:mem=10gb

    ## load all necessary software into environment
    source /opt/anaconda3/etc/profile.d/conda.sh
    conda activate exonerate-2.4.0

    ## gapped alignment a la Smith-Waterman, reporting only alignments with 75% of the maximal score optainable for that query and only the best hit for that query

    mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Annotation/${Species}

    #gunzip /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/${Species}/output/${Species}_ILL.fa.gz

    exonerate \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/GCF_000008025.1_ASM802v1_protein.faa \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/${Species}/output/${Species}_ILL.fa \
        --showtargetgff \
        --showalignment  \
        --showvulgar \
        --showsugar \
        --model protein2genome \
        --percent 80 \
        --bestn 1 \
        --ryo \">${Species}_%qi_%qd_%ti_(%tab-%tae)\n%tas\n\" \
      >> /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Annotation/${Species}/${Species}_genes.full

    python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/parseExonerate.py \
      --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Annotation/${Species}/${Species}_genes.full \
      --output /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Annotation/${Species}/${Species}_genes

    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${Species}_Annotation.sh

  qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${Species}_Annotation.sh
done

Spec=(Re1_full Re3 Re6_full Re10 Ak7_full Ak9_full MEL_full CS POP)
Names=(Portugal_wMel_Re1 Portugal_wMelCS_Re3 Portugal_wMel_Re6 Portugal_wMelCS_Re10 Finland_wMel_AK7 Finland_wMel_AK9 w1118_wMel w1118_wMelCS w1118_wMelPop)

Species=POP
Name=w1118_wMelPop
for i in ${!Spec[*]}; do
  Species=${Spec[i]}
  Name=${Names[i]}
  echo """

    #!/bin/sh

    ## name of Job
    #PBS -N Annotation_${Species}

    ## Redirect output stream to this file.
    #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Annotation/log/${Species}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select a maximum walltime of 2h
    #PBS -l walltime=100:00:00

    ## Select a maximum of 20 cores and 500gb of RAM
    #PBS -l select=1:ncpus=2:mem=10gb

    ## load all necessary software into environment
    source /opt/anaconda3/etc/profile.d/conda.sh
    conda activate exonerate-2.4.0

    ## gapped alignment a la Smith-Waterman, reporting only alignments with 75% of the maximal score optainable for that query and only the best hit for that query

    mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Annotation/${Species}

    exonerate \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/GCF_000008025.1_ASM802v1_protein.faa \
        /media/inter/mkapun/projects/DrosoWolbGenomics/results/WolbGenomes/${Name}/nucmer/${Name}.fasta \
        --showtargetgff \
        --showalignment  \
        --showvulgar \
        --showsugar \
        --model protein2genome \
        --percent 80 \
        --bestn 1 \
        --ryo \">${Species}_%qi_%qd_%ti_(%tab-%tae)\n%tas\n\" \
      >> /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Annotation/${Species}/${Species}_genes.full

    python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/parseExonerate.py \
      --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Annotation/${Species}/${Species}_genes.full \
      --output /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Annotation/${Species}/${Species}_genes

    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${Species}_Annotation.sh

  qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${Species}_Annotation.sh
done

printf "ID\tGene\tStart\tEnd\tType\n" >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Annotation/Summary.txt

for ID in HG_09 HG_15 HG_16 HG_20 HG0026 HG47203 HG47204 Re1_full Re3 Re6_full Re10 Ak7_full Ak9_full MEL_full CS POP; do

  python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/SummarizeExonerate.py \
    --gff /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/GCF_000008025.1/genomic.gff \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Annotation/${ID}/${ID}_genes.alignment \
    --Name ${ID} \
    --EXName /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/names.txt \
    >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Annotation/Summary.txt

done

echo '''

library(tidyverse)

DATA=read.table("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Annotation/Summary.txt",
  header=T,
  sep="\t")

DATA.wide <- DATA %>% 
  spread(ID,Type)

write.table(file="/media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/busco/Annotation.txt",
  DATA.wide,
  quote=F,
  row.names=F)


PLOT=ggplot(DATA,aes(group=Gene))+
  geom_rect(aes(xmin = Start, xmax = End, ymin = 0, ymax = 1,fill=Type))+
  facet_grid(ID~.)+
    theme_bw()+
  scale_fill_manual(values=c("blue","orange","red","grey","purple"))+
   theme(
        axis.text.y=element_blank(),  #remove y axis labels
        axis.ticks.y=element_blank()  #remove y axis ticks
        )+
  theme(strip.text.y.right = element_text(angle = 0))+ 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) + 
  scale_x_continuous(breaks=seq(0, 1300000, 250000))


ggsave("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/busco/Annotation.pdf",
  PLOT,
  width=10,
  height=4)

ggsave("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/busco/Annotation.png",
  PLOT,
  width=10,
  height=4)

''' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/busco/Annotation.r

Rscript /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/busco/Annotation.r

python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/GeneFunctFromGFF.py \
  --gff /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/GCF_000008025.1/genomic.gff \
  >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/busco/function.txt
