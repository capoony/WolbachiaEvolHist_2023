##  First make denovo assemblies of wMelCS-typ libraries

Samples=(Re3 Re10 CS POP)
Barcodes=(04 06 10 16)

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

##  Then combine two ONT runs for wMel samples make denovo assemblies

Samples=(Re1 Re6 Ak7 Ak9 MEL)
Barcodes=(03 05 07 08 09)
Barcodes2=(18 19 20 21 17)

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/CombinedMel

for i in ${!Samples[*]}; do
  Sample=${Samples[i]}
  Barcode=${Barcodes[i]}
  Barcode2=${Barcodes2[i]}

  echo $i $Sample $Barcode

  mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/CombinedMel/${Samples[i]}

  cp /media/inter/SeqData/raw/MinION/20221013_DrosoWolbGenomics/SUP/FASTQ/barcode${Barcode}/*.gz \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/CombinedMel/${Samples[i]}

  cp /media/inter/SeqData/raw/MinION/20230202_DrosoWolbGenomics2/SUP/FASTQ/barcode${Barcode2}/*.gz \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/CombinedMel/${Samples[i]}

  /media/inter/pipelines/AutDeNovo/AutDeNovo.sh \
    Name=${Sample}_full \
    OutputFolder=/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/assemblies_ONT/${Sample}_full \
    ONT=/media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/CombinedMel/${Samples[i]} \
    threads=100 \
    RAM=400 \
    RAMAssembly=800 \
    decont=no \
    SmudgePlot=no \
    BuscoDB=rickettsiales_odb10 \
    Racon=2

  rm -rf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/assemblies_ONT/${Sample}

done

rm -rf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/CombinedMel

## prepapre for SRA upload
mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/SRA

Samples=(Re1_1 Re3 Re6_1 Re10 Ak7_1 Ak9_1 MEL_1 CS POP)
Barcodes=(03 04 05 06 07 08 09 10 16)

for i in ${!Samples[*]}; do
  Sample=${Samples[i]}
  Barcode=${Barcodes[i]}

  cat /media/inter/SeqData/raw/MinION/20221013_DrosoWolbGenomics/SUP/FASTQ/barcode${Barcode}/*.fastq.gz \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/SRA/${Sample}.fq.gz

done

Samples=(Re1_2 Re6_2 Ak7_2 Ak9_2 MEL_2)
Barcodes2=(18 19 20 21 17)

for i in ${!Samples[*]}; do
  Sample=${Samples[i]}
  Barcode=${Barcodes2[i]}

  cat /media/inter/SeqData/raw/MinION/20230202_DrosoWolbGenomics2/SUP/FASTQ/barcode${Barcode}/*.fastq.gz \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/SRA/${Sample}.fq.gz

done
