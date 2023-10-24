## Dyak Wolkbachia
PWD=/media/inter/mkapun/projects/WolbachiaEvolHist_2023

wget -qO - "https://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/Wolbachia_endosymbiont_of_Drosophila_yakuba/latest_assembly_versions/GCF_005862115.1_ASM586211v1/GCF_005862115.1_ASM586211v1_genomic.fna.gz" \
    >${PWD}/data/refseq/data/wYak.fasta

cd ${PWD}/data/refseq/busco
source /opt/anaconda3/etc/profile.d/conda.sh
conda activate busco_5.2.2
busco -i ${PWD}/data/refseq/data/wYak.fasta \
    -o wYak \
    -m genome \
    -c 50 \
    -f \
    -l rickettsiales_odb10
