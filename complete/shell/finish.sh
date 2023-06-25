Samples=(HG0027) #HG_09 HG_15 HG_16 HG_20 HG0026 HG47203 HG47204 377 378)
NewName=(HG0027) #Germany_Passau_1800_HG_09 Sweden_Lund_1933_HG_15 Sweden_Lund_1933_HG_16 Sweden_Lund_1933_HG_20 Sweden_Lund_1933_HG0026 Sweden_Lund_1933_HG47203 Sweden_Lund_1933_HG47204 Sweden_Lund_1800_377 Sweden_Lund_1800_378)

for i in ${!Samples[*]}; do
    Sample=${Samples[i]}
    New=${NewName[i]}
    echo $i ${Sample} ${New}

    mkdir -p /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/${New}/nucmer
    cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/${New}/nucmer

    conda activate mummer-3.23

    ## Use NUCMER to align all Wolbachia-specific contigs agains the reference.
    nucmer \
        -mum \
        -p ${New} \
        /media/inter/mkapun/projects/DrosoWolbGenomics/data/AE017196.1_wMel.fa \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/${Sample}/output/${Sample}_ILL.fa

    #combine contigs in order according to showtilingoutput in multifasta files

    delta-filter -q ${New}.delta >${New}.filter.delta

    show-coords -THrcl ${New}.filter.delta >${New}.coords

    show-tiling -i 20.0 -v 20.0 -V 0 -g -1 -R ${New}.filter.delta >${New}.tiling

    python /media/inter/mkapun/projects/DrosoWolbGenomics/scripts/CombineContigs.py \
        --tile ${New}.tiling \
        --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/${Sample}/output/${Sample}_ILL.fa \
        >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/${New}/nucmer/${New}.fasta

    python /media/inter/mkapun/projects/DrosoWolbGenomics/scripts/Scaffold.py \
        --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/${New}/nucmer/${New}.fasta \
        --Name ${New} |
        python /media/inter/mkapun/projects/DrosoWolbGenomics/scripts/SetStart.py \
            --reference /media/inter/mkapun/projects/DrosoWolbGenomics/data/AE017196.1_wMel.fa \
            --input - \
            >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/${New}/nucmer/${New}_start.fasta

done

## Now make multiple alignment with MAUVE

conda activate mauve-2.4.0

progressiveMauve --output=/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/Mauve_pM \
    /media/inter/mkapun/projects/DrosoWolbGenomics/data/AE017196.1_wMel.fa \
    /media/inter/mkapun/projects/DrosoWolbGenomics/results/CompGenomics/FASTA/w1118_wMel_start.fasta \
    /media/inter/mkapun/projects/DrosoWolbGenomics/results/CompGenomics/FASTA/Finland_wMel_AK7_start.fasta \
    /media/inter/mkapun/projects/DrosoWolbGenomics/results/CompGenomics/FASTA/Finland_wMel_AK9_start.fasta \
    /media/inter/mkapun/projects/DrosoWolbGenomics/results/CompGenomics/FASTA/Portugal_wMel_Re1_start.fasta \
    /media/inter/mkapun/projects/DrosoWolbGenomics/results/CompGenomics/FASTA/Portugal_wMel_Re6_start.fasta \
    /media/inter/mkapun/projects/DrosoWolbGenomics/results/CompGenomics/FASTA/Portugal_wMelCS_Re3_start.fasta \
    /media/inter/mkapun/projects/DrosoWolbGenomics/results/CompGenomics/FASTA/Portugal_wMelCS_Re10_start.fasta \
    /media/inter/mkapun/projects/DrosoWolbGenomics/results/CompGenomics/FASTA/w1118_wMelCS_start.fasta \
    /media/inter/mkapun/projects/DrosoWolbGenomics/results/CompGenomics/FASTA/w1118_wMelPop_start.fasta \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/Germany_Passau_1800_HG_09/nucmer/Germany_Passau_1800_HG_09_start.fasta \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/Sweden_Lund_1933_HG_15/nucmer/Sweden_Lund_1933_HG_15_start.fasta \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/Sweden_Lund_1933_HG_16/nucmer/Sweden_Lund_1933_HG_16_start.fasta \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/Sweden_Lund_1933_HG_20/nucmer/Sweden_Lund_1933_HG_20_start.fasta \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/Sweden_Lund_1933_HG0026/nucmer/Sweden_Lund_1933_HG0026_start.fasta \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/Sweden_Lund_1933_HG47203/nucmer/Sweden_Lund_1933_HG47203_start.fasta \
    /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/Sweden_Lund_1933_HG47204/nucmer/Sweden_Lund_1933_HG47204_start.fasta

