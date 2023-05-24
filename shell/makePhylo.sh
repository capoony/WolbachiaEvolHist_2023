output=$1
input=$2
name=$3
outgroup=$4
offset=$5

### First Wolbachia
rm -rf ${output}
mkdir -p ${output}
cd ${output}

module load Phylogeny/RAxML-2.8.10

## run ML tree reconstruction
raxmlHPC-PTHREADS-SSE3 \
    -m GTRCAT \
    -V \
    -N 20 \
    -p 772374015 \
    -n ${name} \
    -s ${input} \
    -T 200

raxmlHPC-PTHREADS-SSE3 \
    -m GTRCAT \
    -N 100 \
    -p 772374015 \
    -b 444353738 \
    -n bootrep_snps \
    -s ${input} \
    -T 200

# Now, reconcile the best ML tree w/ the bootreps:
raxmlHPC-SSE3 -f b \
    -m GTRCAT \
    -t RAxML_bestTree.${name} \
    -z RAxML_bootstrap.bootrep_snps \
    -n FINAL_snps

## plot Tree
Rscript /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/PlotTree_outgroup.r \
    ${output}/RAxML_bipartitions.FINAL_snps \
    ${output}/${name} \
    ${name} \
    ${offset} \
    ${outgroup}
