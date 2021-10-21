#!/bin/bash

# Dereplicate sequences with vsearch for OTU clustering
qiime vsearch dereplicate-sequences \
  --i-sequences test-merged.qza \
  --o-dereplicated-table table.qza \
  --o-dereplicated-sequences rep-seqs.qza
