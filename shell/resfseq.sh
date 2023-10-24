## download Datasets
PWD=/media/inter/mkapun/projects/WolbachiaEvolHist_2023

mkdir ${PWD}/data/refseq

cd ${PWD}/data/refseq

## get full list of available bacterial RefSeq genomes
wget ftp://ftp.ncbi.nih.gov/genomes/refseq/bacteria/assembly_summary.txt

## filter for wMel-type genomes that are NOT in Aedes
grep 'wMel' assembly_summary.txt |
    grep -v 'Aedes' |
    awk -F '\t' '{print $9$10","$20}' |
    sed 's/strain=//g' >assembly_summary_complete_genomes.txt

grep 'wMel' assembly_summary.txt |
    grep -v 'Aedes' >assembly_summary_list_genomes.txt

mkdir data

## obtain and rename read data for all samples from input file
while
    IFS=','
    read -r ID link
do
    echo ${link##*/}
    wget -O data/${ID}.fa.gz $link/${link##*/}_genomic.fna.gz

done <assembly_summary_complete_genomes.txt

### BUSCO analysis

mkdir -p busco/log

while
    IFS=','
    read -r ID link
do
    echo """

  #!/bin/sh

  ## name of Job
  #PBS -N BUSCO_${ID}

  ## Redirect output stream to this file.
  #PBS -o ${PWD}/data/refseq/busco/log/Busco_${ID}_log.txt

  ## Stream Standard Output AND Standard Error to outputfile (see above)
  #PBS -j oe

  ## Select 50 cores and 200gb of RAM
  #PBS -l select=1:ncpus=50:mem=200g

  ######## load dependencies #######

  source /opt/anaconda3/etc/profile.d/conda.sh
  conda activate busco_5.2.2

  ######## run analyses #######

  ## Go to pwd
  cd ${PWD}/data/refseq/busco

  gunzip ${PWD}/data/refseq/data/${ID}.fa.gz

  busco -i ${PWD}/data/refseq/data/${ID}.fa \
       -o ${ID}  \
          -m genome  \
             -c 50  \
                -f  \
                   -l rickettsiales_odb10
    """ >${PWD}/shell/QSUB/${ID}_Busco.qsub

    qsub ${PWD}/shell/QSUB/${ID}_Busco.qsub

done <assembly_summary_complete_genomes.txt
