PWD=/media/inter/mkapun/projects/WolbachiaEvolHist_2023

mkdir ${PWD}/results/denovo

for i in 377 378 HG_09 HG_15 HG_16 HG_20 HG0026 HG0034 HG47203 HG47204; do

    echo """
    /media/inter/pipelines/AutDeNovo/AutDeNovo.sh \
        Name=${ID} \
        OutputFolder=${PWD}/results/denovo/${ID} \
        Fwd=${PWD}/results/kraken/${ID}_1.fq.gz \
        Rev=${PWD}/results/kraken/${ID}_2.fq.gz \
        threads=50 \
        RAM=200 \
        RAMAssembly=500 \
        decont=no \
        SmudgePlot=no \
        BuscoDB=rickettsiales_odb10 \
        Trimmer=TrimGalore \
        MinReadLen=35 \
        BaseQuality=20 \
        Racon=2
    
    """ >${PWD}/shell/QSUB/${ID}_denovo.sh

    sh ${PWD}/shell/QSUB/${ID}_denovo.sh &

done

### now compare BUSCO results

mkdir -p ${PWD}/results/CompGenomes/busco_summaries

cd ${PWD}/results/denovo

find -iname "*short_summary.*.txt" -exec cp "{}" ${PWD}/results/CompGenomes/busco_summaries \;

source /opt/anaconda3/etc/profile.d/conda.sh
conda activate busco_5.2.2

python3.9 /opt/anaconda3/envs/busco_5.2.2/bin/generate_plot.py \
    -wd ${PWD}/results/CompGenomes/busco_summaries

cp ${PWD}/results/assemblies_ONT/*/results/AssemblyQC/Busco/*/short_summary.specific.rickettsiales_odb10.*.txt ${PWD}/results/CompGenomes/busco_summaries_red

python3.9 /opt/anaconda3/envs/busco_5.2.2/bin/generate_plot.py \
    -wd ${PWD}/results/CompGenomes/busco_summaries_red

cp ${PWD}/results/CompGenomes/busco_summaries_red/busco_figure.pdf ${PWD}/output/busco/busco_figure_red.pdf

cp ${PWD}/results/CompGenomes/busco_summaries_red/busco_figure.png ${PWD}/output/busco/busco_figure_red.png
