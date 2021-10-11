

# Documentation for SIGNET streamline project

## Getting started 
First you should clone the directory to your path in server and add the path you installed the software to enable directly running the command without specifying a particular path.
```bash
git clone https://github.itap.purdue.edu/jiang548/SIGNET.git
cd SIGNET
export PATH=$PATH:/path/to/signet
```
where */path/to/signet* should be replaced with your path to *SIGNET*.

## Requirement
1. This package runs on UNIX bash shell. Check your shell with "echo $SHELL" to make sure that you are running on UNIX bash shell.
2. This package assumes you are using the **Slurm Workload Manager** for supercomputers in the network analysis stage.  
3. This pacakge assumes you have singularity installed it you would like to use the container image that described in the 

## Container image
1. The Singularity Image Format file **signet.sif** comes with all the required pacakges for *SIGNET*, and an environment that *SIGNET* could run smoothly in. You could first pull the image from Sylabs Cloud Library and rename it as "signet.sif", after which you could append the path of package to singularity so it could execute *SIGNET* smoothly.
```bash
singularity pull signet.sif library://geomeday/default/signet:v0.0.1
export SINGULARITYENV_APPEND_PATH="/path/to/signet"
```
where */path/to/signet* should be replaced with your path to *SIGNET*.

2. You could use the image by attaching a prefix ahead of the original commands you want to execute, which are described in details in sections below.
```bash
singularity exec signet.sif [Command]

e.g. 
singularity exec signet.sif signet -s 
```
Or you could first go into the container by  
```bash 
singularity shell signet.sif
```
and then execute all the commands as usual

**Caution**
```bash
All the result for each step will return to the corresponding folders in the res_root directory in the configuration file config.ini, by default, the /res directory where the package is installed. You should change the res_root directory in the config.ini file if you want to start a new analysis.
```

## Introduction

This streamline project provide users easy linux user interface for constructing whole-genome gene regulatory networks using transciptomic data (frome RNA sequence) and genotypic data. 

Procedures of constructing gene regulatory networks can be split into five main steps:
1. gene expression preprocess
2. genenotype preprocess
3. cis-eQTL analysis
4. network analysis
5. network visualization

To use this streamline tool, user need first to prepare the genetype data in xxx format and gene expression data in xxx format.  Then set the configuration file properly, and run each step command seperately.

**Comments**

We have to think about how to organize the data, especially intermediate results and final results in general.

**1.** Setting (or configuration) files should be put in the current directory;

**2.** Intermediate results may be put in different subdirectory of current directory? Like in `./tmp/` (or inside it to have `./tmpt/` for transcriptomic preprocessing; `./tmpg/` for genotpic preprocessing; `./tmpc/` for cis-eQTL mapping; './tmpn/' for network construction)? 

**3.** Final results may be put in current directory or a subdirectory? Like in `./res/` (or inside it to have `./rest/` for transcriptomic preprocessing; `./resg/` for genotpic preprocessing; `./resc/` for cis-eQTL mapping; './resn/' for network construction)?


## Quit Start

#### 1. Prepare the DataSet

We highly recommand you to prepare the gene expression data and genotype data first, and place them to a specific data folder, to organize each step as it may involve many files:

