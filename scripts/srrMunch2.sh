#!/bin/bash

# fasterq-dump and fastq file management for snakemake

ACC_LIST=$1
DATA_DIR=$2

# Read the SRA Accession List line-by-line, running sra-tools'
#   fasterq-dump on each entry
while read line; do
    fastq-dl --cpus $(nproc) $line ENA
done < $ACC_LIST

# Create the $DATA_DIR folder if it doesn't already exist
if [ ! -d "$DATA_DIR" ]; then
    mkdir $DATA_DIR
fi

# Move fastqs to $DATA_DIR
for i in *_1.fastq.gz; do
    mv $i $DATA_DIR
done

for i in *_2.fastq.gz; do
    mv $i $DATA_DIR
done

# Discard non-biologic reads
rm *.fastq.gz

for i in $DATA_DIR/*.gz; do
    gunzip $i
done

tar -cf data/fastqs.tar data
