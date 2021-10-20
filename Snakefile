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
        expand("screened/{sample}.fasta", sample=SAMPLES)

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
