#!/bin/bash

#TODO: Find out if sample-metadata is needed, and if so,
# can it be auto-generated?
#
# Visualize FeatureTable artifacts
qiime feature-table summarize \
  --i-table table-dn-99.qza \
  --o-visualization table.qzv #\
  #--m-sample-metadata-file sample-metadata.tsv
