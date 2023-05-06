## Subset BAM files to ~50x coverage

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/subset
mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/*.bam; do
    tmp=${i##*/}
    ID=${tmp%.bam*}
    echo ${ID}

    echo """

    ## App 200x coverage = 1300000/300 *200 ~ 88000

    module load Tools/samtools-1.12


    reads=130000
    bam=/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/${ID}.bam

    samtools index \$bam

    fraction=\$(samtools idxstats \$bam | cut -f3 | awk -v ct=\$reads 'BEGIN {total=0} {total += \$1} END {print ct/total}')

    if [ \"\$(echo \"if (\${fraction} > 1) 1\" | bc)\" -eq 1 ]; then
        echo 1 ${ID}
        cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/${ID}.bam \
            /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/subset/${ID}_sampled.bam

    else
        echo \${fraction} ${ID}
        samtools view -bs \${fraction} /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/${ID}.bam \
            >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/subset/${ID}_sampled.bam
    fi

    echo /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/subset/${ID}_sampled.bam \
        >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/bamlist_Wolb.txt
    
    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_subset.sh

    sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_subset.sh &

done

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/*.bam; do
    tmp=${i##*/}
    ID=${tmp%.bam*}
    echo ${ID}

    echo """

    ## App 200x coverage = 1300000/300 *200 ~ 88000

    module load Tools/samtools-1.12


    reads=130000
    bam=/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/${ID}.bam

    samtools index \$bam

    fraction=\$(samtools idxstats \$bam | cut -f3 | awk -v ct=\$reads 'BEGIN {total=0} {total += \$1} END {print ct/total}')

    if [ \"\$(echo \"if (\${fraction} > 1) 1\" | bc)\" -eq 1 ]; then
        echo 1 ${ID}
        cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/${ID}.bam \
            /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/subset/${ID}_sampled.bam

    else
        echo \${fraction} ${ID}
        samtools view -bs \${fraction} /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/${ID}.bam \
            >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/subset/${ID}_sampled.bam
    fi

    echo /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/subset/${ID}_sampled.bam \
        >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/bamlist_Wolb.txt
    
    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_subset.sh

    sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_subset.sh &

done

Samples=(Re1_full Re3 Re6_full Re10 Ak7_full Ak9_full MEL_full CS POP)

for i in ${!Samples[*]}; do
    ID=${Samples[i]}

    echo """

    ## App 50x coverage = 1300000/300 *50 ~ 22000

    module load Tools/samtools-1.12


    reads=22000
    bam=/media/inter/mkapun/projects/DrosoWolbGenomics/results/RefMapping/${ID}.bam

    samtools index \$bam

    fraction=\$(samtools idxstats \$bam | cut -f3 | awk -v ct=\$reads 'BEGIN {total=0} {total += \$1} END {print ct/total}')

    if [ \"\$(echo \"if (\${fraction} > 1) 1\" | bc)\" -eq 1 ]; then
        echo 1 ${ID}
        cp /media/inter/mkapun/projects/DrosoWolbGenomics/results/RefMapping/${ID}.bam \
            /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/subset/${ID}_sampled.bam

    else
        echo \${fraction} ${ID}
        samtools view -bs \${fraction} /media/inter/mkapun/projects/DrosoWolbGenomics/results/RefMapping/${ID}.bam \
            >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/subset/${ID}_sampled.bam
    fi

    echo /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping/subset/${ID}_sampled.bam \
        >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/bamlist_Wolb.txt
    
    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_subset.sh

    sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_subset.sh &

done

### now Mitochondria

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_mito/subset

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_mito/*.bam; do
    tmp=${i##*/}
    ID=${tmp%.bam*}
    echo ${ID}

    echo """

    ## App 50x coverage = 19000/300 *50 ~ 3200

    module load Tools/samtools-1.12


    reads=3200
    bam=/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_mito/${ID}.bam

    samtools index \$bam

    fraction=\$(samtools idxstats \$bam | cut -f3 | awk -v ct=\$reads 'BEGIN {total=0} {total += \$1} END {print ct/total}')

    if [ \"\$(echo \"if (\${fraction} > 1) 1\" | bc)\" -eq 1 ]; then
        echo 1 ${ID}
        cp /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_mito/${ID}.bam \
            /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_mito/subset/${ID}_sampled.bam

    else
        echo \${fraction} ${ID}
        samtools view -bs \${fraction} /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_mito/${ID}.bam \
            >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_mito/subset/${ID}_sampled.bam
    fi

    echo /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/mapping_mito/subset/${ID}_sampled.bam \
        >>/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/bamlist_Mito.txt
    
    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_mito_subset.sh

    sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_mito_subset.sh &

done
