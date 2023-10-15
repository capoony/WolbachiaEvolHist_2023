## test for statistical congruency among wolb and mito trees.

#use trees from tanglegram analyses

echo '''

library(ape)

Mito<-read.tree("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram/phylogeny_mito/RAxML_bestTree.Mito_snps")

Wolb<-read.tree("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram/phylogeny_wolb/RAxML_bestTree.Wolb_snps")

Mito.dist<-cophenetic(Mito)
Wolb.dist<-cophenetic(Wolb)

RN <- rownames(Mito.dist)
Wolb.dist <- Wolb.dist[RN, RN]
Matrices <- rbind(Mito.dist, Wolb.dist)
Matrices.stat<-CADM.global(Matrices, 
    nmat=2, 
    n=28,
    nperm=100000)

sink("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram/CADM.stat")
Matrices.stat
sink()
''' >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram/CADM.r

Rscript /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/tanglegram/CADM.r
