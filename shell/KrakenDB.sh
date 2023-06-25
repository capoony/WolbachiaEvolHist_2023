## make Database for Wolbachia

### manually download FASTA files first, see RefSeq IDs in paper

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db

DATA=("wMel" "wMelCS" "wMelPop")
IDs=(163164 1379791 1317678)

for index in ${!DATA[@]}; do
    echo $((index + 1))": "${DATA[index]}
    Name=${DATA[index]}
    ID=${IDs[index]}
    awk -v ID=$ID '{if ($0~/>/) {print $1"|kraken:taxid|"ID} else {print}}' /media/inter/mkapun/projects/DrosoWolbGenomics/results/CompGenomics/FASTA/w1118_${Name}_start.fasta >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/w1118_${Name}_start.fasta
done

sudo -s
module load Assembly/kraken-2.1.2

DBNAME=/media/scratch/kraken-2.1.2/db/Wolbachia
kraken2-build \
    --use-ftp \
    --download-taxonomy \
    --db $DBNAME

for file in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/w1118_*_start.fasta; do
    kraken2-build \
        --add-to-library $file \
        --db $DBNAME
done

kraken2-build \
    --build \
    --db $DBNAME

### Make database for Mitochondria

cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data

wget -q -O - "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=NC_024511.2&rettype=fasta" >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/NC_024511.2.fa

# TaxID: 7227

awk '{if ($0~/>/) {print $1"|kraken:taxid|7227"} else {print}}' /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/NC_024511.2.fa >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/NC_024511.2_start.fasta

sudo -s
module load Assembly/kraken-2.1.2

DBNAME=/media/scratch/kraken-2.1.2/db/MitoDmel
kraken2-build \
    --use-ftp \
    --download-taxonomy \
    --db $DBNAME

kraken2-build \
    --add-to-library /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/NC_024511.2_start.fasta \
    --db $DBNAME

kraken2-build \
    --build \
    --db $DBNAME

cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data

## Get D. melanogaster Genome and make database with Dmel and wMelCS

curl -O http://ftp.flybase.net/releases/FB2023_02/dmel_r6.51/fasta/dmel-all-chromosome-r6.51.fasta.gz

pigz -d /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/dmel-all-chromosome-r6.51.fasta.gz

awk '{if ($0~/>/) {print $1"|kraken:taxid|7227"} else {print}}' /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/dmel-all-chromosome-r6.51.fasta \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/dmel-all-chromosome-r6.51_start.fasta

sudo -s
module load Assembly/kraken-2.1.2

DBNAME=/media/scratch/kraken-2.1.2/db/DrosoWolb
kraken2-build \
    --use-ftp \
    --download-taxonomy \
    --db $DBNAME

kraken2-build \
    --add-to-library /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/NC_024511.2_start.fasta \
    --db $DBNAME

kraken2-build \
    --add-to-library /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/w1118_wMelCS_start.fasta \
    --db $DBNAME

kraken2-build \
    --build \
    --db $DBNAME

## Get wMeg and build Library of Supergroups A and B

wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/008/245/065/GCF_008245065.1_ASM824506v1/GCF_008245065.1_ASM824506v1_genomic.fna.gz

awk '{if ($0~/>/) {print $1"|kraken:taxid|1335053"} else {print}}' /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GCF_008245065.1_ASM824506v1_genomic.fna \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GCF_008245065.1_ASM824506v1_genomic_DB.fna

sudo -s
module load Assembly/kraken-2.1.2

DBNAME=/media/scratch/kraken-2.1.2/db/Supergroups
kraken2-build \
    --use-ftp \
    --download-taxonomy \
    --db $DBNAME

kraken2-build \
    --add-to-library /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GCF_008245065.1_ASM824506v1_genomic_DB.fna \
    --db $DBNAME

kraken2-build \
    --add-to-library /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/w1118_wMelCS_start.fasta \
    --db $DBNAME

kraken2-build \
    --build \
    --db $DBNAME
