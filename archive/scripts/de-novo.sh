#!/bin/bash

# Create OTUs via de novo clustering
qiime vsearch cluster-features-de-novo \
  --i-table table.qza \
  --i-sequences rep-seqs.qza \
  --p-perc-identity 0.99 \
  --o-clustered-table table-dn-99.qza \
  --o-clustered-sequences rep-seqs-dn-99.qza
