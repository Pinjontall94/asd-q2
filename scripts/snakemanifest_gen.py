#!/bin/env python

import re, os
import pandas as pd

# Define list of fastqs' full paths and associated sample IDs
# (e.g. "data/SRR10007909_1.fastq" and "SRR10007909", respectively)
#fastqs_full_path = [os.path.splitext(x) for x in snakemake.input]
fastqs_full_path = snakemake.input
sample_regex = "(?<=data/).*(?=_R?[12]\\.fastq)"
sample_id = [x.group() for x in re.search(sample_regex, snakemake.input) if x]

fwd_regex = "(?<=data/).*_R?[1]\\.fastq"
rev_regex = "(?<=data/).*_R?[2]\\.fastq"
forward = [x.group() for x in re.search(fwd_regex, fastqs_full_path) if x]
reverse = [x.group() for x in re.search(rev_regex, fastqs_full_path) if x]

if len(forward) > 0 and len(reverse) > 0:
    # Create dictionary of headers and columns
    d = {
        "sample-id": sample_id,
        "forward-absolute-filepath": forward,
        "reverse-absolute-filepath": reverse,
    }

    # Import the dictionary into a dataframe
    print("sample_id =", sample_id)
    print("fastqs = ", fastqs_full_path)
    print("forward =", forward)
    print("reverse =", reverse)
    df = pd.DataFrame(d)

    # Export the dataframe to a file labeled manifest.tsv
    manifest_tsv = df.to_csv(manifest, sep="\t", index=False)

elif len(forward) == 0 and len(reverse) == 0:
    d = {"sample-id": sample_id, "absolute-filepath": fastqs_full_path}

    df = pd.DataFrame(d)

    manifest_tsv = df.to_csv(manifest, sep="\t", index=False)

else:
    print("Error! Mismatched numbers of forward and reverse reads")
