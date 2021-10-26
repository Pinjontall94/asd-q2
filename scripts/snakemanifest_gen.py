#!/bin/env python

import re, os, sys, argparse
import pandas as pd
from pandas.core.common import temp_setattr

# Define argument parser
parser = argparse.ArgumentParser(
    description="Generates a Qiime 2-compatible manifest.tsv"
)

# Add arguments to parser object
parser.add_argument("-f", "--forward", action="store", required=True)
parser.add_argument("-r", "--reverse", action="store", required=False)
parser.add_argument("-o", "--output", action="store", required=True)

# Define parsed arguments as args
args = parser.parse_args()

#TODO: Modify this script to accept a single argument
#TODO: Create conditional to differentiate between merged and pairwise
#   sequences, based on a ".*(?=_R?1).fastq" pattern. NOTE: This will
#   ignore the case where you download a fwd seq WITHOUT a matching rev
#   seq. To account for this, run a check to see whether the _2 file
#   exists, and throw an error if not.

# Define input arguments
#fwd = snakemake.input[0]
fwd = args.forward

#if snakemake.input[1] is True:
if args.reverse is None:
    print("No reverse sequence given, assuming sequences were already merged")
else:
    #rev = snakemake.input[1]
    rev = args.reverse

# Define output argument
#manifest = snakemake.output[0]
manifest = args.output

# Extract sample string and fastq path (e.g. "SRR10007909" and
#   "data/SRR10007909", respectively)
fastq = os.path.splitext(fwd)
sample_regex = "(?<=data/).*(?=_R?[12]\\.fastq)"
sample_string = re.search(sample_regex, fastq).group()

temp_entry = f"{sample_string}\t{fwd}"

if rev is None:
    entry = temp_entry
else:
    entry = temp_entry + f"\t{rev}"


with open(manifest, "a+") as file:
    file.write(entry)
