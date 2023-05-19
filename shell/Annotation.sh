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
