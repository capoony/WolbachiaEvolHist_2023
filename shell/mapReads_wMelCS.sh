## Map reads for Wolbachia wMelCS

## get refernce genome; downloaded manually from https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_014354335.1/ and stored as /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/GCF_014354335.1_ASM1435433v1_genomic.fna

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_wMelCS
module load NGSmapper/bwa-0.7.13

gzip /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/GCF_014354335.1_ASM1435433v1_genomic.fna

## index reference
module load NGSmapper/bwa-0.7.13
bwa index /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/GCF_014354335.1_ASM1435433v1_genomic.fna.gz

for ID in 380 HG_16 HG_14 HG_17 HG_18 HG_19 HG_21 HG0021 HG0025 HG0028 HG0035 HG29702 HG47203 376 377 378 HG_09 HG_15 HG_16 HG_20 HG0026 HG0027 HG0029 HG0034 HG47203 HG47204 HG47205 CK2 DGRP335 DGRP338 ED2 ED3 ED6N ED10N EZ2 GA125 KN34 KR7 RG3 RG5 RG34 SP80 TZ14 UG5N ZI268 ZO12 ZS11 wMelCS wMelCSb; do

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N Annotation_${Species}

    ## Redirect output stream to this file.
    #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_wMelCS/${ID}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select a maximum walltime of 2h
    #PBS -l walltime=100:00:00

    ## Select a maximum of 20 cores and 500gb of RAM
    #PBS -l select=1:ncpus=50:mem=100gb

    ### dependenceies

    module load NGSmapper/bwa-0.7.13
    module load NGSmapper/minimap2-2.17
    module load Tools/samtools-1.12

    bwa mem \
        -t 50 \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/GCF_014354335.1_ASM1435433v1_genomic.fna.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/${ID}_1.fq.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/${ID}_2.fq.gz |
        samtools view  -F 4 -bh | samtools sort \
        >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_wMelCS/${ID}.bam

    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_mapping.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_mapping.qsub

done

## now map also DGRP335
ID=DGRP335
module load NGSmapper/bwa-0.7.13
module load NGSmapper/minimap2-2.17
module load Tools/samtools-1.12

bwa mem \
    -t 50 \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/GCF_014354335.1_ASM1435433v1_genomic.fna.gz \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/${ID}.fq.gz |
    samtools view -F 4 -bh | samtools sort \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_wMelCS/${ID}.bam

### now also map ONT reads
Samples=(Re1_full Re3 Re6_full Re10 Ak7_full Ak9_full MEL_full CS POP)

module load NGSmapper/minimap2-2.17
module load Tools/samtools-1.12

for i in ${!Samples[*]}; do
    Sample=${Samples[i]}

    echo $i ${Sample}

    minimap2 -ax map-ont \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/GCF_014354335.1_ASM1435433v1_genomic.fna.gz \
        /media/inter/mkapun/projects/DrosoWolbGenomics/results/assemblies/${Sample}/data/ONT/${Sample}_ont.fq.gz |
        samtools view -bh | samtools sort \
        >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_wMelCS/${Sample}.bam

    samtools index /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_wMelCS/${Sample}.bam

done

####

module load Tools/bcftools-1.16
module load Tools/samtools-1.12

## make BAMlist

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData_wMelCS
for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_wMelCS/*.bam; do
    echo $i >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData_wMelCS/bamlist_Wolb.txt

done

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_wMelCS/*.bam; do
    samtools index $i &
done

gunzip /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/GCF_014354335.1_ASM1435433v1_genomic.fna.gz

## SNP calling of Wolbachia reads
bcftools mpileup \
    -Bf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/GCF_014354335.1_ASM1435433v1_genomic.fna \
    -b /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData_wMelCS/bamlist_Wolb.txt \
    -a AD,DP \
    -d 1000 \
    -Ou |
    bcftools call \
        -O z --ploidy 1 \
        -c \
        -v \
        -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData_wMelCS/Wolb.vcf.gz

## select SNPs and make phylip input
gzip /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/Wolb_Burkholderia.fna
python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/BCF2Phylip.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData_wMelCS/Wolb.vcf.gz \
    --MinAlt 1 \
    --MaxPropGaps 0.5 \
    --MinCov 5 \
    --exclude 377,378,380,HG0029,HG0027,HG0034,wYak \
    --names /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/names.txt \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData_wMelCS/Wolb.phy

## make phylogenetic tree
sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/makePhylo_MidpointRoot.sh \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Wolb_wMelCS \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData_wMelCS/Wolb.phy \
    Wolbachia \
    0.1 \
    8 \
    8 \
    no
