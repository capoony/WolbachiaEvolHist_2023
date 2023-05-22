## download Datasets

mkdir /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/refseq

cd /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/refseq

wget ftp://ftp.ncbi.nih.gov/genomes/refseq/bacteria/assembly_summary.txt

grep 'wMel' assembly_summary.txt |
    grep -v 'Aedes' |
    awk -F '\t' '{print $9$10","$20}' |
    sed 's/strain=//g' >assembly_summary_complete_genomes.txt

mkdir data
## obtain and rename read data for all samples from input file
while
    IFS=','
    read -r ID link
do
    echo ${link##*/}
    wget -O data/${ID}.fa.gz $link/${link##*/}_genomic.fna.gz

done <assembly_summary_complete_genomes.txt

### BUSCO

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
  #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/refseq/busco/log/Busco_${ID}_log.txt

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

  gunzip /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/refseq/data/${ID}.fa.gz

  busco -i /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/refseq/data/${ID}.fa \
       -o ${ID}  \
          -m genome  \
             -c 50  \
                -f  \
                   -l rickettsiales_odb10
    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_Busco.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_Busco.qsub

done <assembly_summary_complete_genomes.txt
