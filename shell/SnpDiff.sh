### manually make Groups file: /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/groups.txt

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/SnpDiff

python /media/inter/mkapun/projects/WolbachiaEvolHist_2023/scripts/SNPDiff.py \
    --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/MergedData/Wolb.phy \
    --groups /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/groups.txt \
    >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/SnpDiff/counts.txt

## Then make Pivot table In Excel
