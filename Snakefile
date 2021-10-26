# Specify NCBI's forward and reverse fastq file naming scheme for snakemake
DIRECTION = ["1", "2"]

# Generate sample list by reading NCBI accession list file line-by-line
with open("SRR_Acc_List.txt") as f:
    SAMPLES = [line.rstrip("\n") for line in f]


#configfile: "config.yaml"

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
            fasterq-dump -o {output} $line
        done < {input}) 2> {log}
        """

#FIXME: fwd and rev arguments mean there can't be any pre-merged data (as
#   opposed to just looking at all *.fastq files in "data/")
rule generateManifest:
    input:
        fwd = expand("data/{sample}_1.fastq", sample=SAMPLES)
        rev = expand("data/{sample}_2.fastq", sample=SAMPLES)
    output: "manifest.tsv"
    shell:
        "python scripts/manifest_gen.py -i {input} -o {output}"
    #run:
    #   "scripts/manifest_gen.py"

rule import:
    input: "manifest.tsv"
    output: "test-paired-end-demux.qza"
    shell:
        "scripts/import-paired.sh"

rule mergePairs:
    input: "test-paired-end-demux.qza"
    output: "test-merged.qza"
    shell:
        "scripts/join_pairs.sh"

rule derep:
    input: "test-merged.qza"
    output:
        "table.qza",
        "rep-seqs.qza"
    shell:
        "scripts/derep.sh"

rule denovo:
    input:
        table="table.qza",
        seqs="rep-seqs.qza"
    output:
        "table-dn-99.qza",
        "rep-seqs-dn-99.qza"
    shell:
        "scripts/de-novo.sh"

rule tabulate_seqs:
    input: "table-dn-99.qza"
    output: "table.qzv"
    shell:
        "scripts/tab_visualize.sh"

rule seq_visualize:
    input: "rep-seqs-dn-99.qza"
    output: "rep-seqs.qzv"
    shell:
        "scripts/rep_seqs_visualize.sh"
