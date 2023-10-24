PWD=/media/inter/mkapun/projects/WolbachiaEvolHist_2023

cd ${PWD}/data

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

done <${PWD}/data/SupergroupB.txt

### Include historic samples
cp ${PWD}/data/reads/HG0029_*.fastq.gz ${PWD}/data/reads_SB
cp ${PWD}/data/reads/HG0027_*.fastq.gz ${PWD}/data/reads_SB
cp ${PWD}/data/reads/HG0026_*.fastq.gz ${PWD}/data/reads_SB
cp ${PWD}/data/reads/HG47205_*.fastq.gz ${PWD}/data/reads_SB
cp ${PWD}/data/reads/HG47204_*.fastq.gz ${PWD}/data/reads_SB

mkdir ${PWD}/data/trim_SB

for i in ${PWD}/data/reads_SB/*_1.fastq.gz; do

    tmp=${i##*/}

    ID=${tmp%_1.f*}

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N trim_galore_${ID}

    ## Redirect output stream to this file.
    #PBS -o ${PWD}/data/trim_SB/${ID}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select 50 cores and 200gb of RAM
    #PBS -l select=1:ncpus=100:mem=200g

    ######## load dependencies #######

    source /opt/anaconda3/etc/profile.d/conda.sh
    conda activate trim-galore-0.6.2

    ## Go to output folder
    cd ${PWD}/data/trim_SB

    ## loop through all FASTQ pairs and trim by quality PHRED 20, min length 30bp and automatically detect & remove adapters

    trim_galore   \
        --paired   \
        --quality 20   \
        --length 30    \
        --cores 100   \
        --gzip   \
        ${PWD}/data/reads_SB/${ID}_1.fastq.gz   \
        ${PWD}/data/reads_SB/${ID}_2.fastq.gz

    """ >${PWD}/shell/QSUB/trim_SB_${ID}.txt

    sh ${PWD}/shell/QSUB/trim_SB_${ID}.txt

done

#### mapping against wMeg

## index reference

mkdir ${PWD}/results/mapping_SB

gzip ${PWD}/results/HG0027/GCF_008245065.1_ASM824506v1_genomic_DB.fna

module load NGSmapper/bwa-0.7.13
bwa index ${PWD}/results/HG0027/GCF_008245065.1_ASM824506v1_genomic_DB.fna.gz

for i in ${PWD}/data/reads_SB/*_1.fastq.gz; do

    tmp=${i##*/}

    ID=${tmp%_1.f*}

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N Annotation_${Species}

    ## Redirect output stream to this file.
    #PBS -o ${PWD}/results/mapping_SB/${ID}_log.txt

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
        ${PWD}/results/HG0027/GCF_008245065.1_ASM824506v1_genomic_DB.fna.gz \
        ${PWD}/data/trim_SB/${ID}_1_val_1.fq.gz \
        ${PWD}/data/trim_SB/${ID}_2_val_2.fq.gz |
        samtools view  -F 4 -bh | samtools sort \
        >${PWD}/results//mapping_SB/${ID}.bam

    """ >${PWD}/shell/QSUB/${ID}_mapping_SB.qsub

    sh ${PWD}/shell/QSUB/${ID}_mapping_SB.qsub

done

module load Tools/bcftools-1.16
module load Tools/samtools-1.12

### now merge BAMs
mkdir ${PWD}/results/MergedData_SB
for i in ${PWD}/results/mapping_SB/*.bam; do
    echo $i >>${PWD}/results/MergedData_SB/bamlist_Wolb.txt

done

for i in ${PWD}/results/mapping_SB/*.bam; do
    samtools index $i &
done

#### OK, now try to get the consensus for alignments

mkdir ${PWD}/results/Gryllus

## manually download the two available nucleotide sequences from Genbank: https://www.ncbi.nlm.nih.gov/nuccore/?term=txid1346729[Organism:noexp] as ${PWD}/results/Gryllus/Wolb_Gryll.fa

source /opt/anaconda3/etc/profile.d/conda.sh
conda activate exonerate-2.4.0

gunzip ${PWD}/data/db/AE017196.1_wMel.fa.gz
gunzip ${PWD}/results/HG0027/GCF_008245065.1_ASM824506v1_genomic_DB.fna.gz

exonerate \
    ${PWD}/results/Gryllus/Wolb_Gryll.fa \
    ${PWD}/results/HG0027/GCF_008245065.1_ASM824506v1_genomic_DB.fna \
    --showtargetgff \
    --showalignment \
    --showvulgar \
    --model affine:local \
    --showsugar \
    --ryo ">376_%qi_%qd_%ti_(%tab-%tae)\n%tas\n" \
    >${PWD}/results/Gryllus/Wolb_Gryll.full

## OK; the expected region for wsp is 474881 -> 475479
## now extract the corresponding region

module load Tools/samtools-1.18

for i in ${PWD}/results/mapping_SB/*.bam; do
    tmp=${i##*/}

    ID=${tmp%.bam*}

    samtools view -bh ${PWD}/results/mapping_SB/${ID}.bam "NZ_CP021120.1|kraken:taxid|1335053:474800-475500" |
        samtools consensus -f fasta - |
        sed "s/NZ_CP021120.1|kraken:taxid|1335053/${ID}/g" \
            >>${PWD}/results/Gryllus/Wolb_Gryll2.fa

done

## align

conda activate mafft-7.487

mafft \
    --thread 50 \
    --auto \
    --adjustdirection \
    ${PWD}/results/Gryllus/Wolb_Gryll2.fa \
    >${PWD}/results/Gryllus/Wolb_Gryll2_aln.fa

## make phylogenetic tree
sh ${PWD}/shell/makePhylo_MidpointRoot.sh \
    ${PWD}/results/Gryllus/wsp2 \
    ${PWD}/results/Gryllus/Wolb_Gryll2_aln.fa \
    Wolbachia_wsp \
    0.02 \
    8 \
    8 \
    no
