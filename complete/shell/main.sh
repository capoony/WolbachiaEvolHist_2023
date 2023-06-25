## download data from SRA

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/GetData.sh

## trim raw reads

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/trimming.sh

## Make Kraken Databases

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/KrakenDB.sh

## run Kraken for Wolbachia and Mitochondria

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/runKraken.sh

## make denovo assemblies and compare BUSCO scores

sh /media/inter/mkapun/projects/WolbEvolHist_2023/shell/assembly.sh

## scaffold the draft genomes based on the reference and compare with Mauve

sh /media/inter/mkapun/projects/WolbEvolHist_2023/shell/finish.sh

## Make Annotation with exonerate

sh /media/inter/mkapun/projects/WolbEvolHist_2023/shell/Annotation.sh

## map isolated reads against corresponding reference

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/mapReads.sh

## Detect diagnostic SNPs for wMel and wMelCS and characterize

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/DiagnosticSNPs.sh

## map all reads against the hologenome

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/mapReads_full.sh

## investigate the distribution of read depths along the reference

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/readdepths.sh

## calculate the relative titer for all strains

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/titer.sh

## SNP calling

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/SNPcalling.sh

## make a phylogeny

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/phylogeny.sh

## make tanglegram

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/tanglegram.sh

## copy output

Samples=(HG_09 HG_15 HG_16 HG_20 HG0026 HG47203 HG47204 377 378)
NewName=(Germany_Passau_1800_HG_09 Sweden_Lund_1933_HG_15 Sweden_Lund_1933_HG_16 Sweden_Lund_1933_HG_20 Sweden_Lund_1933_HG0026 Sweden_Lund_1933_HG47203 Sweden_Lund_1933_HG47204 Sweden_Lund_1800_377 Sweden_Lund_1800_378)

for i in ${!Samples[*]}; do
    Sample=${Samples[i]}
    New=${NewName[i]}

    mkdir -p /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/genomes/${New}

    cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/${New}/nucmer/${New}_start.fasta /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/genomes/${New}
    cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/${New}/nucmer/${New}.fasta /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/genomes/${New}
    cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Annotation/${Sample}/${Sample}_genes.gff /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/genomes/${New}/${New}.gff
    cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Annotation/${Sample}/${Sample}_genes.fa /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/genomes/${New}/${New}_genes.fa
    cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Annotation/${Sample}/${Sample}_genes.Sugar /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/genomes/${New}/${New}_genes.Sugar

done

gzip /media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/genomes/*/*.fa*

cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023

pandoc \
    -f markdown \
    -t docx \
    -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/WolbEvolHist_2023.docx \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/README.md
