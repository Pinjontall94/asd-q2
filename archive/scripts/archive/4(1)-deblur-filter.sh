#!/bin/bash

# denoise with Deblur, rather than dada2 (starts with quality filtering)

# Note: this stage reflects current Deblur authors'
#	recommended filtering parameters
qiime quality-filter q-score \
 --i-demux demux.qza \
 --o-filtered-sequences demux-filtered.qza \
 --o-filter-stats demux-filter-stats.qza
