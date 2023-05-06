## Historic Museum samples provide evidence for a recent replacment of _Wolbachia_ variants in European _Drosophila melanogaster_

### Abstract 

### 1. Introduction

### 2. Materials and Methods

In this study, we investigated _Wolbachia_ infections in 25 historic _D. melanogaster_ museum samples from Sweden, Denmark and Germany, that were collected between 90 and 200 years ago (REF). Taking advantage of recently published whole genomic Illumina deep sequencing data of the samples, we tested for the presence of _Wolbachia_-specific reads in these samples, estimated titer variation and investigated the relatedness to contemporary _Wolbachia_ strains. Complementary to the historic samples, we used Oxford Nanopore technology (ONT) to newly sequence genomic DNA of six strain of freshly collected isofemale lines from wild populations in Portugal and Finland, that were naturally infected with either the wMel or the wMelCS _Wolbachia_ variants (REF) and of three lab-strains that were artifically infected previously with wMel, wMelCS and wMelCS POP (REF; see Table S1). 

#### 2.1 DNA extraction, library preprartion and ONT whole genome sequencing

TBA

#### 2.2 De-Novo assembly and draft annotation

 At first, we sorted the raw FASTQ files of each library with Kraken (REF) using a custom-built databset that consisted of the published genomes of wMel (XXX), wMelCS (XXX) and wMelCS POP (XXX) and only retained Illumina and ONT reads which matched the references in the database. Illumina reads of the historic samples were quality-trimmed (PHRED-scaled basequality >=25) and trimmed for sequencing adapters using cutadapt (REF). We only used intact read-pairs with a minimum length of 75bp for de-novo assembly with SPAdes (REF) using default parameters. Raw long-fragment reads from ONT sequencing of contemporary flies were assembled with Flye (REF) using default paramters. 
 
 Subsequently, we assessed the assembly quality based on common quality statistics such as numbers of contigs, N50 and N90 with QUAST (REF) and tested for the assembly completeness using the BUSCO approach, where the proportion of intact, fragmented and missing benchmarking universal single-copy orthologs specific to the bacterial order Rickettsiales (rickettsiales_odb10) is evaluated in each assembled genome (REF). In addition, we re-mapped the raw reads to the assembled contigs using minimap2 (REF) to assess variation in coverage and compared all contigs to a local copy of the NCBI _nt_ database using blastn of the BLAST suite (REF). After that, we visulized the results of these quality assessments with Blobtools (REF). 
 
 Finally, we used the published _Wolbachia_ wMel reference genome (ENA|AE017196|AE017196.1) as a backbone to align and orient the raw contigs with _nucmer_ of the MUMmer package (REF). Then, we used _show-tiling_ of the MUMmer package to identify the minimum number of unique contigs that span a maximum of the reference backbone. Using a custom script, we then combined these contigs into a single scaffold and filled the gaps between each pair of consecutive contigs with a string of ten N's. Moreover, given that the bacterial genome is circular, we anchored the newly assembled scaffolds at the startpoint of the reference genome and shifted pretailing sequences to the end of the scaffolds. We then calculated multiple genome alignments of all scaffolds and the _Wolbachia_ reference using progressive-mauve (REF) and visualized the alignemnt with Mauve GUI (REF).


>Since RNASeq data was neither available for the historic nor for the contemporary samples, we computed a draft genome annotation based on comparing the genomic sequences of the assemblies to a reference wMel transcriptome (CP046925.1) by gapped alignment using the protein2genome model of exonerate (REF). Conservatively, we only retained gene models with reached at least 80% of the maximal alignment score optainable for a given sequence.

#### 2.3 Relative Bacterial Titer

To obtain estimates of _Wolbachia_ titers, we used minimap2 (REF) to map all raw FASTQ reads for each sample against a joint reference sequence, which was constructed from the _Drosophila melanogaster_ reference genome v.6 (REF) and additional genome sequences of other common microbial symbionts, including the wMel reference genome (see REF for more details). Using samtools depth (REF) in combination with a custom _awk_ script, we calculated average read depths for all _Drosophila_ chromosomes and symbiont genomes. Based on this information, we estimated relative _Wolbachia_ titers for a given sample by dividing the average read depth at the _Wolbachia_ genome by the average read depth across all _Drosophila_ autosomes.

#### 2.4 Phylogenetic analysis 

We employed two complementary approaches to explore the evolutionary history of Wolbachia based on phylogenetics. Using MAFFT (REF), we aligned the nuclear sequences of 107 BUSCO genes, which were identified in at least 15 infected historic and contemporary samples. We then concatenated the alignments with a custom Python script and restricted the analysis to 13 samples where nuclear sequences were available for >90% of all 107 BUSCO genes. Then, we reconstructed a maximum likelihood tree based on the GTR-Gamma substitution model using RaXML (REF) and additionally performed 100 rounds of bootstrapping to test for the robustness of each node. The final tree was plotted in _R_ (REF) using the _ggtree_ package (REF).  


### Results 



#### _Wolbachia_ in 



### Discussion

### Acknowledgments 

### References