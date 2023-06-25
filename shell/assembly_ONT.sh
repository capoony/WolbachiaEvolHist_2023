## make denovo assemblies of all libraries

Samples=(Re1_full Re3 Re6_full Re10 Ak7_full Ak9_full MEL_full CS POP)
Barcodes=(03 04 05 06 07 08 09 10 16)

for i in ${!Samples[*]}; do
  Sample=${Samples[i]}
  Barcode=${Barcodes[i]}

  echo $i $Sample $Barcode

  mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/assemblies_ONT/${Sample}

  /media/inter/pipelines/AutDeNovo/AutDeNovo.sh \
    Name=${Sample} \
    OutputFolder=/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/assemblies_ONT/${Sample} \
    ONT=/media/inter/SeqData/raw/MinION/20221013_DrosoWolbGenomics/SUP/FASTQ/barcode${Barcode} \
    threads=100 \
    RAM=400 \
    RAMAssembly=800 \
    decont=no \
    SmudgePlot=no \
    BuscoDB=rickettsiales_odb10 \
    Racon=2

done
