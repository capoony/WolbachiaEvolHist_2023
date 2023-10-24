## investigate presence of wMel and wMelCS in DEST samples
PWD=/media/inter/mkapun/projects/WolbachiaEvolHist_2023

mkdir ${PWD}/results/DEST

pigz -dc /media/inter/mkapun/projects/ImPoolation/data/dest.all.PoolSNP.001.50.25Feb2023.norep.vcf.gz |
    awk '$1=="W_pipientis" || $1 ~/^#/' |
    pigz >${PWD}/results/DEST/DEST_wolb.fa.gz

gunzip -c /media/inter/mkapun/projects/ImPoolation/data/dest.all.PoolSNP.001.50.25Feb2023.norep.vcf.gz |
    grep -v '^>' |
    awk '{print $1}' |
    uniq
