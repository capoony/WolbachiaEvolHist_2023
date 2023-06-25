### Isolate Wolbachia Contigs
mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WolbGenomes

## get wMel Reference
cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data
wget https://www.ebi.ac.uk/ena/browser/api/fasta/AE017196.1?download=true

mv /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/AE017196.1?download=true /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/AE017196.1_wMel.fa

Samples=(Re1_full Re3 Re6_full Re10 Ak7_full Ak9_full MEL_full CS POP)
for i in ${!Samples[*]}; do
  Sample=${Samples[i]}
  echo $i ${Sample}

  mkdir -p /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WolbGenomes/${Sample}/Genomes

  ## Only keep BLAST hits with more than 95% identity and store first two columns
  awk '$6>95' /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/assemblies/${Sample}/results/BLAST/blastn_${Sample}.txt |
    cut -f 1-2 \
      >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WolbGenomes/${Sample}/${Sample}.bl

  ## assign taxonomic information
  perl /media/inter/mkapun/projects/SepsidMicroBiome/scripts/tax_trace.pl \
    /media/inter/mkapun/projects/SepsidMicroBiome/data/nodes.dmp \
    /media/inter/mkapun/projects/SepsidMicroBiome/data/names.dmp \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WolbGenomes/${Sample}/${Sample}.bl \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WolbGenomes/${Sample}/${Sample}.tax

  ## split by taxonomy
  python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/SplitFASTAByBLASTsimple.py \
    --FASTA /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/assemblies/${Sample}/output/${Sample}_ONT.fa.gz \
    --BLAST /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WolbGenomes/${Sample}/${Sample}.tax \
    --output /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WolbGenomes/${Sample}/Genomes

  ##combine contigs in order according to showtilingoutput in multifasta files

  mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WolbGenomes/${Sample}/nucmer
  cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WolbGenomes/${Sample}/nucmer

  conda activate mummer-3.23

  gunzip /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WolbGenomes/${Sample}/Genomes/Wolbachia.fa.gz

  ## Use NUCMER to align all Wolbachia-specific contigs agains the reference.
  nucmer \
    -mum \
    -p ${Sample} \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/AE017196.1_wMel.fa \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WolbGenomes/${Sample}/Genomes/Wolbachia.fa

  gzip /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WolbGenomes/${Sample}/Genomes/Wolbachia.fa

  #combine contigs in order according to showtilingoutput in multifasta files

  delta-filter -q ${Sample}.delta >${Sample}.filter.delta

  show-coords -THrcl ${Sample}.filter.delta >${Sample}.coords

  show-tiling -i 20.0 -v 20.0 -V 0 -g -1 -R ${Sample}.filter.delta >${Sample}.tiling

  python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/CombineContigs.py \
    --tile ${Sample}.tiling \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WolbGenomes/${Sample}/Genomes/Wolbachia.fa.gz \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WolbGenomes/${Sample}/nucmer/${Sample}.fasta

done

## Now scaffold and readjust start
NewName=(Re1_full Re3 Re6_full Re10 Ak7_full Ak9_full MEL_full CS POP))
for i in ${!NewName[*]}; do
  New=${NewName[i]}

  echo $New

  python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/Scaffold.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WolbGenomes/${New}/nucmer/${New}.fasta \
    --Name ${New} |
    python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/SetStart.py \
      --reference /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/AE017196.1_wMel.fa \
      --input - \
      >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomics/FASTA/${New}_start.fasta

done

## copy assemblies to output folder
cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/WolbGenomes/*/nucmer/*.fasta \
  /media/inter/mkapun/projects/WolbachiaEvolHist_2023/Output/Genomes

rm -f /media/inter/mkapun/projects/WolbachiaEvolHist_2023/Output/Genomes/sorted_contigs.fasta

gzip /media/inter/mkapun/projects/WolbachiaEvolHist_2023/Output/Genomes/*.fasta
