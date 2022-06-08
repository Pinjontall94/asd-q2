#!/bin/python
#
# manifest-gen.py
#
# Generates a Qiime 2-compatible manifest.tsv from a given directory
#   populated with fastq.gz files

import argparse
import os, subprocess
import re
import pandas as pd

parser = argparse.ArgumentParser(
    description="Generates a Qiime 2-compatible manifest.tsv"
)

parser.add_argument("-i", "--input", action="store", required=True)
parser.add_argument("-o", "--output", action="store", required=True)

args = parser.parse_args()

# Add trailing backslash on fastq directory (if not specified on command line)
if re.search("/$", args.input):
    fastq_dir = args.input
else:
    fastq_dir = args.input + "/"

manifest = args.output

## Download all fastqs and place in fastq_dir
#accession_list = "SRR_Acc_List.txt"
#
#with open(accession_list, "r") as file:
#    srr_list = [x.rstrip() for x in file]
#    for i in srr_list:
#        subprocess.Popen(["fasterq-dump", "-O", fastq_dir, i])

# Create tuple of the fastqs in the data directory, listing their parent directory
#   (e.g. 'ERR1353528.fastq')
fastqs = sorted(list(os.listdir(fastq_dir)))

# Create tuple of sample id's from fastqs, minus their suffices and file extensions
#   (e.g. 'ERR1353528')

# Extracts substrings from fastqs as re.match objects
substrings = [re.search(".*(?=_R?[12]\\.fastq)", i) for i in fastqs]

# Get a list from the list of re.match objects (so it can be used in the dataframe later)
# sample_strings = list(map(lambda x: x.group(), substrings))
sample_strings = [x.group() for x in substrings if x]

# Remove redundant entries from the reverse reads by taking only unique values in sample_strings
sample_id = list(dict.fromkeys(sample_strings))

# NOTE: Doesn't work, splitext leaves the read direction attached.
# Use re.search instead to extract the sample id substring.
# sample_id = tuple(set(map(lambda x: os.path.splitext(x)[0], fastqs)))

fastqs_abs_path = tuple(map(lambda x: "$PWD/" + fastq_dir + x, fastqs))

forward = tuple(filter(lambda x: re.search(r"_R?1\.fastq", x), fastqs_abs_path))

reverse = tuple(filter(lambda x: re.search(r"_R?2\.fastq", x), fastqs_abs_path))

if len(forward) > 0 and len(reverse) > 0:
    # Create dictionary of headers and columns
    d = {
        "sample-id": sample_id,
        "forward-absolute-filepath": forward,
        "reverse-absolute-filepath": reverse,
    }

    # Import the dictionary into a dataframe
    print("sample_id =", sample_id)
    print("fastqs =", fastqs)
    print("fastqs_abs_path = ", fastqs_abs_path)
    print("forward =", forward)
    print("reverse =", reverse)
    df = pd.DataFrame(d)

    # Export the dataframe to a file labeled manifest.tsv
    manifest_tsv = df.to_csv(manifest, sep="\t", index=False)

elif len(forward) == 0 and len(reverse) == 0:
    d = {"sample-id": sample_id, "absolute-filepath": fastqs_abs_path}

    df = pd.DataFrame(d)

    manifest_tsv = df.to_csv(manifest, sep="\t", index=False)

else:
    print("Error! Mismatched numbers of forward and reverse reads")
