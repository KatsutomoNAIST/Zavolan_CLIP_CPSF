#!/bin/bash -login
#$ -cwd
#$ -V

## Join standard error and standard output into 1 file output
#$ -j y
# Time-stamp: <2016-03-08 19:37:23 liling>

# Load perl module
#module load perl-5.14

# set script to exit when there is an error
set -e

# set locale
export LC_ALL="C"

usage() {
    echo "usage: preprocessfastqgzwithflankrandomnucleotide.sh <LIB> <ADAPTER> <QUALSCORE> <MINLENGTH> <MAXLENGTH> <RANDOMNUC5P> <RANDOMNUC3P>"
    echo "where: <LIB> is the library name"
    echo "       <ADAPTER> is the adapter to clip"
    echo "       <QUALSCORE> is the quality score encoded in fastq file"
    echo "       <MINLENGTH> is the minimum read length"
    echo "       <MAXLENGTH> is the maximum read length"
    echo "       <RANDOMNUC5P> is the number of flanking random nucleotides to trim at 5p end"
    echo "       <RANDOMNUC3P> is the number of flanking random nucleotides to trim at 3p end"
    echo "       written in each row provided in a tab-separated text file."
    echo "This script does the job of preprocessing fastq files"
    echo "from Illumina sequencing with a list of variables."
    echo "Fastq file is FastQCed, gunzip, clipped "
   
}


############################################################################################################################################
# Requirements:
# gawk, gnu coreutils, gnu sed, fastx_toolkit, seqtk
############################################################################################################################################

export PATH=$PATH:/data/OkamuraLab/local/packagecode/seqtkgithubr76/seqtk

