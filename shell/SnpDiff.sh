### manually make Groups file: ${PWD}/data/groups.txt
PWD=/media/inter/mkapun/projects/WolbachiaEvolHist_2023

mkdir ${PWD}/results/SnpDiff

python ${PWD}/scripts/SNPDiff.py \
    --input ${PWD}/results/MergedData/Wolb.phy \
    --groups ${PWD}/data/groups.txt \
    >${PWD}/results/SnpDiff/counts.txt

## Then make Pivot table In Excel
