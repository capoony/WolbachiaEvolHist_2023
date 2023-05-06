### make Script to plot Trees
echo """
# load necessary R libraries
library('ggtree')
library('gridExtra')
library('ggrepel')
library('ape')
library('ggplot2')
library('phangorn')
library('dplyr')
library(phytools) # to determine the maximum tree height and add midpoint root

args=commandArgs(trailingOnly=TRUE)

input=args[1]
output=args[2]
title=args[3]
offset=as.numeric(args[4])


## load tree file and root midpoint
tree<-read.tree(input)
tree<-midpoint.root(tree)

## caluculate tree height (on x-axis)
Xmax<-max(nodeHeights(tree))

## only retain Bootstrapping Support > 75% 
tree\$node.label[as.numeric(tree\$node.label) <75] <-NA

## plot tree
PLOT.tree<-ggtree(tree, 
    layout = 'roundrect')+
  ggtitle(title)+
  theme_tree2()+
  theme_bw()+
  ggplot2::xlim(0,
    Xmax+offset)+
  xlab('av. subst./site') +
  geom_nodelab(hjust = 1.25,
            vjust = -0.75,
            size = 3,
            color = 'blue')+
  theme(axis.title.y=element_blank(),
    axis.text.y=element_blank(),
    axis.ticks.y=element_blank())+
  geom_tiplab()

PNG=paste0(output,'.png')
PDF=paste0(output,'.pdf')
## export tree
ggsave(filename=PDF,
  PLOT.tree)
ggsave(filename=PNG,
  PLOT.tree)
""" >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/PlotTree.r

### First Wolbachia
rm -rf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Wolb
mkdir -p /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Wolb
cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Wolb

module load Phylogeny/RAxML-2.8.10

## run ML tree reconstruction
raxmlHPC-PTHREADS-SSE3 \
  -m GTRCAT \
  -V \
  -N 20 \
  -p 772374015 \
  -n Wolbachia_snps \
  -s /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb.phy \
  -T 200

raxmlHPC-PTHREADS-SSE3 \
  -m GTRCAT \
  -N 100 \
  -p 772374015 \
  -b 444353738 \
  -n bootrep_snps \
  -s /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb.phy \
  -T 200

# Now, reconcile the best ML tree w/ the bootreps:
raxmlHPC-SSE3 -f b \
  -m GTRCAT \
  -t RAxML_bestTree.Wolbachia_snps \
  -z RAxML_bootstrap.bootrep_snps \
  -n FINAL_snps

## plot Tree
Rscript /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/PlotTree.r \
  /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Wolb/RAxML_bipartitions.FINAL_snps \
  /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Wolb/Wolb \
  Wolbachia \
  0.25 \
  NO

### Then Mitochondria

rm -rf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Mito
mkdir -p /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Mito
cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Mito

module load Phylogeny/RAxML-2.8.10

## run ML tree reconstruction
raxmlHPC-PTHREADS-SSE3 \
  -m GTRCAT \
  -V \
  -N 20 \
  -p 772374015 \
  -n Mitochondria_snps \
  -s /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Mito.phy \
  -T 200

raxmlHPC-PTHREADS-SSE3 \
  -m GTRCAT \
  -N 50 \
  -p 772374015 \
  -b 444353738 \
  -n bootrep_snps \
  -s /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Mito.phy \
  -T 200

# Now, reconcile the best ML tree w/ the bootreps:
raxmlHPC-SSE3 -f b \
  -m GTRCAT \
  -t RAxML_bestTree.Mitochondria_snps \
  -z RAxML_bootstrap.bootrep_snps \
  -n FINAL_snps

## plot tree
Rscript /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/PlotTree.r \
  /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Mito/RAxML_bipartitions.FINAL_snps \
  /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Mito/Mito \
  Mitochondria \
  0.25 \
  NO
