### get wRi assembly

wget -qO - "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=CP001391.1&rettype=fasta" \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/refseq/data/wRi.fasta

### get BUSCO genes
cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/refseq/busco
source /opt/anaconda3/etc/profile.d/conda.sh
conda activate busco_5.2.2
busco -i /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/refseq/data/wRi.fasta \
    -o wRi \
    -m genome \
    -c 50 \
    -f \
    -l rickettsiales_odb10

### append sequence to BUSCO alignment
for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/*.fasta; do

    tmp=${i##*/}
    GENE=${tmp%_dna*}

    if [ -f "/media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/refseq/busco/wRi/run_rickettsiales_odb10/busco_sequences/single_copy_busco_sequences/${GENE}.fna" ]; then

        cat /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/refseq/busco/wRi/run_rickettsiales_odb10/busco_sequences/single_copy_busco_sequences/${GENE}.fna >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_genes2/${GENE}_dna.fasta

    fi

done

wget -qO - "https://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/Wolbachia_endosymbiont_of_Drosophila_yakuba/latest_assembly_versions/GCF_005862115.1_ASM586211v1/GCF_005862115.1_ASM586211v1_genomic.fna.gz" \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/refseq/data/wYak.fasta

cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/refseq/busco
source /opt/anaconda3/etc/profile.d/conda.sh
conda activate busco_5.2.2
busco -i /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/refseq/data/wYak.fasta \
    -o wYak \
    -m genome \
    -c 50 \
    -f \
    -l rickettsiales_odb10

## OK, simulate PE Illumina reads
module load Simulation/art-MountRainier

art_illumina \
    --paired \
    --in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/refseq/data/wYak.fasta \
    --out /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/wYak-pe100-reads \
    --len 100 \
    --fcov 100 \
    --mflen 400 \
    --sdev 0 \
    -ir 0.0 -ir2 0.0 -dr 0.0 -dr2 0.0 -qs 100 -qs2 100 -na

gzip /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/wYak-pe100-*

## map

module load NGSmapper/BBmap-38.90

reformat.sh in=/media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/wYak-pe100-reads1.fq.gz \
    out=/media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/wYak-pe100-reads1_p33.fq.gz \
    qin=64 qout=33

reformat.sh in1=/media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/wYak-pe100-reads2.fq.gz \
    out=/media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/wYak-pe100-reads2_p33.fq.gz \
    qin=64 qout=33

module load NGSmapper/bwa-0.7.13
module load NGSmapper/minimap2-2.17
module load Tools/samtools-1.12

bwa mem \
    -t 100 \
    /media/inter/mkapun/projects/DrosoWolbGenomics/data/AE017196.1_wMel.fa \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/wYak-pe100-reads1_p33.fq.gz \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/wYak-pe100-reads2_p33.fq.gz |
    samtools view -F 4 -bh | samtools sort \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/wYak.bam

samtools coverage /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/wYak.bam | awk -v ID="wYak" 'NR>1{print ID"\t"$0}' >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb_coverages.txt

echo /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/wYak.bam \
    >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/bamlist_Wolb.txt

echo /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/wYak.bam \
    >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/bamlist_Wolb_stringent.txt
