#!/bin/sh

#  Script.sh
#  
#
#  Created by okamurak on 2020/11/29.
#
##Prepare bam track for IGV upload (SRR488727)
bowtie /Volumes/NAIST_data007/NarryKim_Aqseq_Fastq/hg38 -v 2 -m 10 --best --strata -S SRR488727clip.fastq  SRR488727.hg38.sam
samtools view -S -b SRR488727.hg38.sam > SRR488727.hg38.bam
samtools sort SRR488727.hg38.bam -o SRR488727.hg38.sorted.bam
samtools index SRR488727.hg38.sorted.bam

##Prepare bam track for IGV upload (SRR488729)
bowtie /Volumes/NAIST_data007/NarryKim_Aqseq_Fastq/hg38 -v 2 -m 10 --best --strata -S SRR488729clip.fastq  SRR488729.hg38.sam
samtools view -S -b SRR488729.hg38.sam > SRR488729.hg38.bam
samtools sort SRR488729.hg38.bam -o SRR488729.hg38.sorted.bam
samtools index SRR488729.hg38.sorted.bam
