#!/bin/bash -login
#$ -cwd
#$ -V

## Join standard error and standard output into 1 file output
#$ -j y
# Time-stamp: <2014-02-17 12:23:53 liling>

# Load perl module
#module load perl-5.14

usage() {
    echo "usage: getlistforpreprocessfastqgztllhpc.sh <DATAPROCESSLIST>"
    echo "where: <DATAPROCESSLIST> is a text file with each row for a library"
    echo "       to process with <LIB> <ADAPTER> <QUALSCORE> <MINLENGTH> <MAXLENGTH> <FXARTIFACTFILTER> <RANDOMNUC5P> <RANDOMNUC3P>"
    echo "       in which"
    echo "       <LIB> is the library name"
    echo "       <ADAPTER> is the adapter to clip"
    echo "       <QUALSCORE> is the quality score encoded in fastq file"
    echo "       <MINLENGTH> is the minimum read length"
    echo "       <MAXLENGTH> is the maximum read length"
    echo "       <FXARTIFACTFILTER> is the fastx artifact filtered file to remove reads with all but three identical bases"
    echo "       <RANDOMNUC5P> is the number of flanking random nucleotides to trim at 5p end"
    echo "       <RANDOMNUC3P> is the number of flanking random nucleotides to trim at 3p end"
    echo "       written in each row provided in a text file."
    echo "This script does the job of fetching the list of variables to pass to"
    echo "the script preprocessfastqIlluminatllhpcbz2multipleinput.sh."
}


# Minimal argument checking

if [ $# -lt 1 ]; then
    usage
    exit
fi

# Set variable for input file
DATAPROCESSLIST=$1

echo "Start"
date

while read -r LINE
do
    LIB=$(echo $LINE | awk '{print $1}')
    ADAPTER=$(echo $LINE | awk '{print $2}')
    QUALSCORE=$(echo $LINE | awk '{print $3}')
    MINLENGTH=$(echo $LINE | awk '{print $4}')
    MAXLENGTH=$(echo $LINE | awk '{print $5}')
    FXARTIFACTFILTER=$(echo $LINE | awk '{print $6}')
    RANDOMNUC5P=$(echo $LINE | awk '{print $7}')
    RANDOMNUC3P=$(echo $LINE | awk '{print $8}')
    echo "variables to process"
    echo $LIB $ADAPTER $QUALSCORE $MINLENGTH $MAXLENGTH $FXARTIFACTFILTER $RANDOMNUC5P $RANDOMNUC3P
    echo "run preprocessing"
    a1_Preprocess_Fastq.sh $LIB $ADAPTER $QUALSCORE $MINLENGTH $MAXLENGTH $FXARTIFACTFILTER $RANDOMNUC5P $RANDOMNUC3P
    ##echo "run fastx artifacts filter on length filtered collapsed fasta file"
    ##a2_preprocessfastxartifactsfilter.sh $LIB $ADAPTER $QUALSCORE $MINLENGTH $MAXLENGTH $FXARTIFACTFILTER
#don't run a3
#echo "move fasta files to correct location"
#a3_movefilestolocationtllhpc.sh $LIB $MINLENGTH $MAXLENGTH $FXARTIFACTFILTER
done < $1

echo "Done"
date
