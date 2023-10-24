PWD=/media/inter/mkapun/projects/WolbachiaEvolHist_2023

### Isolate Wolbachia Contigs
mkdir ${PWD}/results/WolbGenomes

## get wMel Reference
cd ${PWD}/data
wget https://www.ebi.ac.uk/ena/browser/api/fasta/AE017196.1?download=true

mv ${PWD}/data/AE017196.1?download=true ${PWD}/data/AE017196.1_wMel.fa

Samples=(Re1_full Re3 Re6_full Re10 Ak7_full Ak9_full MEL_full CS POP)
for i in ${!Samples[*]}; do
  Sample=${Samples[i]}
  echo $i ${Sample}

  mkdir -p ${PWD}/results/WolbGenomes/${Sample}/Genomes

  ## Only keep BLAST hits with more than 95% identity and store first two columns
  awk '$6>95' ${PWD}/results/assemblies/${Sample}/results/BLAST/blastn_${Sample}.txt |
    cut -f 1-2 \
      >${PWD}/results/WolbGenomes/${Sample}/${Sample}.bl

  ## assign taxonomic information
  perl /media/inter/mkapun/projects/SepsidMicroBiome/scripts/tax_trace.pl \
    /media/inter/mkapun/projects/SepsidMicroBiome/data/nodes.dmp \
    /media/inter/mkapun/projects/SepsidMicroBiome/data/names.dmp \
    ${PWD}/results/WolbGenomes/${Sample}/${Sample}.bl \
    ${PWD}/results/WolbGenomes/${Sample}/${Sample}.tax

  ## split by taxonomy
  python ${PWD}/scripts/SplitFASTAByBLASTsimple.py \
    --FASTA ${PWD}/results/assemblies/${Sample}/output/${Sample}_ONT.fa.gz \
    --BLAST ${PWD}/results/WolbGenomes/${Sample}/${Sample}.tax \
    --output ${PWD}/results/WolbGenomes/${Sample}/Genomes

  ##combine contigs in order according to showtilingoutput in multifasta files

  mkdir ${PWD}/results/WolbGenomes/${Sample}/nucmer
  cd ${PWD}/results/WolbGenomes/${Sample}/nucmer

  conda activate mummer-3.23

  gunzip ${PWD}/results/WolbGenomes/${Sample}/Genomes/Wolbachia.fa.gz

  ## Use NUCMER to align all Wolbachia-specific contigs agains the reference.
  nucmer \
    -mum \
    -p ${Sample} \
    ${PWD}/data/AE017196.1_wMel.fa \
    ${PWD}/results/WolbGenomes/${Sample}/Genomes/Wolbachia.fa

  gzip ${PWD}/results/WolbGenomes/${Sample}/Genomes/Wolbachia.fa

  #combine contigs in order according to showtilingoutput in multifasta files

  delta-filter -q ${Sample}.delta >${Sample}.filter.delta

  show-coords -THrcl ${Sample}.filter.delta >${Sample}.coords

  show-tiling -i 20.0 -v 20.0 -V 0 -g -1 -R ${Sample}.filter.delta >${Sample}.tiling

  python ${PWD}/scripts/CombineContigs.py \
    --tile ${Sample}.tiling \
    --input ${PWD}/results/WolbGenomes/${Sample}/Genomes/Wolbachia.fa.gz \
    >${PWD}/results/WolbGenomes/${Sample}/nucmer/${Sample}.fasta

done

## Now scaffold and readjust start
NewName=(Re1_full Re3 Re6_full Re10 Ak7_full Ak9_full MEL_full CS POP)
for i in ${!NewName[*]}; do
  New=${NewName[i]}

  echo $New

  python ${PWD}/scripts/Scaffold.py \
    --input ${PWD}/results/WolbGenomes/${New}/nucmer/${New}.fasta \
    --Name ${New} |
    python ${PWD}/scripts/SetStart.py \
      --reference ${PWD}/data/AE017196.1_wMel.fa \
      --input - \
      >${PWD}/results/CompGenomes/FASTA/${New}_start.fasta

done

## copy to output and manually edit FASTA header to contain more info

mkdir ${PWD}/Genomes

cp ${PWD}/results/CompGenomes/FASTA/*_start.fasta ${PWD}/Genomes
