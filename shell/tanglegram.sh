## now make tanglegram

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram

python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/IntersectPhy.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Mito.phy,/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb.phy \
    --names MITO,WOLB \
    --output /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram/

rm -rf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram/phylogeny_mito
mkdir -p /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram/phylogeny_mito
cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram/phylogeny_mito

module load Phylogeny/RAxML-2.8.10

## run ML tree reconstruction
raxmlHPC-PTHREADS-SSE3 \
    -m GTRCAT \
    -V \
    -N 20 \
    -p 772374015 \
    -n Mito_snps \
    -s /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram/MITO.phy \
    -T 200

raxmlHPC-PTHREADS-SSE3 \
    -m GTRCAT \
    -N 2 \
    -p 772374015 \
    -b 444353738 \
    -n bootrep_snps \
    -s /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram/MITO.phy \
    -T 200

# Now, reconcile the best ML tree w/ the bootreps:
raxmlHPC-SSE3 -f b \
    -m GTRCAT \
    -t RAxML_bestTree.Mito_snps \
    -z RAxML_bootstrap.bootrep_snps \
    -n Mito

rm -r /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram/phylogeny_wolb
mkdir -p /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram/phylogeny_wolb
cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram/phylogeny_wolb

module load Phylogeny/RAxML-2.8.10

## run ML tree reconstruction
raxmlHPC-PTHREADS-SSE3 \
    -m GTRCAT \
    -V \
    -N 20 \
    -p 772374015 \
    -n Wolb_snps \
    -s /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram/WOLB.phy \
    -T 200

raxmlHPC-PTHREADS-SSE3 \
    -m GTRCAT \
    -N 2 \
    -p 772374015 \
    -b 444353738 \
    -n bootrep_snps \
    -s /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram/WOLB.phy \
    -T 200

# Now, reconcile the best ML tree w/ the bootreps:
raxmlHPC-SSE3 -f b \
    -m GTRCAT \
    -t RAxML_bestTree.Wolb_snps \
    -z RAxML_bootstrap.bootrep_snps \
    -n Mito

echo '''
library(tidyverse)
library(phytools)
library(dendextend)
library(phylogram) # to make dendrograms from non-ultrametric trees
library(ape) # to import NEXUS and to plot co-phyloplots

Tree.Wol<-midpoint.root(read.tree("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram/phylogeny_wolb/RAxML_bestTree.Wolb_snps"))

Wol.ultra=as.dendrogram(chronos(Tree.Wol, lambda=0) )
# Wol.unmatched <- as.dendrogram(multi2di(Wol.ultra, random=TRUE) )
# plot(Wol.unmatched)

## load Mitodata based on amino acids and match UCE labels
Tree.Mito<-midpoint.root(read.tree("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram/phylogeny_mito/RAxML_bestTree.Mito_snps"))

Mito.ultra=as.dendrogram(chronos(Tree.Mito, lambda=0) )
# Mito.unmatched <- as.dendrogram(multi2di(Mito.ultra, random=TRUE) )
# plot(Mito.unmatched)

dndlist<-dendlist("Wolbachia"=Wol.ultra,"Mitochondria"=Mito.ultra)

pdf("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram/Tanglegram.pdf",
    width=10,
    height=6)
dndlist %>% untangle(method = "step1side") %>% 
    tanglegram(common_subtrees_color_branches = TRUE, 
        highlight_branches_lwd = FALSE,
        margin_inner = 5,
        edge.lwd=3)
dev.off()

png("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram/Tanglegram.png",
    width=10,
    height=6,
    units="in",
    res=300)
dndlist %>% untangle(method = "step1side") %>% 
    tanglegram(common_subtrees_color_branches = TRUE, 
        highlight_branches_lwd = FALSE,
        margin_inner = 5,
        edge.lwd=3)
dev.off()

''' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram/plot.r

Rscript /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram/plot.r

cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram/Tanglegram.* /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/Phylogeny
