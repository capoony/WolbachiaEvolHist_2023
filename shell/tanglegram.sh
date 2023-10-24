## now make tanglegram
PWD=/media/inter/mkapun/projects/WolbachiaEvolHist_2023

mkdir ${PWD}/results/tanglegram

python ${PWD}/scripts/IntersectPhy.py \
    --input ${PWD}/results/MergedData/Mito.phy,${PWD}/results/MergedData/Wolb.phy \
    --names MITO,WOLB \
    --output ${PWD}/results/tanglegram/

rm -rf ${PWD}/results/tanglegram/phylogeny_mito
mkdir -p ${PWD}/results/tanglegram/phylogeny_mito
cd ${PWD}/results/tanglegram/phylogeny_mito

module load Phylogeny/RAxML-2.8.10

## run ML tree reconstruction
raxmlHPC-PTHREADS-SSE3 \
    -m GTRCAT \
    -V \
    -N 20 \
    -p 772374015 \
    -n Mito_snps \
    -s ${PWD}/results/tanglegram/MITO.phy \
    -T 200

raxmlHPC-PTHREADS-SSE3 \
    -m GTRCAT \
    -N 2 \
    -p 772374015 \
    -b 444353738 \
    -n bootrep_snps \
    -s ${PWD}/results/tanglegram/MITO.phy \
    -T 200

# Now, reconcile the best ML tree w/ the bootreps:
raxmlHPC-SSE3 -f b \
    -m GTRCAT \
    -t RAxML_bestTree.Mito_snps \
    -z RAxML_bootstrap.bootrep_snps \
    -n Mito

rm -r ${PWD}/results/tanglegram/phylogeny_wolb
mkdir -p ${PWD}/results/tanglegram/phylogeny_wolb
cd ${PWD}/results/tanglegram/phylogeny_wolb

module load Phylogeny/RAxML-2.8.10

## run ML tree reconstruction
raxmlHPC-PTHREADS-SSE3 \
    -m GTRCAT \
    -V \
    -N 20 \
    -p 772374015 \
    -n Wolb_snps \
    -s ${PWD}/results/tanglegram/WOLB.phy \
    -T 200

raxmlHPC-PTHREADS-SSE3 \
    -m GTRCAT \
    -N 2 \
    -p 772374015 \
    -b 444353738 \
    -n bootrep_snps \
    -s ${PWD}/results/tanglegram/WOLB.phy \
    -T 200

# Now, reconcile the best ML tree w/ the bootreps:
raxmlHPC-SSE3 -f b \
    -m GTRCAT \
    -t RAxML_bestTree.Wolb_snps \
    -z RAxML_bootstrap.bootrep_snps \
    -n Mito

echo """
library(tidyverse)
library(phytools)
library(dendextend)
library(phylogram) # to make dendrograms from non-ultrametric trees
library(ape) # to import NEXUS and to plot co-phyloplots

Tree.Wol<-midpoint.root(read.tree('${PWD}/results/tanglegram/phylogeny_wolb/RAxML_bestTree.Wolb_snps'))

Wol.ultra=as.dendrogram(chronos(Tree.Wol, lambda=0) )
# Wol.unmatched <- as.dendrogram(multi2di(Wol.ultra, random=TRUE) )
# plot(Wol.unmatched)

## load Mitodata based on amino acids and match UCE labels
Tree.Mito<-midpoint.root(read.tree('${PWD}/results/tanglegram/phylogeny_mito/RAxML_bestTree.Mito_snps'))

Mito.ultra=as.dendrogram(chronos(Tree.Mito, lambda=0) )
# Mito.unmatched <- as.dendrogram(multi2di(Mito.ultra, random=TRUE) )
# plot(Mito.unmatched)

dndlist<-dendlist('Wolbachia'=Wol.ultra,'Mitochondria'=Mito.ultra)

pdf('${PWD}/results/tanglegram/Tanglegram.pdf',
    width=10,
    height=6)
dndlist %>% untangle(method = 'step1side') %>% 
    tanglegram(common_subtrees_color_branches = TRUE, 
        highlight_branches_lwd = FALSE,
        margin_inner = 5,
        edge.lwd=3)
dev.off()

png('${PWD}/results/tanglegram/Tanglegram.png',
    width=10,
    height=6,
    units='in',
    res=300)
dndlist %>% untangle(method = 'step1side') %>% 
    tanglegram(common_subtrees_color_branches = TRUE, 
        highlight_branches_lwd = FALSE,
        margin_inner = 5,
        edge.lwd=3)
dev.off()

""" >${PWD}/results/tanglegram/plot.r

Rscript ${PWD}/results/tanglegram/plot.r

cp ${PWD}/results/tanglegram/Tanglegram.* ${PWD}/output/Phylogeny
