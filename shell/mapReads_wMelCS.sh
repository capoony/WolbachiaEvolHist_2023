## Map reads for Wolbachia wMelCS
PWD=/media/inter/mkapun/projects/WolbachiaEvolHist_2023

## get refernce genome; downloaded manually from https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_014354335.1/ and stored as ${PWD}/data/GCF_014354335.1_ASM1435433v1_genomic.fna

mkdir ${PWD}/results/mapping_wMelCS
module load NGSmapper/bwa-0.7.13

gzip ${PWD}/data/GCF_014354335.1_ASM1435433v1_genomic.fna

## index reference
module load NGSmapper/bwa-0.7.13
bwa index ${PWD}/data/GCF_014354335.1_ASM1435433v1_genomic.fna.gz

for ID in 380 HG_16 HG_14 HG_17 HG_18 HG_19 HG_21 HG0021 HG0025 HG0028 HG0035 HG29702 HG47203 376 377 378 HG_09 HG_15 HG_16 HG_20 HG0026 HG0027 HG0029 HG0034 HG47203 HG47204 HG47205 CK2 DGRP370 DGRP646 DGRP335 DGRP338 ED2 ED3 ED6N ED10N EZ2 GA125 KN34 KR7 RG3 RG5 RG34 SP80 TZ14 UG5N ZI268 ZO12 ZS11 wMelCS wMelCSb; do

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N Annotation_${Species}

    ## Redirect output stream to this file.
    #PBS -o ${PWD}/results/mapping_wMelCS/${ID}_log.txt

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
        ${PWD}/data/GCF_014354335.1_ASM1435433v1_genomic.fna.gz \
        ${PWD}/results/kraken/${ID}_1.fq.gz \
        ${PWD}/results/kraken/${ID}_2.fq.gz |
        samtools view  -F 4 -bh | samtools sort \
        >${PWD}/results/mapping_wMelCS/${ID}.bam

    """ >${PWD}/shell/QSUB/${ID}_mapping.qsub

    sh ${PWD}/shell/QSUB/${ID}_mapping.qsub

done

## now map also DGRP335
ID=DGRP335
module load NGSmapper/bwa-0.7.13
module load NGSmapper/minimap2-2.17
module load Tools/samtools-1.12

bwa mem \
    -t 50 \
    ${PWD}/data/GCF_014354335.1_ASM1435433v1_genomic.fna.gz \
    ${PWD}/results/kraken/${ID}.fq.gz |
    samtools view -F 4 -bh | samtools sort \
    >${PWD}/results/mapping_wMelCS/${ID}.bam

### now also map ONT reads
Samples=(Re1_full Re3 Re6_full Re10 Ak7_full Ak9_full MEL_full CS POP)

module load NGSmapper/minimap2-2.17
module load Tools/samtools-1.12

for i in ${!Samples[*]}; do
    Sample=${Samples[i]}

    echo $i ${Sample}

    minimap2 -ax map-ont \
        ${PWD}/data/GCF_014354335.1_ASM1435433v1_genomic.fna.gz \
        /media/inter/mkapun/projects/DrosoWolbGenomics/results/assemblies/${Sample}/data/ONT/${Sample}_ont.fq.gz |
        samtools view -bh | samtools sort \
        >${PWD}/results/mapping_wMelCS/${Sample}.bam

    samtools index ${PWD}/results/mapping_wMelCS/${Sample}.bam

done

####

module load Tools/bcftools-1.16
module load Tools/samtools-1.12

## make BAMlist

mkdir ${PWD}/results/MergedData_wMelCS
for i in ${PWD}/results/mapping_wMelCS/*.bam; do
    echo $i >>${PWD}/results/MergedData_wMelCS/bamlist_Wolb.txt

done

for i in ${PWD}/results/mapping_wMelCS/*.bam; do
    samtools index $i &
done

gunzip ${PWD}/data/GCF_014354335.1_ASM1435433v1_genomic.fna.gz

## SNP calling of Wolbachia reads
bcftools mpileup \
    -Bf ${PWD}/data/GCF_014354335.1_ASM1435433v1_genomic.fna \
    -b ${PWD}/results/MergedData_wMelCS/bamlist_Wolb.txt \
    -a AD,DP \
    -d 1000 \
    -Ou |
    bcftools call \
        -O z --ploidy 1 \
        -c \
        -v \
        -o ${PWD}/results/MergedData_wMelCS/Wolb.vcf.gz

## select SNPs and make phylip input
gzip ${PWD}/data/Wolb_Burkholderia.fna
python ${PWD}/scripts/BCF2Phylip.py \
    --input ${PWD}/results/MergedData_wMelCS/Wolb.vcf.gz \
    --MinAlt 1 \
    --MaxPropGaps 0.6 \
    --MinCov 5 \
    --exclude 377,378,380,HG0029,HG0027,HG0034,wYak \
    --names ${PWD}/data/names.txt \
    >${PWD}/results/MergedData_wMelCS/Wolb.phy

## make phylogenetic tree
sh ${PWD}/shell/makePhylo_MidpointRoot.sh \
    ${PWD}/results/phylogney/Wolb_wMelCS \
    ${PWD}/results/MergedData_wMelCS/Wolb.phy \
    Wolbachia \
    0.1 \
    8 \
    8 \
    no

echo '''
library(tidyverse)
library(phytools)
library(dendextend)
library(phylogram) # to make dendrograms from non-ultrametric trees
library(ape) # to import NEXUS and to plot co-phyloplots

Tree.wMel<-midpoint.root(read.tree("${PWD}/results/phylogney/Wolb/RAxML_bipartitions.FINAL_snps"))

wMel.ultra=as.dendrogram(chronos(Tree.wMel, lambda=0) )
# wMel.unmatched <- as.dendrogram(multi2di(wMel.ultra, random=TRUE) )
# plot(wMel.unmatched)

## load Mitodata based on amino acids and match UCE labels
Tree.wMelCS<-midpoint.root(read.tree("${PWD}/results/phylogney/Wolb_wMelCS/RAxML_bipartitions.FINAL_snps"))

wMelCS.ultra=as.dendrogram(chronos(Tree.wMelCS, lambda=0) )
# wMelCS.unmatched <- as.dendrogram(multi2di(wMelCS.ultra, random=TRUE) )
# plot(wMelCS.unmatched)

dndlist<-dendlist("wMel_ref"=wMel.ultra,"wMelCS_ref"=wMelCS.ultra)

pdf("${PWD}/results/MergedData_wMelCS/Tanglegram.pdf",
    width=6,
    height=6)
dndlist %>% untangle(method = "step1side") %>% 
    tanglegram(common_subtrees_color_branches = TRUE, 
        highlight_branches_lwd = FALSE,
        margin_inner = 5,
        edge.lwd=3)
dev.off()

png("${PWD}/results/MergedData_wMelCS/Tanglegram.png",
    width=6,
    height=6,
    units="in",
    res=300)
dndlist %>% untangle(method = "step1side") %>% 
    tanglegram(common_subtrees_color_branches = TRUE, 
        highlight_branches_lwd = FALSE,
        margin_inner = 5,
        edge.lwd=3)
dev.off()

''' >${PWD}/results/MergedData_wMelCS/plot.r

Rscript ${PWD}/results/MergedData_wMelCS/plot.r