## Open alignment in Mauve and store image as Mauve_image.png

Mauve

### now repeat for the two supergroupB samples

Samples=(HG0027 HG0029) #HG_09 HG_15 HG_16 HG_20 HG0026 HG47203 HG47204 377 378)
NewName=(H03 H05)       #Germany_Passau_1800_HG_09 Sweden_Lund_1933_HG_15 Sweden_Lund_1933_HG_16 Sweden_Lund_1933_HG_20 Sweden_Lund_1933_HG0026 Sweden_Lund_1933_HG47203 Sweden_Lund_1933_HG47204 Sweden_Lund_1800_377 Sweden_Lund_1800_378)

for i in ${!Samples[*]}; do
    Sample=${Samples[i]}
    New=${NewName[i]}
    echo $i ${Sample} ${New}

    mkdir -p /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/${New}/nucmer
    cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/${New}/nucmer

    conda activate mummer-3.23

    ## Use NUCMER to align all Wolbachia-specific contigs agains the reference.
    nucmer \
        -mum \
        -p ${New} \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/HG0027/GCF_008245065.1_ASM824506v1_genomic_DB.fna \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/${Sample}/output/${Sample}_ILL.fa

    #combine contigs in order according to showtilingoutput in multifasta files

    delta-filter -q ${New}.delta >${New}.filter.delta

    show-coords -THrcl ${New}.filter.delta >${New}.coords

    show-tiling -i 20.0 -v 20.0 -V 0 -g -1 -R ${New}.filter.delta >${New}.tiling

    python /media/inter/mkapun/projects/DrosoWolbGenomics/scripts/CombineContigs.py \
        --tile ${New}.tiling \
        --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/${Sample}/output/${Sample}_ILL.fa \
        >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/${New}/nucmer/${New}.fasta

    python /media/inter/mkapun/projects/DrosoWolbGenomics/scripts/Scaffold.py \
        --input /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/${New}/nucmer/${New}.fasta \
        --Name ${New} |
        python /media/inter/mkapun/projects/DrosoWolbGenomics/scripts/SetStart.py \
            --reference /media/inter/mkapun/projects/DrosoWolbGenomics/data/AE017196.1_wMel.fa \
            --input - \
            >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/${New}/nucmer/${New}_start.fasta

done

### BUSCO

for i in ${!Samples[*]}; do
    Sample=${Samples[i]}
    New=${NewName[i]}
    echo $i ${Sample} ${New}

    echo """

  #!/bin/sh

  ## name of Job
  #PBS -N BUSCO_${ID}

  ## Redirect output stream to this file.
  #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/refseq/busco/log/Busco_${New}_log.txt

  ## Stream Standard Output AND Standard Error to outputfile (see above)
  #PBS -j oe

  ## Select 50 cores and 200gb of RAM
  #PBS -l select=1:ncpus=50:mem=200g

  ######## load dependencies #######

  source /opt/anaconda3/etc/profile.d/conda.sh
  conda activate busco_5.2.2

  ######## run analyses #######

  ## Go to pwd
  cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/refseq/busco

  busco -i /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/DraftGenome/${New}/nucmer/${New}_start.fasta \
       -o ${New}  \
          -m genome  \
             -c 50  \
                -f  \
                   -l rickettsiales_odb10
    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${New}_Busco.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${New}_Busco.qsub

done
