## make Database for Wolbachia
PWD=/media/inter/mkapun/projects/WolbachiaEvolHist_2023

### use the de-novo assemblies of MEL, CS and POP to create a DB to prefilter reads

mkdir ${PWD}/data/db

DATA=("wMel" "wMelCS" "wMelPop")
IDs=(163164 1379791 1317678)

for index in ${!DATA[@]}; do
    echo $((index + 1))": "${DATA[index]}
    Name=${DATA[index]}
    ID=${IDs[index]}
    awk -v ID=$ID '{if ($0~/>/) {print $1"|kraken:taxid|"ID} else {print}}' /media/inter/mkapun/projects/DrosoWolbGenomics/results/CompGenomics/FASTA/w1118_${Name}_start.fasta >${PWD}/data/db/w1118_${Name}_start.fasta
done

sudo -s
module load Assembly/kraken-2.1.2

DBNAME=/media/scratch/kraken-2.1.2/db/Wolbachia
kraken2-build \
    --use-ftp \
    --download-taxonomy \
    --db $DBNAME

for file in ${PWD}/data/db/w1118_*_start.fasta; do
    kraken2-build \
        --add-to-library $file \
        --db $DBNAME
done

kraken2-build \
    --build \
    --db $DBNAME

### Make database for Mitochondira

## now the same for mitochondria

cd ${PWD}/data

wget -q -O - "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=NC_024511.2&rettype=fasta" >${PWD}/data/NC_024511.2.fa

# TaxID: 7227

awk '{if ($0~/>/) {print $1"|kraken:taxid|7227"} else {print}}' ${PWD}/data/NC_024511.2.fa >${PWD}/data/db/NC_024511.2_start.fasta

sudo -s
module load Assembly/kraken-2.1.2

DBNAME=/media/scratch/kraken-2.1.2/db/MitoDmel
kraken2-build \
    --use-ftp \
    --download-taxonomy \
    --db $DBNAME

kraken2-build \
    --add-to-library ${PWD}/data/db/NC_024511.2_start.fasta \
    --db $DBNAME

kraken2-build \
    --build \
    --db $DBNAME

cd ${PWD}/data

curl -O http://ftp.flybase.net/releases/FB2023_02/dmel_r6.51/fasta/dmel-all-chromosome-r6.51.fasta.gz

pigz -d ${PWD}/data/dmel-all-chromosome-r6.51.fasta.gz

awk '{if ($0~/>/) {print $1"|kraken:taxid|7227"} else {print}}' ${PWD}/data/dmel-all-chromosome-r6.51.fasta \
    >${PWD}/data/dmel-all-chromosome-r6.51_start.fasta

sudo -s
module load Assembly/kraken-2.1.2

DBNAME=/media/scratch/kraken-2.1.2/db/DrosoWolb
kraken2-build \
    --use-ftp \
    --download-taxonomy \
    --db $DBNAME

kraken2-build \
    --add-to-library ${PWD}/data/db/NC_024511.2_start.fasta \
    --db $DBNAME

kraken2-build \
    --add-to-library ${PWD}/data/db/w1118_wMelCS_start.fasta \
    --db $DBNAME

kraken2-build \
    --build \
    --db $DBNAME

###### now add wMeg for Supergroup A & B db

awk '{if ($0~/>/) {print $1"|kraken:taxid|1335053"} else {print}}' ${PWD}/results/HG0027/GCF_008245065.1_ASM824506v1_genomic.fna \
    >${PWD}/results/HG0027/GCF_008245065.1_ASM824506v1_genomic_DB.fna

sudo -s
module load Assembly/kraken-2.1.2

DBNAME=/media/scratch/kraken-2.1.2/db/Supergroups
kraken2-build \
    --use-ftp \
    --download-taxonomy \
    --db $DBNAME

kraken2-build \
    --add-to-library ${PWD}/results/HG0027/GCF_008245065.1_ASM824506v1_genomic_DB.fna \
    --db $DBNAME

kraken2-build \
    --add-to-library ${PWD}/data/db/w1118_wMelCS_start.fasta \
    --db $DBNAME

kraken2-build \
    --build \
    --db $DBNAME
