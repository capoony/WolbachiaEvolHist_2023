PWD=/media/inter/mkapun/projects/WolbachiaEvolHist_2023

module load Tools/bcftools-1.16
module load Tools/samtools-1.12

### for Wolbachia

## make BAMlist
for i in ${PWD}/results/mapping/*.bam; do
    echo $i >>${PWD}/results/MergedData/bamlist_Wolb.txt

done

Samples=(Re1_full Re3 Re6_full Re10 Ak7_full Ak9_full MEL_full CS POP)

for i in ${!Samples[*]}; do
    Sample=${Samples[i]}

    echo /media/inter/mkapun/projects/DrosoWolbGenomics/results/RefMapping/${Sample}.bam \
        >>${PWD}/results/MergedData/bamlist_Wolb.txt

done

### now index mapped BAM flies

for i in ${PWD}/results/mapping/*.bam; do
    samtools index $i
done

## now exclude libraries which, based on the BLOBtools analyses do not contain Wolbachia or less than XXX reads mapped to the reference
gunzip ${PWD}/data/Wolb_Burkholderia.fna.gz

## SNP calling of Wolbachia reads
bcftools mpileup \
    -Bf ${PWD}/data/Wolb_Burkholderia.fna \
    -b ${PWD}/results/MergedData/bamlist_Wolb_stringent.txt \
    -a AD,DP \
    -d 1000 \
    -r "ENA|AE017196|AE017196.1" \
    -Ou |
    bcftools call \
        -O z --ploidy 1 \
        -c \
        -v \
        -o ${PWD}/results/MergedData/Wolb.vcf.gz

## select SNPs and make phylip input
gzip ${PWD}/data/Wolb_Burkholderia.fna
python ${PWD}/scripts/BCF2Phylip.py \
    --input ${PWD}/results/MergedData/Wolb.vcf.gz \
    --MinAlt 1 \
    --MaxPropGaps 0.5 \
    --MinCov 5 \
    --exclude 377,378,380,HG0029,HG0027,HG0034,wYak \
    --names ${PWD}/data/names.txt \
    >${PWD}/results/MergedData/Wolb.phy

## make phylogenetic tree
sh ${PWD}/shell/makePhylo_MidpointRoot.sh \
    ${PWD}/results/phylogney/Wolb \
    ${PWD}/results/MergedData/Wolb.phy \
    Wolbachia \
    0.1 \
    8 \
    8 \
    no

## repeat SNP selection with relaxed parameters to include all samples
python ${PWD}/scripts/BCF2Phylip.py \
    --input ${PWD}/results/MergedData/Wolb.vcf.gz \
    --MinAlt 1 \
    --MaxPropGaps 0.9 \
    --MinCov 2 \
    --exclude wYak \
    --names ${PWD}/data/names.txt \
    >${PWD}/results/MergedData/Wolb_full.phy

sh ${PWD}/shell/makePhylo_MidpointRoot.sh \
    ${PWD}/results/phylogney/Wolb_full \
    ${PWD}/results/MergedData/Wolb_full.phy \
    Wolbachia \
    0.1 \
    200 \
    8 \
    yes

cp ${PWD}/results/phylogney/Wolb/Wolbachia.pdf ${PWD}/output/Phylogeny/Wolbachia_SNPs.pdf
cp ${PWD}/results/phylogney/Wolb/Wolbachia.png ${PWD}/output/Phylogeny/Wolbachia_SNPs.png

cp ${PWD}/results/phylogney/Wolb_full/Wolbachia.pdf ${PWD}/output/Phylogeny/Wolbachia_SNPs_full.pdf
cp ${PWD}/results/phylogney/Wolb_full/Wolbachia.png ${PWD}/output/Phylogeny/Wolbachia_SNPs_full.png

### repeat for Mitochondria

rm -rf ${PWD}/results/MergedData/bamlist_Mito.txt

for i in ${PWD}/results/mapping_mito/*.bam; do
    echo $i >>${PWD}/results/MergedData/bamlist_Mito.txt

done

printf "#ID\trname\tstartpos\tendpos\tnumreads\tcovbases\tcoverage\tmeandepth\tmeanbaseq\tmeanmapq\n" >${PWD}/results/MergedData/Mito_coverages.txt

for i in ${PWD}/results/mapping_mito/*.bam; do

    tmp=${i##*/}
    ID=${tmp%.*}

    samtools coverage $i | awk -v ID=$ID 'NR>1{print ID"\t"$0}' >>${PWD}/results/MergedData/Mito_coverages.txt

done

bcftools mpileup \
    -Bf ${PWD}/data/db/NC_024511.2_start.fasta \
    -b ${PWD}/results/MergedData/bamlist_Mito.txt \
    -a AD,DP \
    -d 1000 \
    -Ou |
    bcftools call \
        -O z --ploidy 1 \
        -c \
        -v \
        -o ${PWD}/results/MergedData/Mito.vcf.gz

python ${PWD}/scripts/BCF2Phylip.py \
    --input ${PWD}/results/MergedData/Mito.vcf.gz \
    --MinAlt 1 \
    --MaxPropGaps 0.5 \
    --MinCov 2 \
    --names ${PWD}/data/names.txt \
    --exclude mtDyak \
    >${PWD}/results/MergedData/Mito.phy

sh ${PWD}/shell/makePhylo_MidpointRoot.sh \
    ${PWD}/results/phylogney/Mito \
    ${PWD}/results/MergedData/Mito.phy \
    Mitchondria \
    0.05 \
    8 \
    8 \
    no

cp ${PWD}/results/phylogney/Mito/Mitchondria.pdf ${PWD}/output/Phylogeny/Mitochondria_SNPs_full.pdf
cp ${PWD}/results/phylogney/Mito/Mitchondria.png ${PWD}/output/Phylogeny/Mitochondria_SNPs_full.png
