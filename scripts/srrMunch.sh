#!/bin/bash

ACC_LIST=$1

# Read the SRA Accession List line-by-line, running sra-tools'
# 	fasterq-dump on each entry
while read line; do
	fasterq-dump -O data $line 2>>fastq-dump.err
done < $ACC_LIST

# Create the data folder if it doesn't already exist
if [ ! -d "data" ]; then
	mkdir data
fi

# Move fastqs to data dir
for i in *.fastq; do
	mv $i data
done
