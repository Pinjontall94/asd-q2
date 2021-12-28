#!/bin/env python

from qiime2.plugins.vsearch.methods import join_pairs
from qiime2.plugins.vsearch.methods import dereplicate_sequences
from qiime2.plugins.vsearch.methods import cluster_features_de_novo
from qiime2.plugins import feature_table
from qiime2 import Artifact

demux = Artifact.load('test-paired-end-demux.qza')

merged_seqs = join_pairs(demultiplexed_seqs=demux)

demuxJoinedResults = join_pairs(demultiplexed_seqs=demux)
demuxJoinedVisResults = feature_table.visualizers.summarize(demuxJoinedResults.table)
demuxJoinedVisResults.write('test-viz-api.qzv')

#derep_seqs = dereplicate_sequences(sequences=merged_seqs.joined_sequences)
#de_novo_seqs = cluster_features_de_novo(sequences=derep_seqs.dereplicated_sequences, table=derep_seqs.table, perc_identity=0.99)
#
#output_visual = feature_table.visualizers.summarize(de_novo_seqs.table)
#output_visual.write('table-dn-99-api.qzv')
#
#output_feature_table = feature_table.visualizers.tabulate_seqs(de_novo_seqs.representative_sequences)
#output_feature_table.write('rep-seqs-dn-99-api.qzv')
