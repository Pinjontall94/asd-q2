#!/bin/bash

# Generate visualization for rep-seqs file
qiime feature-table tabulate-seqs \
  --i-data rep-seqs-dn-99.qza \
  --o-visualization rep-seqs.qzv
