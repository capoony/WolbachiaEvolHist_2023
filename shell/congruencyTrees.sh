## test for statistical congruency among wolb and mito trees.
PWD=/media/inter/mkapun/projects/WolbachiaEvolHist_2023

#use trees from tanglegram analyses

echo """

library(ape)

Mito<-read.tree('${PWD}/results/tanglegram/phylogeny_mito/RAxML_bestTree.Mito_snps')

Wolb<-read.tree('${PWD}/results/tanglegram/phylogeny_wolb/RAxML_bestTree.Wolb_snps')

Mito.dist<-cophenetic(Mito)
Wolb.dist<-cophenetic(Wolb)

RN <- rownames(Mito.dist)
Wolb.dist <- Wolb.dist[RN, RN]
Matrices <- rbind(Mito.dist, Wolb.dist)
Matrices.stat<-CADM.global(Matrices, 
    nmat=2, 
    n=28,
    nperm=100000)

sink('${PWD}/results/tanglegram/CADM.stat')
Matrices.stat
sink()
""" >${PWD}/results/tanglegram/CADM.r

Rscript ${PWD}/results/tanglegram/CADM.r