# Minimal argument checking
if [ $# -lt 5 ]; then
    usage
    exit
fi

# Set variables
LIB=$1         #library name
ADAPTER=$2     #adapter sequence to clip
QUALSCORE=$3   #fastq quality score according to fastQC, Q33 or Q64
MINLENGTH=$4   #18
MAXLENGTH=$5   #30
RANDOMNUC5P=$6 #0
RANDOMNUC3P=$7 #2

LENGTHFILTERFASTA=l${MINLENGTH}t${MAXLENGTH}nt

echo "check locale setting"
locale

printf "\n"

echo "This is running preprocessfastqgzwithflankrandomnucleotide.sh from $PWD"

printf "\n"

echo "Start with ${LIB}"
date

printf "\n"

echo "print variables"
echo "<LIB>"
echo $1
echo "<ADAPTER>"
echo $2
echo "<QUALSCORE>"
echo $3
echo "<MINLENGTH>"
echo $4
echo "<MAXLENGTH>"
echo $5
echo "<RANDOMNUC5P>"
echo $6
echo "<RANDOMNUC3P>"
echo $7


printf "\n"

echo "note that this fastq file has random nucleotides flanking the insert sequence"

printf "\n"

echo "Processing files to clip, convert fasta, identifiers."
echo "clipping fasta file, discard sequences with no adaptor,"
echo "discard sequences with 'N's, discard sequences shorter than 5 nt..."
echo "converting fastq to fasta, rename identifiers to numbers..."
echo "changing read identifiers to include library information..."

echo "running FastQC for ${LIB}.fastq.gz"
fastqc ${LIB}.fastq.gz
printf "\n"

echo "gunzip fastq files"
gunzip -c ${LIB}.fastq.gz > ${LIB}.fq
printf "\n"

echo "head check file format ${LIB}"
head ${LIB}.fq
printf "\n"

echo "use fastx_clipper to remove adapter sequences"
fastx_clipper -${QUALSCORE} -a ${ADAPTER} -c -v -i ${LIB}.fq > ${LIB}.clipped.fastq.temp

echo "use seqtk trimfq to trim flanking before ${RANDOMNUC5P} nt end ${RANDOMNUC3P} nt"
seqtk trimfq -b ${RANDOMNUC5P} -e ${RANDOMNUC3P} ${LIB}.clipped.fastq.temp > ${LIB}clip.fastq

echo "convert the clipped fastq file to fasta"
fastq_to_fasta -i ${LIB}clip.fastq -v -r | sed "s/^>/>${LIB}_/" | grep . > ${LIB}clip.fasta


printf "\n"

echo "head check ${LIB}clip.fasta"
head ${LIB}clip.fasta


printf "\n"

echo "Do collapsing of fasta file first to unique reads with collapsed counts in identifier"

printf "\n"

echo "collapsing clipped fasta file"
echo "rename identifiers for ${LIB}"
fastx_collapser -v -i ${LIB}clip.fasta | \
sed "s/-/_/g ; s/^>/>${LIB}_/" > ${LIB}clipcolid.fasta

printf "\n"

echo "head check collapsed file"
head ${LIB}clipcolid.fasta

printf "\n"

echo "count numbers of collapsed sequences"
grep -c ${LIB} ${LIB}clipcolid.fasta

printf "\n"

echo "Convert fasta format to tabular format"
echo "use information from header for collapsed sequence read count"
fasta_formatter -i ${LIB}clipcolid.fasta -t | \
awk 'BEGIN {OFS="\t"; FS="_|\t"} {print $1,$2,$3,$4,length($4)}' > ${LIB}clipcolidtemp01.txt

echo "sort by highest count to lowest"
sort -k3,3nr ${LIB}clipcolidtemp01.txt > ${LIB}clipcolid.fasta.tab

printf "\n"

echo "head check ${LIB}clipcolid.fasta.tab"
echo "LIB SERIALNUMBER COUNT SEQUENCE LENGTH"
head -20 ${LIB}clipcolid.fasta.tab
wc -l ${LIB}clipcolid.fasta.tab

printf "\n"

echo "remove temp files"
rm ${LIB}clipcolidtemp01.txt

printf "\n"

echo "Calculate length counts"
awk 'BEGIN {OFS=FS="\t"} {a[$5]+=$3} END {for (i in a) print i,a[i]}' ${LIB}clipcolid.fasta.tab \
> ${LIB}clipcolidtemp02.txt

echo "sort by smallest length to highest"
sort -k1,1n ${LIB}clipcolidtemp02.txt > ${LIB}clipcolid.fasta.lengthcounts.txt

printf "\n"

echo "head check ${LIB}clipcolid.fasta.lengthcounts.txt"
echo "LENGTH COUNT"
head -100 ${LIB}clipcolid.fasta.lengthcounts.txt

printf "\n"

echo "remove temp files"
rm ${LIB}clipcolidtemp02.txt

printf "\n"

echo "Length filter for min ${MINLENGTH}nt and max ${MAXLENGTH}nt"
awk '($5 >= '$MINLENGTH') && ($5 <= '$MAXLENGTH')' ${LIB}clipcolid.fasta.tab > ${LIB}clipcolid${LENGTHFILTERFASTA}temp03.txt

echo "head check ${LIB}clipcolid${LENGTHFILTERFASTA}temp03.txt"
head ${LIB}clipcolid${LENGTHFILTERFASTA}temp03.txt

echo "convert to fasta format"
awk 'BEGIN {OFS=FS="\t"} {print $1"_"$2"_"$3,$4}' ${LIB}clipcolid${LENGTHFILTERFASTA}temp03.txt | \
awk '{print ">"$1"\n"$2}' > ${LIB}clip${LENGTHFILTERFASTA}colid.fasta

echo "head check ${LIB}clip${LENGTHFILTERFASTA}colid.fasta"
head ${LIB}clip${LENGTHFILTERFASTA}colid.fasta

printf "\n"

echo "count number of collapsed length filtered sequences"
grep -c ${LIB} ${LIB}clip${LENGTHFILTERFASTA}colid.fasta

echo "Count total reads in ${LIB}clipcolid.fasta.tab"
awk '{SUM+=$3} END {if (SUM > 0) print SUM; else print "0"}' ${LIB}clipcolid.fasta.tab

echo "Count reads min ${MINLENGTH}nt max ${MAXLENGTH}nt"
awk '{SUM+=$3} END {if (SUM > 0) print SUM; else print "0"}' ${LIB}clipcolid${LENGTHFILTERFASTA}temp03.txt

echo "Count reads shorter than ${MINLENGTH}nt"
awk '($5 < '$MINLENGTH')' ${LIB}clipcolid.fasta.tab | awk '{SUM+=$3} END {if (SUM > 0) print SUM; else print "0"}'

echo "Count reads longer than ${MAXLENGTH}nt"
awk '($5 > '$MAXLENGTH')' ${LIB}clipcolid.fasta.tab | awk '{SUM+=$3} END {if (SUM > 0) print SUM; else print "0"}'

printf "\n"

echo "remove temp files"
rm ${LIB}clipcolid${LENGTHFILTERFASTA}temp03.txt
rm *.temp

printf "\n"

echo "Done with ${LIB}"
date
