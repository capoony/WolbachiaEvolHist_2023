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

rm -rf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/busco_dna

### make alignments

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/mafft_dna
conda activate mafft-7.487

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/*_dna.fasta; do

    tmp=${i##*/}
    ID=${tmp%_*}

    mafft \
        --thread 50 \
        --auto \
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

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/phylogeny2

python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/proteins2genome.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/mafft_dna \
    --names /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/names2.txt \
    --exclude HG0027,HG0029,HG47205,HG_09,HG0026,HG_20 \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/phylogeny2/alignment_dna.fa

module load Phylogeny/RAxML-2.8.10

## make new directory

cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/phylogeny2

## run ML tree reconstruction
raxmlHPC-PTHREADS-SSE3 \
    -m GTRGAMMA \
    -N 20 \
    -p 772374015 \
    -n Wolbachia_dna \
    -s /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/phylogeny2/alignment_dna.fa \
    -T 200

raxmlHPC-PTHREADS-SSE3 \
    -m GTRGAMMA \
    -N 100 \
    -p 772374015 \
    -b 444353738 \
    -n bootrep_dna \
    -s /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/phylogeny2/alignment_dna.fa \
    -T 200

# Now, reconcile the best ML tree w/ the bootreps:
raxmlHPC-SSE3 -f b \
    -m GTRGAMMA \
    -t RAxML_bestTree.Wolbachia_dna \
    -z RAxML_bootstrap.bootrep_dna \
    -n FINAL_dna

Rscript /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/PlotTree.r \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/phylogeny2/RAxML_bipartitions.FINAL_dna \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/phylogeny2/Wolbachia_BUSCO \
    Wolbachia_BUSCO \
    0.0001 \
    NO

cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/phylogeny2/Wolbachia_BUSCO.* /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Phylogeny
