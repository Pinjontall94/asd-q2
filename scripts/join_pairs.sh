#!/bin/bash

qiime vsearch join-pairs \
	--i-demultiplexed-seqs test-paired-end-demux.qza \
	--o-joined-sequences test-merged.qza
