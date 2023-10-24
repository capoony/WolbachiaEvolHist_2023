# now phylogeny based on BUSCO

## Get list of full IDs, see here for credits: https://bioinformaticsworkbook.org/phylogenetics/reconstructing-species-phylogenetic-tree-with-busco-genes-using-maximum-liklihood-method.html#gsc.tab=0

PWD=/media/inter/mkapun/projects/WolbachiaEvolHist_2023

mkdir ${PWD}/results/CompGenomes/busco_genes2

#rm -f ${PWD}/results/CompGenomes/busco_genes2/complete_busco_ids.txt

cd ${PWD}/results/denovo

for file in $(find -iname "full_table*.tsv"); do
    grep -v "^#" ${file} | awk '$2=="Complete" {print $1}' \
        >>${PWD}/results/CompGenomes/busco_genes2/complete_busco_ids.txt
done

cd ${PWD}/results/assemblies_ONT

for file in $(find -iname "full_table*.tsv"); do
    grep -v "^#" ${file} | awk '$2=="Complete" {print $1}' \
        >>${PWD}/results/CompGenomes/busco_genes2/complete_busco_ids.txt
done

cd ${PWD}/data/refseq/busco

for file in $(find -iname "full_table*.tsv"); do
    grep -v "^#" ${file} | awk '$2=="Complete" {print $1}' \
        >>${PWD}/results/CompGenomes/busco_genes2/complete_busco_ids.txt
done

## Genes that are present in ALL samples

sort ${PWD}/results/CompGenomes/busco_genes2/complete_busco_ids.txt |
    uniq -c \
        >${PWD}/results/CompGenomes/busco_genes2/complete_busco_ids_with_counts.txt

awk '$1 >= 33 {print $2}' ${PWD}/results/CompGenomes/busco_genes2/complete_busco_ids_with_counts.txt \
    >${PWD}/results/CompGenomes/busco_genes2/final_busco_ids.txt

### Get Sequences

mkdir -p ${PWD}/results/CompGenomes/busco_genes2/busco_dna

cd ${PWD}/results/denovo

for dir in $(find . -type d -name "single_copy_busco_sequences"); do
    echo $dir
    tmp=${dir#*/}
    abbrv=${tmp%%/*}

    for i in ${dir}/*.fna; do

        file=${i##*/}
        #echo $file

        cp $i ${PWD}/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}
        sed -i 's/^>/>'${abbrv}'|/g' ${PWD}/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}
        cut -f 1 -d ":" ${PWD}/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file} |
            tr '[:lower:]' '[:upper:]' \
                >${PWD}/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}.1
        mv ${PWD}/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}.1 \
            ${PWD}/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}
    done

done

### Get Sequences

cd ${PWD}/results/assemblies_ONT

for dir in $(find . -type d -name "single_copy_busco_sequences"); do
    echo $dir
    tmp=${dir#*/}
    abbrv=${tmp%%/*}

    for i in ${dir}/*.fna; do

        file=${i##*/}
        #echo $file

        cp $i ${PWD}/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}
        sed -i 's/^>/>'${abbrv}'|/g' ${PWD}/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}
        cut -f 1 -d ":" ${PWD}/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file} |
            tr '[:lower:]' '[:upper:]' \
                >${PWD}/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}.1
        mv ${PWD}/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}.1 \
            ${PWD}/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}
    done

done

cd ${PWD}/data/refseq/busco

for dir in $(find . -type d -name "single_copy_busco_sequences"); do
    echo $dir
    tmp=${dir#*/}
    abbrv=${tmp%%/*}

    for i in ${dir}/*.fna; do

        file=${i##*/}
        #echo $file

        cp $i ${PWD}/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}
        sed -i 's/^>/>'${abbrv}'|/g' ${PWD}/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}
        cut -f 1 -d ":" ${PWD}/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file} | tr '[:lower:]' '[:upper:]' >${PWD}/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}.1
        mv ${PWD}/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}.1 ${PWD}/results/CompGenomes/busco_genes2/busco_dna/${abbrv}_${file}
    done

done

### concatenate and reduce to shared genes, what a beautiful code!!!

while read line; do
    cat ${PWD}/results/CompGenomes/busco_genes2/busco_dna/*_${line}.fna \
        >>${PWD}/results/CompGenomes/busco_genes2/${line}_dna.fasta
done <${PWD}/results/CompGenomes/busco_genes2/final_busco_ids.txt

## rm -rf ${PWD}/results/CompGenomes/busco_genes2/busco_dna

# append outgroup data

### make alignments

mkdir ${PWD}/results/CompGenomes/mafft_dna
conda activate mafft-7.487

for i in ${PWD}/results/CompGenomes/busco_genes2/*_dna.fasta; do

    tmp=${i##*/}
    ID=${tmp%_*}

    mafft \
        --thread 50 \
        --auto \
        --adjustdirection \
        ${i} \
        >${PWD}/results/CompGenomes/mafft_dna/${ID}_aln.fasta

    python ${PWD}/scripts/fixIDAfterMafft.py \
        --Alignment ${PWD}/results/CompGenomes/mafft_dna/${ID}_aln.fasta \
        --input ${i} \
        >${PWD}/results/CompGenomes/mafft_dna/${ID}_aln_fixed.fasta

    rm -f ${PWD}/results/CompGenomes/mafft_dna/${ID}_aln.fasta

done

# for i in ${PWD}/data/refseq/data/*.fa
# do
# tmp=${i##*/}
# ID=${tmp%%.*}

# echo "$ID,$ID" >> ${PWD}/data/names2.txt

# done

## make phylogeny

rm -rf ${PWD}/results/CompGenomes/phylogeny2

mkdir ${PWD}/results/CompGenomes/phylogeny2

python ${PWD}/scripts/ConcatenateAlignments.py \
    --input ${PWD}/results/CompGenomes/mafft_dna \
    --names ${PWD}/data/names2.txt \
    --exclude HG0027,HG0029,HG47205,WMELOCTOLESS,WMEL_AMD,WMELCS112,WMELCSCSBERKELEY,WMELPC75,WMELPLUS,WMELPOP1,WMELPOP2,WMELPOP3 \
    --output ${PWD}/results/CompGenomes/alignment_dna

## Manually edit Alignment File in JalView -- puuh --- and store as ${PWD}/results/CompGenomes/alignment_dna_noSing.fa

sh ${PWD}/shell/makePhylo_MidpointRoot.sh \
    ${PWD}/results/CompGenomes/phylogeny2_noSing \
    ${PWD}/results/CompGenomes/alignment_dna_noSing.fa \
    Wolbachia \
    0.00005 \
    8 \
    5 \
    no
