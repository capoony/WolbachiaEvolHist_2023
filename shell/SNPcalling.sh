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

## SNP calling
bcftools mpileup \
    -Bf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/AE017196.1_wMel.fa \
    -b /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/bamlist_Wolb.txt \
    -a AD,DP \
    -d 600 \
    -Ou |
    bcftools call \
        -O z --ploidy 1 \
        -c \
        -v \
        -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb.vcf.gz

python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/BCF2Phylip.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb.vcf.gz \
    --MinAlt 1 \
    --MaxPropGaps 0.6 \
    --MinCov 5 \
    --names /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/names.txt \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb.phy

### for Mitochondria

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_mito/*.bam; do
    echo $i >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/bamlist_Mito.txt

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
    --MaxPropGaps 0.6 \
    --MinCov 5 \
    --names /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/names.txt \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Mito.phy
