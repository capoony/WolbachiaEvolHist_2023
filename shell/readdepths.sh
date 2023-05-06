mkdir -p /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/ReadDepths/log

for i in /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/denovo/*; do

    ID=${i##*/}

    echo """
    #!/bin/sh

    ## name of Job
    #PBS -N Kraken_${ID}

    ## Redirect output stream to this file.
    #PBS -o /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/ReadDepths/${ID}_log.txt

    ## Stream Standard Output AND Standard Error to outputfile (see above)
    #PBS -j oe

    ## Select 50 cores and 300gb of RAM
    #PBS -l select=1:ncpus=50:mem=300g

    ######## load dependencies #######

    module load Assembly/kraken-2.1.2

    DBNAME=/media/scratch/kraken-2.1.2/db/DrosoWolb 

    kraken2 \
        --threads 100 \
        --gzip-compressed \
        --paired \
        --report /media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/ReadDepths/${ID}.report \
        --use-names \
        --db \$DBNAME \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/${ID}_1.fastq.gz \
        /media/inter/mkapun/projects/WolbachiaEvolHist_2023/data/reads/${ID}_2.fastq.gz  > /dev/null
        
    """ >/media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_cov.qsub

    qsub /media/inter/mkapun/projects/WolbachiaEvolHist_2023/shell/QSUB/${ID}_cov.qsub

done
