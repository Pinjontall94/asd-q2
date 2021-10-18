#!/bin/bash

# Denoise with 'deblur denoise-16S'
#
# Note: Trim length should match length where median quality begins to drop
#	(here: 120, usually around 115-130), UNLESS in a metaanalysis. 
#	In that case, keep lengths consistent between all studies

qiime deblur denoise-16S \
  --i-demultiplexed-seqs demux-filtered.qza \
  --p-trim-length 240 \
  --o-representative-sequences rep-seqs-deblur.qza \
  --o-table table-deblur.qza \
  --p-sample-stats \
  --o-stats deblur-stats.qza