[Click here](#data-format) for more detail about genotype and genexpression dataset

#### 2. Set configuration 

Here we set the number of chromosome to 22

```bash
tspls config -m nchr 22
```

**Comments**

**1.** I would like to change the whole package name of tspls to `signet` (for **Statistical Inference on Gene (or Global) Networks**, or even simpler with `sign`?), so in the following I will always use `signet` in my comments;

**2.** What about use `-[character]` for each function? So we may replace `config` with `-s` (for settings). For example, we can use
```bash
signet -s --nchr 22
```
to set the #chromosome to 22. Otherwise, if we want to check the #chromosome, we can use
```bash
signet -s --nchr
```
That is, when no value is provided, we will display the value of the specified parameter. We can also use 
```bash
signet -s
```
to display the values of all parameters. We may also provide a way to reset the value of one parameter or all parameters to default values? Like the following?
```bash
signet -s --d
```
or 
```bash
signet -s --nchar --d
```

**3.** We also need a parameter to record the number of cohorts (or groups) so we can later on incoporate the codes of ReDNet and NANOVA into this package:
```bash
signet -s --ngrp 1
```
If `ngrp` is set to be larger than 1, we have to decide how to manage the transcriptomic files and genotype files. For example, if we want to use one file for each group, we need a separate file to map files for different groups?



#### 3. Genotype Preprocess

```bash
tspls geno-preprocess 
```

**Comments**

I would suggest to take
```bash
signet -g
```
for preprocessing genotype data


#### 4. Genexpression Preprocess

```bash
tspls genexp-preprocess
```

**Comments**

I would suggest to take
```bash
signet -t
```
for preprocessing transcriptomic (gene expression) data



#### 5. cis-eQTL Analysis

```bash
tspls cis-eQTL 
```

**Comments**

I would suggest to take
```bash
signet -c
```
for cis-eQTL analysis



#### 6. Network Analysis

```bash
tspls network --nboots 10
```

**Comments**

I would suggest to take
```bash
signet -n --nboots 10
```
for network construction. Is it necessary to separate the two stages of the network construction (like `-n1` and `-n2`)? Of cource, it will be better if we can take it in one step.


#### 7. Network Visualization
Based on the coefficient matrix we got in the network analysis part, we will visualize our constructed gene regulatory networks.

```bash
tspls netvis --freq 0.8 --ncount 2
```

**Comments**

**1.** I would suggest to take
```bash
signet -v --freq 0.8 --ntop 2
```
for network visualization.

**2.** We should unify the way to set up options (or configurations). Previously, we simply use, for example, `nchar`, to list/set up its value. Should we remove the double dashes here (`--`) or include the double dashes also for configurations? Is `ncount 2` for the top 2 networks? If so, I'd rather use `ntop 2`?



## Command Guide

*Please note that you have to run genotype preprocessing before gene expression preprocessing if you are using the GTEx cohort*

### Settings

Settings command is used for look up and modify parameter in the configuration file config.ini. You don't have to modify the parameters at the very beginning, as you will have options to change your input parameters in each step. 

[click here](#config-file) for detailed introduction for configuration file. 

#### Usage
```bash
signet -s [--PARAM] [PARAM VAL] 
```


#### Description
```bash
    --PARAM                                      list the value of parameter PARAM
    --PARAM [PARAM VAL]      modify the value of parameter PARAM to be [PARAM VAL]
```


#### Example
```bash
# list all the parameters
signet -s 
## echo: all the current parameters

# List the paramter
signet -s --nchr
## echo: 22

# Replace s with settings would also work
signet -settings --nchr 

# Modify the paramter
signet -s --nchr 22
## echo: Modification applied to nchr

# Set all the parameters to default 
signet -s --d 
## echo: Set all the parameters to default 
```

#### Error input handling 
```bash
# If you input wrong format such as "-nchr"
signet -s -nchr
echo: The usage and description instruction.

# If you input wrong name such as "-nchro"
echo: Please check the file name
```



### Transcript-prep 
(TCGA)

This command will take the matrix of log2(x+1) transcriptome count data and preprocess it. Each row represent the data for each gene, each column represeing the data for each sample, while the first row is the sample name, and the first column is the gene name.

#### Usage
```bash
signet -t [--g GEXP_FILE] [--p MAP_FILE]
```


#### Description
```bash
--g | --gexp, set gene expression file
--p | --pmap, set the genecode gtf file
```


#### Example
```bash
# List the paramter
signet -t --help
## Display the help page 

# Modify the paramter
signet -t --g ./data/gexp-prep/TCGA-LUAD.htseq_counts.tsv \
          --p ./data/gexp-prep/gencode.v22.gene.gtf
	  
## The preprocessed gene expresion result with correpsonding position file will be stored in /res/rest/
```

(GTEx)

#### Usage
```bash
signet -t [--r READS_FILE] [--tpm TPM_FILE]
```


#### Description
```bash
 --r | --reads                   set the GTEx gene reads file in gct format
 --t | --tpm                     set the gene tpm file
 --g | --gtf                     set the genecode gtf file
```


#### Example
```bash
# List the paramter
signet -t --help
## Display the help page 

# Modify the paramter
signet -t --reads /work/jiang_bio/NetANOVA/real_data/GTEx_lung/gexp/GTEx_gene_reads.gct \
          --tpm /work/jiang_bio/NetANOVA/real_data/GTEx_lung/gexp/GTEx_gene_tpm.gct \
          --gtf ./data/gexp-prep/gencode.v26.GRCh38.genes.gtf
	  
## The preprocessed gene expresion result with correpsonding position file will be stored in /res/rest/
```




### geno-prep

(TCGA)

`geno-prep` command provide the user the interface of preprocessing genotype data. We will do quality control, after which we will use IMPUTE2 for imputation. 

`geno-prep` receive the `map` file and `ped` file as input:
- `data.map`: includes SNP location information with four columns,i.e.,[chromosomeSNP_name genetic_distance locus] for each of p SNPs.
- `data.ped`: includes pedgree information, i.e.,[family_IDindividual_IDmother_IDfather_ID gender phenotype] in the ﬁrst six columns, followed by 2p columns with two columns for each of p SNPs

Output of `geno-prep` will be saved under `/res/resg`:


#### Usage

```bash
signet -g [OPTION VAL] ...
```

#### Description

```
 --p | --ped                   set ped file
 --m | --map                   set map file
 --mind                        set the missing per individual cutoff
 --geno                        set the missing per markder cutoff
 --hwe                         set Hardy-Weinberg equilibrium cutoff
 --nchr                        set the chromosome number
 --r | --ref                   set the reference file for imputation
 --gmap                        set the genomic map file
 --i | --int                   set the interval length for impute2
 --ncores                      set the number of cores
```

#### Example
```bash
# List the paramter
signet -g --help
## Display the help page 

# Modify the paramter
signet -g --ped ./data/geno-prep/test.ped \
          --map ./data/geno-prep/test.map \
	  --ref /work/jiang_bio/NetANOVA/real_data/GTEx_lung/impute_genotype_combined/ref_panel_38/chr \
	  --gmap /work/jiang_bio/NetANOVA/real_data/GTEx_lung/impute_genotype_combined/chr
```

(GTEx)
`geno-prep` command provide the user the interface of preprocessing genotype data. We will first extract the genotype data that has corresponding samples from gene expression data for a particular tissue. 

`geno-prep` receive the 'vcf' file as input:
- `data.vcf`: includes SNP location information in vcf format

Output of `geno-prep` will be saved under `/res/resg`:


#### Usage

```bash
signet -g [OPTION VAL] ...
```

#### Description

```
 --vcf0                        set the VCF file for genotype data before phasing   
 --vcf                         set the VCF file for genotype data, the genotype data is from GTEx after phasing using SHAPEIT
 --read                        set the read file for gene expression read count data in gct format
 --anno                        set the annotation file that contains the sample information
 --tissue                      set the tissue type
```

#### Example
```bash
# Set the cohort
signet -s --cohort GTEx


# Modify the paramter
signet -g --vcf0 /work/jiang_bio/NetANOVA/real_data/GTEx_lung/genotype/Geno_GTEx.vcf \
          --vcf /work/jiang_bio/NetANOVA/real_data/GTEx_lung/genotype_after_phasing/Geno_GTEx.vcf \
          --read /work/jiang_bio/NetANOVA/real_data/GTEx_lung/gexp/GTEx_gene_reads.gct \
	  --anno /work/jiang_bio/NetANOVA/real_data/GTEx_lung/genotype_after_phasing/GTEx_Analysis_v8_Annotations_SampleAttributesDS.txt \
	  --tissue Lung
```



### match
`match` command provide users the interface of matching genotype and gene expression file and the calculation for maf

`match` read the output from `geno-prep` and `gexp-prep`

output of `match` will be saved under `/res/resm`:


#### usage
```bash
signet -m [--c CLINIVAL_FILE]
```


#### Description
```
--c | clinical                   set the clinical file from GDC reporistory for your cohort

```


#### Example
```bash
signet -m --c ./data/clinical.tsv
```


### cis-eqtl

`cis-eqtl` command provide the basic tool for cis-eQTL analysis.  `cis-eqtl` command receive the input file from the previous preprocess step. We will automatically use the result from the previous steps:
- `snps.map` : snp map data
- `snps.maf` : snp maf data from previous step
- `gexp.file` : gene expression file
- `matched.geno` : matched genotype file from previous step
- `gene.pos` : gene position file


The results of `cis-eqtl` are output in to the following files, and they are all saved under  `res/resc/cis-eQTL`:

* `net.Gexp.data`: is the expression data for genes;
* `net.genepos`: include the position for genes in `net.Gexp.data`;
* `[common|low|rare|all].eQTL.data`: includes the genotype data for marginally significant [ common | low | rare | all ] cis-eQTL;
* `[common|low|rare|all].sig.pValue_0.05`: includes the p-value of each pair of gene and its marginally significant [ common | low | rare | all ]  cis-eQTL, where Column 1 is Gene Index, Column is SNP Index in `common.eQTL.data`, and Column 3 is p-Value.
* `[common|low|rare|all].sig.weight_0.05`: includes the weight of collapsed SNPs for marginally significant cis-eQTL. The first column is the gene index, the second column is the SNP index, the third column is the index of collapsed SNP group, and the fourth column is the weight of each SNP in its collapsed group (with value 1 or -1).



**2.** Usage
```
signet -c [OPTION VAL] ...
```


#### Options
```
  --alpha | -a			significant level for cis-eQTL
  --nperms N_PERMS		numer of permutations
  --upstream UP_STREAM		upstream region to flank the genetic region
  --downstram DOWN_STREAM	downstream region to flank the genetic region
  --map MAP_FILE		snps map file path
  --maf MAF_FILE		snps maf file path
  --help | -h			user guide
```

#### Example
```
 signet -c --upstream 100000 --downstream 100000 --nperms 100 --alpha 0.1
```

### network

`network` command provide the tools for constructing a gene regulatory network (GRN) following the two-stage penalized least squares (2SPLS) approach proposed by [D. Zhang, M. Zhang, Ren, and Chen](https://arxiv.org/abs/1511.00370).

`network` receive the input from the previous step:

* `net.Gexp.data`: output from `cis-eqtl`, is the expression data for genes with cis-eQTL:  
* `all.eQTL.data`: output from `cis-eqtl`, includes the genotype data for marginally significant  cis-eQTL:  
* `all.sig.pValue_0.05`: output from `cis-eqtl`,includes the $p$-value of each pair of gene and its marginally significant (p-Value < 0.05) cis-eQTL, where Column 1 is Gene Index (in `net.Gexp.data`), Column is SNP Index (in `all.Geno.data`), and Column 3 is p-Value.
 
The final output files of `network` will be saved under `/res/network/resn`:
* `adjacency_matrix`: the adjancency matrix for the estimated regulatory effects;
* `coefficient_matrix`: the coefficient matrix for the estimated regulatory effects;

#### usage
```
signet -n [OPTION VAL] ...
```


#### description

```
  --loc CIS.LOC                 location of the result after the cis-eQTL analysis
  --cor MAX_COR 		maximum corr. coeff. b/w cis-eQTL of same gene
  --ncores N_CORE		number of cores in each node
  --memory MEMEORY	        memory in each node in GB
  --queue QUEUE                 queue name
  --walltime WALLTIME		maximum walltime of the server in seconds
  --nboots NBOOTS               number of bootstraps datasets
```

#### example
```
signet -n --nboots 10 --queue standby --walltime 4:00:00 --memory 256
```



### netvis

`netvis` provide tools to visualize our constructed gene regulatory networks. Users can choose the bootstrap frequency threshold  and number of subnetworks to visualize the network.

`netvis` will automatically read the output from `network` step:
* `adjacency_matrix`: the adjancency matrix for the estimated regulatory effects;
* `coefficient_matrix`: the coefficient matrix for the estimated regulatory effects;

In addition, we also need user to provide node information file to identify transcription factor for visualization.


#### usage
```
netvis [OPTION VAL] ...
```

**Comments**
Possible changes:
```
signet -v [OPTION VAL] ...
```


#### description

```
  --freq FREQENCY	 	bootstrap frequecy for the visualization
  --ncount NET_COUNT		number of sub-networks
  --ninfo NODE_INFO_FILE        node information file
  --h | --help                  usage
```


## Appendix

### Data Format
* Gene Expression Data (`GeneExpression/jpt.ge` \& `GeneExpression/jpt.gpos`):
    + `jpt.ge` includes the sample IDs in the first column, and the rest is an $n\times p$ matrix with $p$ genes for each of $n$ individuals;
    + `jpt.gpos` is a gene annotation file, including four columns with the first one for *Gene Symbol*, the second one for *Chromosome No.*, the third for *Start Position*, and the last for *End Position*.

* Genotype Data (`Genotype/jpt.map` \& `Genotype/jpt.ped`):
    + `jpt.ped` includes pedgree information, i.e., [family_ID individual_ID mother_ID father_ID gender phenotype] in the first six columns, followed by $2p$ columns with two columns for each of $p$ SNPs.
    + `jpt.map` includes SNP location information with four columns, i.e., [chromosome SNP_name genetic_distance locus] for each of $p$ SNPs.


### config File

config.ini file  is under the main folder and saving the costomized parameters for the four stages of tspls process. Settings in config.ini are orgnized by different sections. 

Users can change the tspls process by modifying the paramter settings in the configuration file.


```bash
# basic settings
[basic]
nchr = 22
ncore_local = 20

[geno]
ped.file = ./data/geno-prep/test.ped
map.file = ./data/geno-prep/test.map
gmap = /work/jiang_bio/NetANOVA/real_data/GTEx_lung/impute_genotype_combined/chr
ref = /work/jiang_bio/NetANOVA/real_data/GTEx_lung/impute_genotype_combined/ref_panel_38/chr

[gexp]
gexp.file = ./data/gexp-prep/TCGA-LUAD.htseq_counts.tsv
pmap.file = ./data/gexp-prep/gencode.v22.gene.gtf

[match]
cli.file = ./data/clinical.tsv

[plink]
mind = 0.1
geno = 0.1
hwe = 0.0001

[ciseqtl]
#snps.map = ./data/cis-eQTL/snps.map
#snps.maf = ./data/cis-eQTL/snps.maf
#gexp.file = ./data/cis-eQTL/gexp_prostate
#matched.geno = ./data/cis-eQTL/matched.Geno
#gene.pos = ./data/cis-eQTL/prostate_gene_pos
snps.map = ./res/resm/new.Geno.map
snps.maf = ./res/resm/new.Geno.maf
matched.gexp = ./res/resm/gexp_rmpc.data
matched.geno = ./res/resm/geno.data
gene.pos = ./res/rest/gene_pos
alpha.cis = 0.05
nperms = 100
upstream = 100000
downstream = 100000

[network]
cis.loc = ./data/resn
ncis = 3
cor = 0.9
nboots = 10
ncores = 128
queue = standby
memory = 256
walltime = 4:00:00

[netvis]
freq = 0.8
ntop = 2
```

### File Structure


```bash
# script folder save all the code
- script/
	- cis-eQTL/
	- network/ 
	- netvis/
	- cis_portal.sh # entrance for cis-eqtl analysis
	- network_portal.sh # entrance for network analysis 
	- netvis_portal.sh #entrance for network visualization
```

## Issues
1. signet.sif EIG-master directory
