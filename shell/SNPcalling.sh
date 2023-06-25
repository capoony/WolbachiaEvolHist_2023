module load Tools/bcftools-1.16
module load Tools/samtools-1.12

### for Wolbachia

## make BAMlist
for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/*.bam; do
    echo $i >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/bamlist_Wolb.txt

done

Samples=(Re1_full Re3 Re6_full Re10 Ak7_full Ak9_full MEL_full CS POP)

for i in ${!Samples[*]}; do
    Sample=${Samples[i]}

    echo /media/inter/mkapun/projects/DrosoWolbGenomics/results/RefMapping/${Sample}.bam \
        >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/bamlist_Wolb.txt

done

### now index mapped BAM flies

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/*.bam; do
    samtools index $i
done

## now exclude libraries which, based on the BLOBtools analyses do not contain Wolbachia or less than XXX reads mapped to the reference
gunzip /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/Wolb_Burkholderia.fna.gz

## SNP calling of Wolbachia reads
bcftools mpileup \
    -Bf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/Wolb_Burkholderia.fna \
    -b /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/bamlist_Wolb_stringent.txt \
    -a AD,DP \
    -d 1000 \
    -r "ENA|AE017196|AE017196.1" \
    -Ou |
    bcftools call \
        -O z --ploidy 1 \
        -c \
        -v \
        -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb.vcf.gz

## select SNPs and make phylip input
gzip /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/Wolb_Burkholderia.fna
python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/BCF2Phylip.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb.vcf.gz \
    --MinAlt 1 \
    --MaxPropGaps 0.5 \
    --MinCov 5 \
    --exclude 377,378,380,HG0029,HG0027,HG0034,wYak \
    --names /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/names.txt \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb.phy

## make phylogenetic tree
sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/makePhylo_MidpointRoot.sh \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Wolb \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb.phy \
    Wolbachia \
    0.1 \
    8 \
    8 \
    no

## repeat SNP selection with relaxed parameters to include all samples
python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/BCF2Phylip.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb.vcf.gz \
    --MinAlt 1 \
    --MaxPropGaps 0.9 \
    --MinCov 2 \
    --exclude wYak \
    --names /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/names.txt \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb_full.phy

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/makePhylo_MidpointRoot.sh \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Wolb_full \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb_full.phy \
    Wolbachia \
    0.1 \
    200 \
    8 \
    yes

cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Wolb/Wolbachia.pdf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Phylogeny/Wolbachia_SNPs.pdf
cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Wolb/Wolbachia.png /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Phylogeny/Wolbachia_SNPs.png

cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Wolb_full/Wolbachia.pdf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Phylogeny/Wolbachia_SNPs_full.pdf
cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Wolb_full/Wolbachia.png /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Phylogeny/Wolbachia_SNPs_full.png

### repeat for Mitochondria

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_mito/*.bam; do
    echo $i >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/bamlist_Mito.txt

done

printf "#ID\trname\tstartpos\tendpos\tnumreads\tcovbases\tcoverage\tmeandepth\tmeanbaseq\tmeanmapq\n" >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Mito_coverages.txt

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_mito/*.bam; do

    tmp=${i##*/}
    ID=${tmp%.*}

    samtools coverage $i | awk -v ID=$ID 'NR>1{print ID"\t"$0}' >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Mito_coverages.txt

done

bcftools mpileup \
    -Bf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/NC_024511.2_start.fasta \
    -b /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/bamlist_Mito.txt \
    -a AD,DP \
    -d 1000 \
    -Ou |
    bcftools call \
        -O z --ploidy 1 \
        -c \
        -v \
        -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Mito.vcf.gz

python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/BCF2Phylip.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Mito.vcf.gz \
    --MinAlt 1 \
    --MaxPropGaps 0.5 \
    --MinCov 2 \
    --names /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/names.txt \
    --exclude mtDyak \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Mito.phy

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/makePhylo_MidpointRoot.sh \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Mito \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Mito.phy \
    Mitchondria \
    0.05 \
    8 \
    8 \
    no

cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Mito/Mitchondria.pdf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Phylogeny/Mitochondria_SNPs_full.pdf
cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Mito/Mitchondria.png /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Phylogeny/Mitochondria_SNPs_full.png
