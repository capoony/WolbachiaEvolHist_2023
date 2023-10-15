cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data

## I manually picked Samples from Supergroup B from the Table S5 in Scholz et al. 2020 and randomly chose 2 at most 2 samples per species.

## obtain and rename read data for all samples from input file
module load Tools/SRAtools-2.11.2

while
    IFS=','
    read -r SRR ID
do
    ## if not Illumina only convert to FASTQ

    echo """
      fasterq-dump \
        --split-3 \
        -o ${ID} \
        -O reads_SB \
        -e 8 \
        -f \
        -p \
        ${SRR}

      pigz reads_SB/${ID}*
      """ >../shell/QSUB/${ID}.sh

    sh ../shell/QSUB/${ID}.sh &

done </media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/SupergroupB.txt

### Include samples H03 and H05 (HG0027 and HG0029)
cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/HG0029_*.fastq.gz /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads_SB
cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/HG0027_*.fastq.gz /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads_SB
cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/HG47205_*.fastq.gz /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads_SB

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim_SB

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads_SB/*_1.fastq.gz; do

    tmp=${i##*/}

    ID=${tmp%_1.f*}

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N trim_galore_${ID}

    ## Redirect output stream to this file.
    #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim_SB/${ID}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select 50 cores and 200gb of RAM
    #PBS -l select=1:ncpus=100:mem=200g

    ######## load dependencies #######

    source /opt/anaconda3/etc/profile.d/conda.sh
    conda activate trim-galore-0.6.2

    ## Go to output folder
    cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim_SB

    ## loop through all FASTQ pairs and trim by quality PHRED 20, min length 30bp and automatically detect & remove adapters

    trim_galore   \
        --paired   \
        --quality 20   \
        --length 30    \
        --cores 100   \
        --gzip   \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads_SB/${ID}_1.fastq.gz   \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads_SB/${ID}_2.fastq.gz

    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/trim_SB_${ID}.txt

    sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/trim_SB_${ID}.txt

done

#### mapping against wMeg

## index reference

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_SB

gzip /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GCF_008245065.1_ASM824506v1_genomic_DB.fna

module load NGSmapper/bwa-0.7.13
bwa index /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GCF_008245065.1_ASM824506v1_genomic_DB.fna.gz

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads_SB/*_1.fastq.gz; do

    tmp=${i##*/}

    ID=${tmp%_1.f*}

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N Annotation_${Species}

    ## Redirect output stream to this file.
    #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_SB/${ID}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select a maximum walltime of 2h
    #PBS -l walltime=100:00:00

    ## Select a maximum of 20 cores and 500gb of RAM
    #PBS -l select=1:ncpus=100:mem=100gb

    ### dependenceies

    module load NGSmapper/bwa-0.7.13
    module load NGSmapper/minimap2-2.17
    module load Tools/samtools-1.12

    bwa mem \
        -t 100 \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GCF_008245065.1_ASM824506v1_genomic_DB.fna.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim_SB/${ID}_1_val_1.fq.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/trim_SB/${ID}_2_val_2.fq.gz |
        samtools view  -F 4 -bh | samtools sort \
        >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results//mapping_SB/${ID}.bam

    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_mapping_SB.qsub

    sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_mapping_SB.qsub

done

module load Tools/bcftools-1.16
module load Tools/samtools-1.12

