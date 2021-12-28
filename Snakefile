# Specify NCBI's forward and reverse fastq file naming scheme for snakemake
DIRECTION = ["1", "2"]

#TODO: Fix this such that SAMPLES is taken from the list of samples with forward and reverse
#       reads. This currently breaks rule 'srrMunch' when ANY sample in the accession list has
#       no "_1.fastq" or "_2.fastq" output files. Better to run srrMunch first (maybe not even
#       as a snakemake rule, given non-deterministic outcomes), and then establish SAMPLES
#       variable from a subset of the files in "data", like maybe all _1.fastq SRRs?
# Generate sample list by reading NCBI accession list file line-by-line
with open("SRR_Acc_List.txt") as f:
    SAMPLES = [line.rstrip("\n") for line in f]


#configfile: "config.yaml"

rule all:
    input:
        "rep-seqs.qzv"

# Download fastqs from NCBI, reading from SRR_Acc_List.txt
rule srrMunch:
    input: "SRR_Acc_List.txt"
    output:
        expand("data/{sample}_{direction}.fastq", sample=SAMPLES, direction=DIRECTION)
    log: "logs/srrMunch/output.log"
    threads: 6
    shell:
        """
        (while read line; do
            fasterq-dump -O data $line
        done < {input}) > {log} 2>&1
        """

#ruleorder: generate_manifest_paired > generate_manifest_merged
#TODO: Create an input function to determine whether you're using
#   "data/{sample}_{direction}.fastq" or "data/{sample}.fastq"
# Create qiime2 manifest
rule generate_manifest:
    input:
        expand("data/{sample}_{direction}.fastq", sample=SAMPLES, direction=DIRECTION)
    output: "manifest.tsv"
    shell:
        "python scripts/manifest_gen.py -i data -o {output}"

# Import seqs via manifest
rule import:
    input: "manifest.tsv"
    output: "test-paired-end-demux.qza"
    log: "logs/generate_manifest/output.log"
    threads: 6
    shell:
        "scripts/import-paired.sh"
#        """
#        (qiime tools import
#          --type 'SampleData[PairedEndSequencesWithQuality]' \
#          --input-path {input} \
#          --output-path {output} \
#          --input-format PairedEndFastqManifestPhred33V2) > {log} 2>&1
#        """

# Merge pairs using q2-vsearch join-pairs
rule merge_pairs:
    input: "test-paired-end-demux.qza"
    output: "test-merged.qza"
    log: "logs/merge_pairs/output.log"
    threads: 6
    shell:
        "scripts/join_pairs.sh"
#        """
#        (qiime vsearch join-pairs \
#        --i-demultiplexed-seqs {input} \
#        --o-joined-sequences {output}) > {log} 2>&1
#        """

# Trim Primers
#rule primer_trim:
#    input: "test-merged.qza"
#    output: "trimmed_demux.qza"
#    log: "logs/primer_trim/output.log"
#    params:
#        fwd=config["primers"]["FWD"]
#        rev=config["primers"]["REV"]
#    shell:
#        """
#        qiime cutadapt trim-paired \
#        --i-demultiplexed-sequences {input} \
#        --p-adapter-f {params.fwd} \
#        --p-adapter-r {params.rev} \
#        --p-discard-untrimmed \
#        --o-trimmed-sequences {output}
#        """

#rule offset:
#    input: "trimmed_demux.qza"
#    output: "offset_demux.qza"
#    log: "logs/offset_trim/output.log"
#    params:
#        fwd=config["primers"]["FWD"]
#        rev=config["primers"]["REV"]
#    shell:
#        """
#        qiime cutadapt trim-paired \
#        --i-demultiplexed-sequences {input} \
#        --p-adapter-f {params.fwd} \
#        --p-adapter-r {params.rev} \
#        --p-discard-untrimmed \
#        --o-trimmed-sequences {output}
#        """

# TODO: Add input function to output "trimmed_demux.qza" or "offset_demux.qza",
#   depending on whether config["offset"]["FWD"] or config["offset"]["REV"]
#   are non-zero. Let this function also determine parameters in trim and
#   offset rules if possible. Otherwise have 4 separate rules for 5' and 3'
#   cutadapt trim and offset.
rule derep:
    input: "test-merged.qza"
    output:
        "table.qza",
        "rep-seqs.qza"
    log: "logs/derep/output.log"
    threads: 6
    shell:
        "scripts/derep.sh"

rule de_novo:
    input:
        table="table.qza",
        seqs="rep-seqs.qza"
    output:
        "table-dn-99.qza",
        "rep-seqs-dn-99.qza"
    log: "logs/de_novo/output.log"
    threads: 6
    shell:
        "scripts/de-novo.sh"

rule tabulate_seqs:
    input: "table-dn-99.qza"
    output: "table.qzv"
    log: "logs/tabulate_seqs/output.log"
    threads: 6
    shell:
        "scripts/tab_visualize.sh"

rule seq_visualize:
    input: "rep-seqs-dn-99.qza"
    output: "rep-seqs.qzv"
    log: "logs/seq_visualize/output.log"
    threads: 6
    shell:
        "scripts/rep_seqs_visualize.sh"
