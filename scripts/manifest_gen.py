#!/bin/python
#
# manifest-gen.py
#
# Generates a Qiime 2-compatible manifest.tsv from a given directory
#   populated with fastq.gz files

import argparse
import os
import re
import pandas as pd


class Reads:
    def __init__(self, fastq_dir):
        self._fastq_dir = fastq_dir
        self._fwd_pattern = r"_R?1\.fastq"
        self._rev_pattern = r"_R?2\.fastq"
        self.fastqs = sorted([*os.listdir(self._fastq_dir)])
        import pdb; pdb.set_trace()
        self.sample_ids = self.gen_sample_ids(self.fastqs)
        self.fastqs_abs_path = ["$PWD/" + fastq_dir + x for x in self.fastqs]
        self.forward_reads = self._gen_reads(
                self._fwd_pattern,
                self.fastqs_abs_path
                )
        self.reverse_reads = self._gen_reads(
                self._rev_pattern,
                self.fastqs_abs_path
                )
        self.manifest = self._gen_manifest(
                self.sample_ids,
                self.forward_reads,
                self.reverse_reads,
                self.fastqs_abs_path
                )

        def gen_sample_ids(self, fastqs):
            pattern = ".*(?=_R?[12]\\.fastq)"
            substrings = [re.search(pattern, i) for i in self.fastqs]
            sample_strings = [x.group() for x in substrings if x]
            return list(dict.fromkeys(sample_strings))

        def _gen_reads(self, search_pattern, abs_path):
            return [re.search(search_pattern, x) for x in abs_path]

        def _gen_manifest(self, sample_ids, forward, reverse, abs_path):
            try:
                if len(forward) > 0 and len(reverse) > 0:
                    # Create dictionary of headers and columns
                    d = {
                        "sample-id": sample_ids,
                        "forward-absolute-filepath": forward,
                        "reverse-absolute-filepath": reverse,
                    }
                else:
                    assert len(forward) == 0 and len(reverse) == 0
                    d = {
                        "sample-id": sample_ids,
                        "absolute-filepath": abs_path
                    }
                return d

            except AssertionError:
                print("Error! Mismatched numbers of forward and reverse reads")


def parse_args():
    parser = argparse.ArgumentParser(
            description="""
            Generates a Qiime 2-compatible manifest.tsv.
            NOTE: Input requires trailing backslash (e.g. "data/")
            """
    )
    parser.add_argument("-i", "--input", action="store", required=True)
    parser.add_argument("-o", "--output", action="store", required=True)
    return parser.parse_args()


def main():
    # Parse the cli and store args into variables
    args = parse_args()
    fastq_dir_path = args.input
    manifest_path = args.output

    # Create a Reads object from our fastqs
    reads = Reads(fastq_dir_path)

    # Create a dataframe from the reads manifest dictionary
    df = pd.DataFrame(reads.manifest)

    # Export the dataframe to a file labeled manifest.tsv
    df.to_csv(manifest_path, sep="\t", index=False)


if __name__ == "__main__":
    main()
