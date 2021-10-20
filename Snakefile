# Specify NCBI's forward and reverse fastq file naming scheme for snakemake
DIRECTION = ["1", "2"]

# Generate sample list by reading NCBI accession list file line-by-line
with open("SRR_Acc_List.txt") as f:
    SAMPLES = [line.rstrip("\n") for line in f]


configfile: "config.yaml"

rule all:
    input:
        #expand("barcoded/{author}.fasta", author=config["AUTHOR"])
        #"metaan.otus.final.readmap.table"
        #expand("screened/{sample}.fasta", sample=SAMPLES)
        "rep-seqs.qzv"

# Download fastqs from NCBI, reading from SRR_Acc_List.txt
rule srrMunch:
    input: "SRR_Acc_List.txt"
    output:
        expand("data/{sample}_{direction}.fastq", sample=SAMPLES, direction=DIRECTION)
    log: "logs/srrMunch/output.log"
    shell:
        """
        (while read line; do
            fasterq-dump -O data $line
        done < {input}) 2> {log}
        """

rule generateManifest:
    input: "data"
    output: "manifest.tsv"
    shell:
        "scripts/manifest_gen.py -i {input} -o {output}"

rule import:
    input: "manifest.tsv"
    shell:
        "scripts/import-paired.sh"

rule mergePairs:
    input: "test-paired-end-demux.qza"
    shell:
        "scripts/join_pairs.sh"

rule derep:
    input: "test-merged.qza"
    shell:
        "scripts/derep.sh"

rule denovo:
    input:
        table="table.qza"
        seqs="rep-seqs.qza"
    output:
        "table-dn-99.qza"
        "rep-seqs.qza"
    shell:
        "scripts/de-novo.sh"

rule tabulate_seqs:
    input: "rep-seqs-dn-99.qza"
    output: "rep-seqs.qzv"
    shell:
        "scripts/tab_visualize"
