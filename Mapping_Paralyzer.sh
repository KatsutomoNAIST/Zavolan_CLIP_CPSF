#!/bin/sh

#  Mapping_Paralyzer.sh
#  
#
#  Created by okamurak on 2020/11/27.
#
LIB=$1
echo "Mapping ${LIB}clip.fastq to hg38 with 2 mismatches allowed"

## map reads to the human genome to hg38
bowtie /Volumes/NAIST_data007/NarryKim_Aqseq_Fastq/hg38 -v 2 -m 10 --best --strata ${LIB}clip.fastq ${LIB}.bowtie

## 2bit file downloaded from https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/

PARalyzer 4G /Users/okamurak/Documents/GitHub/Zavolan_CLIP_CPSF/CPSF6.ini


