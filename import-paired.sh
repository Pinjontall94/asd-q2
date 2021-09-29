#!/bin/bash

# Import paired-end reads listed in manifest.tsv
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path manifest.tsv \
  --output-path test-paired-end-demux.qza \
  --input-format PairedEndFastqManifestPhred33V2
