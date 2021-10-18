#!/bin/bash

rep_seqs=$1

# Generate visualization for rep-seqs file
qiime feature-table tabulate-seqs \
  --i-data $rep_seqs \
  --o-visualization rep-seqs.qzv
