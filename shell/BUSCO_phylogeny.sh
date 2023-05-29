# now phylogeny based on BUSCO

## Get list of full IDs, see here for credits: https://bioinformaticsworkbook.org/phylogenetics/reconstructing-species-phylogenetic-tree-with-busco-genes-using-maximum-liklihood-method.html#gsc.tab=0

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2

rm -f /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/complete_busco_ids.txt

cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo

for file in $(find -iname "full_table*.tsv"); do
    grep -v "^#" ${file} | awk '$2=="Complete" {print $1}' >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/complete_busco_ids.txt
done

cd /media/inter/mkapun/projects/DrosoWolbGenomics/results/assemblies

for file in $(find -iname "full_table*.tsv"); do
    grep -v "^#" ${file} | awk '$2=="Complete" {print $1}' >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/complete_busco_ids.txt
done

cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/refseq/busco

for file in $(find -iname "full_table*.tsv"); do
    grep -v "^#" ${file} | awk '$2=="Complete" {print $1}' >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/complete_busco_ids.txt
done

## Genes that are present in ALL samples

sort /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/complete_busco_ids.txt |
    uniq -c \
        >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/complete_busco_ids_with_counts.txt

awk '$1 >= 33 {print $2}' /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/complete_busco_ids_with_counts.txt \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/final_busco_ids.txt

### Get Sequences

mkdir -p /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/busco_dna

cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo

for dir in $(find . -type d -name "single_copy_busco_sequences"); do
    echo $dir
    tmp=${dir#*/}
    abbrv=${tmp%%/*}

    for i in ${dir}/*.fna; do

        file=${i##*/}
        #echo $file

        cp $i /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}
        sed -i 's/^>/>'${abbrv}'|/g' /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}
        cut -f 1 -d ":" /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file} | tr '[:lower:]' '[:upper:]' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}.1
        mv /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}.1 /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}
    done

done

### Get Sequences

cd /media/inter/mkapun/projects/DrosoWolbGenomics/results/assemblies

for dir in $(find . -type d -name "single_copy_busco_sequences"); do
    echo $dir
    tmp=${dir#*/}
    abbrv=${tmp%%/*}

    for i in ${dir}/*.fna; do

        file=${i##*/}
        #echo $file

        cp $i /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}
        sed -i 's/^>/>'${abbrv}'|/g' /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}
        cut -f 1 -d ":" /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file} | tr '[:lower:]' '[:upper:]' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}.1
        mv /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}.1 /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}
    done

done

cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/refseq/busco

for dir in $(find . -type d -name "single_copy_busco_sequences"); do
    echo $dir
    tmp=${dir#*/}
    abbrv=${tmp%%/*}

    for i in ${dir}/*.fna; do

        file=${i##*/}
        #echo $file

        cp $i /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}
        sed -i 's/^>/>'${abbrv}'|/g' /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}
        cut -f 1 -d ":" /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file} | tr '[:lower:]' '[:upper:]' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}.1
        mv /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}.1 /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}
    done

done

### concatenate and reduce to shared genes, what a beautiful code!!!

while read line; do
    cat /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/busco_dna/*_${line}.fna \
        >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/${line}_dna.fasta
done </media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/final_busco_ids.txt

## rm -rf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/busco_dna

# append outgroup data

### make alignments

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/mafft_dna
conda activate mafft-7.487

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/*_dna.fasta; do

    tmp=${i##*/}
    ID=${tmp%_*}

    mafft \
        --thread 50 \
        --auto \
        --adjustdirection \
        ${i} \
        >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/mafft_dna/${ID}_aln.fasta

    python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/fixIDAfterMafft.py \
        --Alignment /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/mafft_dna/${ID}_aln.fasta \
        --input ${i} \
        >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/mafft_dna/${ID}_aln_fixed.fasta

    rm -f /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/mafft_dna/${ID}_aln.fasta

done

# for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/refseq/data/*.fa
# do
# tmp=${i##*/}
# ID=${tmp%%.*}

# echo "$ID,$ID" >> /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/names2.txt

# done

## make phylogeny

rm -rf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/phylogeny2

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/phylogeny2

python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/ConcatenateAlignments.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/mafft_dna \
    --names /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/names2.txt \
    --exclude HG0027,HG0029,HG47205,HG_09,HG0026,HG_20,WMELOCTOLESS,WMEL_AMD,WMELCS112,WMELCSCSBERKELEY,WMELPC75,WMELPLUS,WMELPOP1,WMELPOP2,WMELPOP3 \
    --geneList /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/alignment_dna.genes \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/alignment_dna.fa

python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/ConcatenateAlignments.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/mafft_dna \
    --names /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/names2.txt \
    --exclude HG0027,HG0029,HG47205,HG_09,HG0026,HG_20,WMELOCTOLESS,WMEL_AMD,WMELCS112,WMELCSCSBERKELEY,WMELPC75,WMELPLUS,WMELPOP1,WMELPOP2,WMELPOP3,WYAK \
    --geneList /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/alignment_dna.genes \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/alignment_dna_noOut.fa

python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/ConcatenateAlignments.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/mafft_dna \
    --names /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/names2.txt \
    --exclude NA \
    --NoGaps \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/phylogeny2/alignment_dna_noGap.fa

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/makePhylo.sh \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/phylogeny2 \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/alignment_dna.fa \
    Wolbachia \
    wYak \
    0.0001

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/makePhylo_MidpointRoot.sh \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/phylogeny2_noOut \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/alignment_dna.fa \
    Wolbachia \
    0.0001

cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/phylogeny2/Wolbachia.pdf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Phylogeny/Wolbachia_BUSCO.pdf
cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/phylogeny2/Wolbachia.png /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Phylogeny/Wolbachia_BUSCO.png

cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/phylogeny2_noOut/Wolbachia.pdf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Phylogeny/Wolbachia_BUSCO_noOut.pdf
cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/phylogeny2_noOut/Wolbachia.png /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Phylogeny/Wolbachia_BUSCO_noOut.png