### now merge BAMs
mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData_SB
for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_SB/*.bam; do
    echo $i >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData_SB/bamlist_Wolb.txt

done

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_SB/*.bam; do
    samtools index $i &
done

### GRYLLUSSSSS??
cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data

module load Tools/SRAtools-2.11.2

while
    IFS=','
    read -r SRR ID
do
    ## if not Illumina only convert to FASTQ

    echo """
      fasterq-dump \
        --split-3 \
        -o ${ID} \
        -O reads_SB \
        -e 8 \
        -f \
        -p \
        ${SRR}

      pigz reads_SB/${ID}*
      """ >../shell/QSUB/${ID}.sh

    sh ../shell/QSUB/${ID}.sh &

done </media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/Gryllus.txt

for i in 5 8; do

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N Kraken_${i}

    ## Redirect output stream to this file.
    #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/${ID}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select 50 cores and 300gb of RAM
    #PBS -l select=1:ncpus=40:mem=200g

    ######## load dependencies #######

    module load Assembly/kraken-2.1.2

    DBNAME=/media/scratch/kraken-2.1.2/db/Supergroups

    kraken2 \
        --threads 40 \
        --gzip-compressed \
        --report /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/Gryllus_bimaculatus_${i}.report \
        --use-names \
        --db \$DBNAME \
        --paired \
        --classified-out /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/Gryllus_bimaculatus_${i}#.fq \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads_SB/Gryllus_bimaculatus_${i}_1.fastq.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads_SB/Gryllus_bimaculatus_${i}_2.fastq.gz  > /dev/null
    
    
    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/Gryllus_bimaculatus_${i}_kraken.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/Gryllus_bimaculatus_${i}_kraken.qsub

done

module load NGSmapper/bwa-0.7.13
bwa index /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GCF_008245065.1_ASM824506v1_genomic_DB.fna.gz

for i in 5 8; do

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N Annotation_${Species}

    ## Redirect output stream to this file.
    #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_SB/${i}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select a maximum walltime of 2h
    #PBS -l walltime=100:00:00

    ## Select a maximum of 20 cores and 500gb of RAM
    #PBS -l select=1:ncpus=50:mem=100gb

    ### dependenceies

    module load NGSmapper/bwa-0.7.13
    module load NGSmapper/minimap2-2.17
    module load Tools/samtools-1.12

    bwa mem \
        -t 50 \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GCF_008245065.1_ASM824506v1_genomic_DB.fna.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/Gryllus_bimaculatus_${i}_1.fq \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/Gryllus_bimaculatus_${i}_2.fq |
        samtools view  -F 4 -bh | samtools sort \
        >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_SB/Gryllus_bimaculatus_${i}.bam

    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/Gryllus_bimaculatus_${i}_mapping_SB.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/Gryllus_bimaculatus_${i}_mapping_SB.qsub

done

for i in 5 8; do

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N Annotation_${Species}

    ## Redirect output stream to this file.
    #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_SB/${i}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select a maximum walltime of 2h
    #PBS -l walltime=100:00:00

    ## Select a maximum of 20 cores and 500gb of RAM
    #PBS -l select=1:ncpus=100:mem=100gb

    ### dependenceies

    module load NGSmapper/bwa-0.7.13
    module load NGSmapper/minimap2-2.17
    module load Tools/samtools-1.12

    bwa mem \
        -t 100 \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/AE017196.1_wMel.fa.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/Gryllus_bimaculatus_${i}_1.fq \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/Gryllus_bimaculatus_${i}_2.fq |
        samtools view  -F 4 -bh | samtools sort \
        >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_SB/Gryllus_bimaculatus_${i}_wMel.bam

    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/Gryllus_bimaculatus_${i}_mapping_SB_wMel.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/Gryllus_bimaculatus_${i}_mapping_SB_wMel.qsub

done

gunzip /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GCF_008245065.1_ASM824506v1_genomic_DB.fna.gz

####

module load Tools/bcftools-1.16
module load Tools/samtools-1.12

## SNP calling of Wolbachia reads of Supergroup B
bcftools mpileup \
    -Bf /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GCF_008245065.1_ASM824506v1_genomic_DB.fna \
    -b /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData_SB/bamlist_Wolb.txt \
    -a AD,DP \
    -d 1000 \
    -Ou |
    bcftools call \
        -O z --ploidy 1 \
        -c \
        -v \
        -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData_SB/Wolb.vcf.gz

## select SNPs and make phylip input

python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/BCF2Phylip.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData_SB/Wolb.vcf.gz \
    --MinAlt 1 \
    --MaxPropGaps 0.99 \
    --MinCov 1 \
    --exclude NA \
    --names /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/names_SB.txt \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData_SB/Wolb2.phy

## make phylogenetic tree
sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/makePhylo_MidpointRoot.sh \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/phylogney/Wolb_SB2 \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData_SB/Wolb2.phy \
    Wolbachia2 \
    0.3 \
    8 \
    8 \
    no

#### OK, now try to get the consensus for alignments

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Gryllus

## manually download the two available nucleotide sequences from Genbank: https://www.ncbi.nlm.nih.gov/nuccore/?term=txid1346729[Organism:noexp] as /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Gryllus/Wolb_Gryll.fa

source /opt/anaconda3/etc/profile.d/conda.sh
conda activate exonerate-2.4.0

gunzip /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/db/AE017196.1_wMel.fa.gz
gunzip /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GCF_008245065.1_ASM824506v1_genomic_DB.fna.gz

exonerate \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Gryllus/Wolb_Gryll.fa \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GCF_008245065.1_ASM824506v1_genomic_DB.fna \
    --showtargetgff \
    --showalignment \
    --showvulgar \
    --model affine:local \
    --showsugar \
    --ryo ">376_%qi_%qd_%ti_(%tab-%tae)\n%tas\n" \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Gryllus/Wolb_Gryll.full

## OK; the expected region for wsp is 474881 -> 475479
## now extract the corresponding region

module load Tools/samtools-1.18

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_SB/*.bam; do
    tmp=${i##*/}

    ID=${tmp%.bam*}
    ID=HG47205
    samtools view -bh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_SB/${ID}.bam "NZ_CP021120.1|kraken:taxid|1335053:474800-475500" |
        samtools consensus -f fasta - |
        sed "s/NZ_CP021120.1|kraken:taxid|1335053/${ID}/g" \
            >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Gryllus/Wolb_Gryll2.fa

done

## align

conda activate mafft-7.487

mafft \
    --thread 50 \
    --auto \
    --adjustdirection \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Gryllus/Wolb_Gryll2.fa \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Gryllus/Wolb_Gryll2_aln.fa

## make phylogenetic tree
sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/makePhylo_MidpointRoot.sh \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Gryllus/wsp2 \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Gryllus/Wolb_Gryll2_aln.fa \
    Wolbachia_wsp \
    0.02 \
    8 \
    8 \
    no
