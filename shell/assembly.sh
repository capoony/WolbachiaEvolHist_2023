mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/*_1.fq.gz; do
    tmp=${i##*/}
    ID=${tmp%_*}
    echo ${ID}

    echo """
    /media/inter/pipelines/AutDeNovo/AutDeNovo.sh \
        Name=${ID} \
        OutputFolder=/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/${ID} \
        Fwd=/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/${ID}_1.fq.gz \
        Rev=/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/kraken/${ID}_2.fq.gz \
        threads=50 \
        RAM=200 \
        RAMAssembly=500 \
        decont=no \
        SmudgePlot=no \
        BuscoDB=rickettsiales_odb10 \
        Trimmer=TrimGalore \
        MinReadLen=35 \
        BaseQuality=20 
    
    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_denovo.sh

    sh /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_denovo.sh &

done

### now compare BUSCO results

mkdir -p /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_summaries

cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo

find -iname "*short_summary.*.txt" -exec cp "{}" /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_summaries \;

source /opt/anaconda3/etc/profile.d/conda.sh
conda activate busco_5.2.2

python3.9 /opt/anaconda3/envs/busco_5.2.2/bin/generate_plot.py \
    -wd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/CompGenomes/busco_summaries
