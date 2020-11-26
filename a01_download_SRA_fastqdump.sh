#!/bin/sh

#  download_SRA_fastqdump.sh
#  
#
#  Created by okamurak on 2019/10/24.
#
## Make SRR_Acc_list.txt using the SRA website "SRA Run Selector"
## first download  SRA files and then expand them into fastq format

export PATH=$PATH:${PWD}

usage() {
    echo "usage: download_SRA_fastqdump.sh <DATAPROCESSLIST>"
    echo "where: <DATAPROCESSLIST> is the SraAccList.txt file"
    
}

if [ $# -lt 1 ]; then
    usage
    exit
fi

DATAPROCESSLIST=$1

echo "Start"
date

while read -r LINE
do
    LIB=$(echo $LINE | awk '{print $1}')
    echo "variables to process"
    echo $LIB
    echo "download SRA file $LIB to $PWD"
    parallel-fastq-dump --threads 8  --gzip --sra-id $LIB

done < $1

echo "Done"
date







