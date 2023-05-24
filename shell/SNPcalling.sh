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

### obtain coverages

printf "#ID\trname\tstartpos\tendpos\tnumreads\tcovbases\tcoverage\tmeandepth\tmeanbaseq\tmeanmapq\n" >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb_coverages.txt

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/*.bam; do

    tmp=${i##*/}
    ID=${tmp%.*}

    samtools coverage $i | awk -v ID=$ID 'NR>1{print ID"\t"$0}' >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb_coverages.txt

done

## now exclude libraries which, based on the BLOBtools analyses do not contain Wolbachia or less than XXX reads mapped to the reference

## SNP calling
bcftools mpileup \
    -Bf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/AE017196.1_wMel.fa \
    -b /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/bamlist_Wolb_stringent.txt \
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
    --MaxPropGaps 0.5 \
    --MinCov 5 \
    --exclude 377,378,380,HG0029,HG0027,HG0034,wMelCSPOP2,wMelCSPOP,wMelOctoless,wMel_run2,wMel_run3 \
    --names /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/names.txt \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb_red.phy

python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/BCF2Phylip.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb.vcf.gz \
    --MinAlt 1 \
    --MaxPropGaps 0.5 \
    --MinCov 5 \
    --exclude 377,378,380,HG0027,HG0034,wMelCSPOP2,wMelCSPOP,wMelOctoless,wMel_run2,wMel_run3 \
    --names /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/names.txt \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb_red2.phy

python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/BCF2Phylip.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb.vcf.gz \
    --MinAlt 1 \
    --MaxPropGaps 0.8 \
    --MinCov 2 \
    --exclude wMelCSPOP2,wMelCSPOP,wMelOctoless,wMel_run2,wMel_run3 \
    --names /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/names.txt \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb_full.phy

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/makePhylo.sh \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Wolb_red \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb_red.phy \
    Wolbachia \
    wMel1_Gulbenkian,wMel1_Portugal,wMel2_Portugal,wMel1_Finland,wMel2_Finland,wMel_LabStrain_Gulbenkian,wMel_Indiana,wMel_Donor4Aedes \
    0.5

cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Wolb_red/Wolbachia.pdf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Phylogeny/Wolbachia_SNPs_red.pdf
cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Wolb_red/Wolbachia.png /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Phylogeny/Wolbachia_SNPs_red.png

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/makePhylo.sh \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Wolb_full \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb_full.phy \
    Wolbachia \
    wMel1_Gulbenkian,wMel1_Portugal,wMel2_Portugal,wMel1_Finland,wMel2_Finland,wMel_LabStrain_Gulbenkian,wMel_Indiana,wMel_Donor4Aedes \
    0.5

cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Wolb_full/Wolbachia.pdf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Phylogeny/Wolbachia_SNPs_full.pdf
cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Wolb_full/Wolbachia.png /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Phylogeny/Wolbachia_SNPs_full.png

### for Mitochondria

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
    --MinCov 5 \
    --names /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/names.txt \
    --exclude NA \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Mito.phy

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/makePhylo_MidpointRoot.sh \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Mito \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Mito.phy \
    Mitchondria \
    0.3

cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Mito/Mitchondria.pdf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Phylogeny/Mitochondria_SNPs_full.pdf
cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Mito/Mitchondria.png /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Phylogeny/Mitochondria_SNPs_full.png
