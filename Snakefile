import subprocess

subprocess.run(["mkdir", "data"])

# Specify NCBI's forward and reverse fastq file naming scheme for snakemake
DIRECTION = ["1", "2"]

#TODO: Fix this such that SAMPLES is taken from the list of samples with forward and reverse
#       reads. This currently breaks rule 'srrMunch' when ANY sample in the accession list has
#       no "_1.fastq" or "_2.fastq" output files. Better to run srrMunch first (maybe not even
#       as a snakemake rule, given non-deterministic outcomes), and then establish SAMPLES
#       variable from a subset of the files in "data", like maybe all _1.fastq SRRs?
#
#NOTE: Okay now we're getting somewhere. split-files works for importing, but will mess up vsearch
#       join_pairs down the line ("more forward than reverse reads" errors). BUT, if the only SRRs
#       included have both _1 and _2 with the old option (the split-3 default, i.e. no "-S" flag),
#       THEN everything will work. So...the initial assumption is probably correct: run srr munch
#       script first, then get the SAMPLES var from the resulting files.
#
#NOTE: Update this for use with ENA via fastq-dl (relies on metadata tsv rather than accession
#       list, though you *can* just give it the PRJNA number!)
# Generate sample list by reading NCBI accession list file line-by-line
with open("SRR_Acc_List.txt") as f:
    ALL_SRRs = [line.rstrip("\n") for line in f]


#configfile: "config.yaml"

rule all:
    input:
        "table-dn-99/feature-table.tsv"
    threads: 7

# Download fastqs from NCBI, reading from SRR_Acc_List.txt
# TODO: Modify to a single tar file as output
rule srrMunch:
    input: "SRR_Acc_List.txt"
    output: "data/fastqs.tar"
    log: "logs/srrMunch/output.log"
    shell:
        # NOTE: Could just trash the non-biologic reads
        # (i.e. the third fastq per SRR, the one without the _1 or _2 suffix)
        """
        scripts/SrrMunch2.sh {input} data
        """

# Snippets to generate a list of only the SRRs that have pairwise data
ALL_FASTQS = [x for x in os.listdir("data")]
SAMPLES = [x.split("_")[0] for x in ALL_FASTQS if x.endswith("_2.fastq")]

#ruleorder: generate_manifest_paired > generate_manifest_merged
#TODO: Create an input function to determine whether you're using
#   "data/{sample}_{direction}.fastq" or "data/{sample}.fastq"
#
#TODO: Modify manifest_gen.py to take an input list (in this case, {wildcard.sample}).
#       Or alternatively, filter the list of SAMPLES vs ALL_SRRs, and place those files
#       in a new directory to use an the input to the current version of manifest_gen.py

# Filter SRRs by

# Create qiime2 manifest
# TODO: modify to expect the srr.tar output of srrmunch
rule generate_manifest:
    input:
        expand("data/{sample}_{direction}.fastq", sample=SAMPLES, direction=DIRECTION)
    output: "manifest.tsv"
    log: "logs/generate_manifest/output.log"
    shell:
        "python scripts/manifest_gen.py -i data -o {output}"

# Import seqs via manifest
rule import:
    input: "manifest.tsv"
    output: "test-paired-end-demux.qza"
    log: "logs/import/output.log"
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
    output: temp("test-merged.qza")
    log: "logs/merge_pairs/output.log"
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
#
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

#def offset_needed():
#    if config["offset"]["FWD"] or config["offset"]["REV"]:
#        return "offset_demux.qza"
#    else:
#        return "trimmed_demux.qza"

rule derep:
    input: "test-merged.qza"
    output:
        temp("table.qza"),
        temp("rep-seqs.qza")
    log: "logs/derep/output.log"
    shell:
        "scripts/derep.sh"

rule de_novo:
    input:
        table="table.qza",
        seqs="rep-seqs.qza"
    output:
        temp("table-dn-99.qza"),
        temp("rep-seqs-dn-99.qza")
    log: "logs/de_novo/output.log"
    shell:
        "scripts/de-novo.sh"

rule q2_export:
    input:
        "table-dn-99.qza"
    output:
        out_dir=directory("table-dn-99"),
        biom=temp("table-dn-99/feature-table.biom")
    shell:
        """
        scripts/q2_export.sh {input} {output.out_dir}
        """

rule biom_convert:
    input:
        "table-dn-99/feature-table.biom"
    output:
        "table-dn-99/feature-table.tsv"
    log: "logs/biom_convert/output.log"
    shell:
        """
        (biom convert -i {input} -o {output} --to-tsv) > {log} 2>&1
        """
