#!/bin/bash

# Explore taxonomic composition based on a taxonomic classifier
#
# Note: In this case we use a pre-trained classifier, but due to security risk
# 	(as well as risk of inaccuracy?), one should train their own classifier
#	on their own data and primers.
#	
#	See: https://docs.qiime2.org/2021.2/tutorials/feature-classifier/
qiime feature-classifier classify-sklearn \
  --i-classifier gg-13-8-99-515-806-nb-classifier.qza \
  --i-reads rep-seqs.qza \
  --o-classification taxonomy.qza

qiime metadata tabulate \
  --m-input-file taxonomy.qza \
  --o-visualization taxonomy.qzv
