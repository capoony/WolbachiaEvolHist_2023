## download data from SRA

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/GetData.sh

## Make Kraken Databases

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/KrakenDB.sh

## run Kraken for Wolbachia and Mitochondria

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/runKraken.sh

## make denovo assemblies and compare BUSCO scores

sh /media/inter/mkapun/projects/WolbEvolHist_2023/shell/assembly.sh

## scaffold the draft genomes based on the reference and compare with Mauve

sh /media/inter/mkapun/projects/WolbEvolHist_2023/shell/finish.sh

## map isolated reads against corresponding reference

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/mapReads.sh

## Subset to ~50x coverages

# sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/subsetBAM.sh

## SNP calling

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/SNPcalling.sh

## make a phylogeny

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/phylogeny.sh

## make tanglegram

sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/tanglegram.sh
