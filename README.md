## asd-q2 (Real name TBD)

This is a simple, snakemake-based pipeline that takes an NCBI accession list of 
a given SRA#, and performs <i>de novo</i> OTU clustering via qiime2's vsearch
wrapper. End results are given in Qiime2 Artifacts (.qza files), though these 
can be extracted the same as any .zip file, if you so choose

### Preparation, or "Before you run snakemake"

1. Clone this repository and create & activate a new conda environment with the 
provided environment file
``` sh
git clone --depth 1 git@github.com:Pinjontall94/asd-q2.git /your/new/analysis/folder
mamba env create -f environment.yaml 
conda activate snakeqiimer
```
Note: the standard conda tool that comes with Anaconda will work, but as 
[Snakemake itself recommends](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html#installation-via-conda-mamba), I highly encourage you to use mamba (whether on its own, or via the
mambaforge distribution)

2. Download the NCBI Accession List (e.g. "SRR_Acc_list.txt") and move it into 
the asd-q2 folder

3. Run the following in the asd-q2 folder: 
```sh
python scripts/srr_munch.py -i SRR_Acc_List.txt -o data
```

4. Modify the config file ("config.yaml") to fit your analysis
Update the following parameters, in plain text, unless otherwise specified:
* "AUTHOR": a string containing <b>no</b> spaces (e.g. "Franklin_53")
* "primers", "FWD" and "REV": integer values only (e.g. FWD: 5)
* Optional: "offset", FWD or REV for 5' and 3' bp-wise offsets, respectively
* Optional: "THREADS", specify the number of CPU threads to allocate to the 
pipeline (e.g. THREADS: 8)

#### Example config:

``` yaml
AUTHOR: "Franklin_53"

primers:
  FWD: GTGCCAGCMGCCGCGGTAA
  REV: ATTAGASACCCBDGTAGTCC

# Number of nucleotides to trim from reads' 5' (FWD) and 3' (REV) ends
offset:
  FWD: 5
  REV: 4

THREADS: 8
```

### Optional: Visualize the pipeline

Note: Requires graphviz is installed 

``` sh
(snakeqiimer) /your/new/analysis/folder/asd-q2 $ snakemake --dag | dot -Tsvg > dag.svg
```

### Run the pipeline 

#### Locally / On your device:
Run with:

``` sh
(snakeqiimer) /your/new/analysis/folder/asd-q2 $ snakemake -cN  # where N = number of cores
```

Your output files will be stored in a newly made "OTUs" folder

### Pipeline Stages 
1. Download and unzip all fastq.gz's listed in the accession list as SRR numbers,
and place them in a "data" folder 

2. Generate a Qiime2-compatible manifest file for the resulting fastqs
<i>Note: Only tested on PHRED33 fastqs</i>

3. Import Seqs

4. Merge paired-end reads with q2-vsearch's join pairs

5. Dereplicate the SampleData[Sequences] artifact

6. <i>De novo </i> cluster FeatureTable[Frequency] and FeatureData[Sequence] 
artifacts

7. Generate FeatureTable and FeatureData summaries

8. Create a tree for phylogenetic diversity analyses

9. Determine alpha and beta diversity

## TODO

* Add conditional to handle all PHRED values compatible with Qiime2
* Add rule for Qiime2 that uses the [artifact api](https://docs.qiime2.org/2021.8/interfaces/artifact-api/)
* Add examples folder showing sample workflows
* Organize rules into a separate folder? (Maybe not necessary)
* Add instructions for running remotely via slurm and/or GCP ()
