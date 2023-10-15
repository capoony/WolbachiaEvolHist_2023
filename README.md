## Historic museum samples provide evidence for a recent replacement of _Wolbachia_ types in European _Drosophila melanogaster_.

The bioinformatics pipeline for the data generation and analyses in [Strunov _et al._ 2023](). Note, that we worked with the library IDs. The names used for the MS can be found [here](datasets/NAMES_CORRECT)

### (A) Obtain data

#### (1) download [historic](https://www.biorxiv.org/content/10.1101/2023.04.24.538033v1) raw read data from SRA 

[shell/GetData.sh](shell/GetData.sh)

#### (2) download [_Drosophila_ Nexus](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5100052/) raw data from SRA

[shell/Nexus.sh](shell/Nexus.sh)

#### (3) download genomic FASTA from RefSeq 

[shell/resfseq.sh](shell/resfseq.sh)

#### (4) download and process wYak outgroup genome

[shell/outgroup.sh](shell/outgroup.sh)

 ---

 ### (B) Quality control and prefiltering


#### (1) Trim raw Illumina reads and obtain readlengths after trimming

[shell/trimming.sh](shell/trimming.sh)

#### (2) Make Kraken Databases

[shell/KrakenDB.sh](shell/KrakenDB.sh)

#### (3) run Kraken for _Wolbachia_ and Mitochondria

[shell/runKraken.sh](shell/runKraken.sh)

 ---

### (C) Reference mapping and SNP calling

#### (1) map raw Illumina and ONT reads against hologenome

[shell/mapReads_full.sh](shell/mapReads_full.sh)

#### (2) obtain mapping statistics and calculate relative titer levels

[shell/titer.sh](shell/titer.sh)

#### (3) map filtered Illumina and ONT reads against _Wolbachia_ and Mitochondria genomes only

[shell/mapReads.sh](shell/mapReads.sh)

[shell/mapReads_ONT.sh](shell/mapReads_ONT.sh)

---

### (D) SNP calling, classification and phylogenetic reconstruction

#### (1) Classification of _Wolbachia_ types with diagnostic SNPs

[shell/DiagnosticSNPs.sh](shell/DiagnosticSNPs.sh)

#### (2) SNP calling for _Wolbachia_ and Mitochondria and phylogenetic reconstruction

[shell/SNPcalling.sh](shell/SNPcalling.sh)

#### (3) compare Mitochondria and _Wolbachia_ with tanglegrams

[shell/tanglegram.sh](shell/tanglegram.sh)

#### (4) specifically investigate samples H03 and H05

[shell/WeirdSamples.sh](shell/WeirdSamples.sh)

---

### (E) De novo assemblies

We used our custom automated denovo assembly pipeline, which can be found [here](https://github.com/nhmvienna/AutDeNovo)

#### (1) make denovo assemblies of novel ONT sequening data

[shell/assembly_ONT.sh](shell/assembly_ONT.sh)

[shell/finish_ONT.sh](shell/finish_ONT.sh)

#### (2) make denovo assemblies of historic samples and compare BUSCO scores

[shell/assembly_Historic.sh](shell/assembly_Historic.sh)

[shell/finish_Historic.sh](shell/finish_Historic.sh)

#### (3) Phylogenetic reconstruction based on BUSCO genes

[shell/BUSCO_phylogeny.sh](shell/BUSCO_phylogeny.sh)

---

### Additional analyses:

####  test for statistical congruency between *Wolbachia* and Mito Trees

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/congruencyTrees.sh

####  identify if there is a potential reference bias

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/mapReads_wMelCS.sh

#### make phylogeny of supergroup B samples

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/SupergroupB_phylogeny.sh

#### BLAST mitochondria reads in H03 and H05

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/mitoBLAST.sh

#### calculate Titer based on Median 

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/titer_median.sh

#### calculate Read depths based on prefiltered reads

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/titer_prefiltered.sh

#### get Pairwise SNP differences among groups

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/SnpDiff.sh