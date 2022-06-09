"""An updated python3 script to merge barcode and read fastas."""

from argparse import ArgumentParser
import fastq as fq

#  Credit: walterst, https://gist.github.com/walterst/7326543
#
# from sys import argv
# from itertools import izip
#
# from cogent.parse.fastq import MinimalFastqParser
#
# """ Usage
# python merge_bcs_reads.py X Y Z
# X: barcodes fastq file
# Y: reads fastq file
# Z: merged output file
# Will write the barcodes at the beginning of the output file
# """
#
#
# bcs = open(argv[1], "U")
# reads = open(argv[2], "U")
# combined_out = open(argv[3], "w")
#
# header_index = 0
# sequence_index = 1
# quality_index = 2
#
# for bc_data,read_data in izip(MinimalFastqParser(bcs,strict=False),
#                                MinimalFastqParser(reads,strict=False)):
#
#    curr_label = bc_data[header_index].strip()
#    bc_read = bc_data[sequence_index]
#    bc_qual = bc_data[quality_index]
#    seq_read = read_data[sequence_index]
#    seq_qual = read_data[quality_index]
#
#    combined_out.write("@%s\n" % curr_label)
#    combined_out.write("%s\n" % (bc_read + seq_read))
#    combined_out.write("+\n")
#    combined_out.write("%s\n" % (bc_qual + seq_qual))


#  For a given set of barcode.fasta and read.fasta, write linewise:
#    "@" + barcode_header_label + "\n"
#    barcode_read + sequence_read + "\n"
#    "+" + "\n"
#    barcode_quality + sequence_quality

parser = ArgumentParser(
    description="Generates a Qiime 2-compatible manifest.tsv"
)

parser.add_argument("-b", "--barcodes", action="store", required=True)
parser.add_argument("-s", "--sequence", action="store", required=True)
parser.add_argument("-o", "--output", action="store", required=True)

args = parser.parse_args()

barcodes = fq.read(args.barcodes)
sequence = fq.read(args.sequence)
combined = args.output

print(barcodes.info, sequence.info)
