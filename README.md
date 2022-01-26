

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
3. This pacakge assumes you have singularity installed if you would like to use the container image that described below. If you are using the linux system, you could install singularity following https://sylabs.io/guides/3.8/user-guide/quick_start.html#quick-installation-steps. If you are a windows/mac user, you could find the installation guide in https://sylabs.io/guides/3.8/admin-guide/installation.html. You could also choose to skip the container, and instead install all the packages required mannually. 


## Container image
1. The Singularity Image Format file **signet.sif** comes with all the required pacakges for *SIGNET*, and an environment that *SIGNET* could run smoothly in. You could first pull the image from Sylabs Cloud Library and rename it as "signet.sif", after which you could append the path of package to singularity so it could execute *SIGNET* smoothly.
```bash
singularity pull signet.sif library://geomeday/default/signet:0.0.4.sif
export SINGULARITYENV_APPEND_PATH="/path/to/signet"
```
where */path/to/signet* should be replaced with your path to *SIGNET*.

2. You could use the image by attaching a prefix ahead of the original commands you want to execute, which are described in details in sections below.
```bash
singularity exec signet.sif [Command]

e.g. 
singularity exec signet.sif signet -s 
```
Or you could first shell into the container by  
```bash 
singularity shell signet.sif
```
and then execute all the commands as usual.

**Caution**  
All the intermediate result for each step will by default return to the corresponding folders in the tmporary directory starting with 'tmp' and all the final result will return to the result folders starting with 'res'.  You could also change the path of result files in the configuration file named config.ini, or use signet -s described below. Please be careful if you are using the relative path instead of the absolute path. The config.ini will record the path relative to the folder the **signet is installed**, in order to reach file mangement consistency. It's highly recommended to run command where signet is installed.  In each of the process, you could specify the result path, and you will be asked to whether purge the tmporary files, if you already have those. It's also suggested you keep a copy of the temporary files for each analysis, in case you need them in later steps.


## Introduction

This streamline project provide users easy linux user interface for constructing whole-genome gene regulatory networks using transciptomic data (from RNA sequence) and genotypic data. 

Procedures of constructing gene regulatory networks can be split into six main steps:
1. genotype preprocess
2. gene expression preprocess
3. adjust for covariates 
4. cis-eQTL analysis
5. network analysis
6. network visualization

To use this streamline tool, user need first to prepare the genetype data in vcf format. Then set the configuration file properly, and run each step command seperately.

## Quit Start

#### 1. Prepare the DataSet

We highly recommand you to prepare the gene expression data and genotype data first, and place them to a specific data folder, to organize each step as it may involve many files:

[Click here](#data-format) for more detail about genotype and genexpression dataset

#### 2. Set configuration 

Here we set the number of chromosomes to 22

**1.** 
```bash
signet -s --nchr 22
```

We can use the command to check below to check chromosome number
```bash
signet -s --nchr
```
That is, when no value is provided, we will display the value of the specified parameter. We can also use 
```bash
signet -s
```
to display the values of all parameters. We may also provide a way to reset the value of one parameter or all parameters to default values.
```bash
signet -s --d
```
or 
```bash
signet -s --nchar --d
```

#### 3. Genotype Preprocess

For preprocessing genotype data
```bash
signet -g
```



#### 4. Genexpression Preprocess


For preprocessing transcriptomic (gene expression) data
```bash
signet -t
```


#### 5. cis-eQTL Analysis

For cis-eQTL analysis

I would suggest to take
```bash
signet -c
```



#### 6. Network Analysis

For network construction.
```bash
signet -n 
```


#### 7. Network Visualization
For network visualization.
```bash
signet -v 
```

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
 --g | --gexp                   gene expression file
 --p | --pmap                   genecode gtf file
 --r | --rest                   result prefix
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


#### Usage

```bash
signet -g [OPTION VAL] ...
```

#### Description

```                           
  --p | --ped                   ped file
  --m | --map                   map file
  --mind                        missing rate per individual cutoff
  --geno                        missing rate per markder cutoff
  --hwe                         Hardy-Weinberg equilibrium cutoff
  --nchr                        chromosome number
  --r | --ref                   reference file for imputation
  --gmap                        genomic map file
  --i | --int                   interval length for impute2
  --ncores                      number of cores
  --resg                        result prefix
```

#### Example
```bash
# List the paramter
signet -g --help
## Display the help page 

# Modify the paramter
signet -g --ped ./data/geno-prep/test.ped \
          --map ./data/geno-prep/test.map \
	      --ref /neyman/work/jiang548/NetANOVA/real_data/GTEx_lung/impute_genotype_combined/ref_panel_38/chr \
	      --gmap /neyman/work/jiang548/NetANOVA/real_data/GTEx_lung/impute_genotype_combined/chr
```

#### Result
Output of `geno-prep` will be saved under `/res/resg`:
```bash
Geno: Genotype data with each row denoting the SNP data for each individual.
Genotype.sampleID: Sample ID for each individual, which uses the reading barcode.
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
signet -g --vcf0 /neyman/work/jiang548/NetANOVA/real_data/GTEx_lung/genotype/Geno_GTEx.vcf \
          --vcf /neyman/work/jiang548/NetANOVA/real_data/GTEx_lung/genotype_after_phasing/Geno_GTEx.vcf \
          --read /neyman/work/jiang548/NetANOVA/real_data/GTEx_lung/gexp/GTEx_gene_reads.gct \
	  --anno /neyman/work/jiang548/NetANOVA/real_data/GTEx_lung/genotype_after_phasing/GTEx_Analysis_v8_Annotations_SampleAttributesDS.txt \
	  --tissue Lung
```






### Adj
`adj` command provide users the interface of matching genotype and gene expression file and the calculation for maf

`adj` read the output from `geno-prep` and `gexp-prep`

output of `adj` will be saved under `/res/resa`:


#### usage
```bash
signet -a [--c CLINIVAL_FILE]
```


#### Description
```
 --c | clinical                   clinical file for your cohort
 --resa                           result prefix
```


#### Example
```bash
signet -a --c ./data/clinical.tsv
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
  --gexp                        gene expression file after matching with genotype data
  --gexp.withpc                 gene expression file without adjusting for pc, after matching with genotype data
  --geno                        genotype file after matching with gene expression data
  --map MAP_FILE                snps map file path
  --maf MAF_FILE                snps maf file path
  --gene_pos                    gene position file
  --alpha | -a			        significance level for cis-eQTL
  --nperms N_PERMS	         	numer of permutations
  --upstream UP_STREAM		    upstream region to flank the genetic region
  --downstram DOWN_STREAM	    downstream region to flank the genetic region
  --resc                        result prefix
```

#### Example
```
 signet -c --upstream 100000 --downstream 100000 --nperms 100 --alpha 0.1
```

### network

`network` command provide the tools for constructing a gene regulatory network (GRN) following the two-stage penalized least squares (2SPLS) approach proposed by [D. Zhang, M. Zhang, Ren, and Chen](https://arxiv.org/abs/1511.00370).

`network` receive the input from the previous step:

**All of the following files has to be put under the directory /data/network

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
  --net.gexp.data               gene expression data for network analysis
  --net.geno.data               marker data for network analysis
  --sig.pair        	        significant index pairs for gene expression and markers
  --net.genename                gene name files for gene expression data
  --net.genepos                 gene position files for gene expression data
  --ncis                        maximum number of biomarkers for each gene
  --cor                         maximum correlation between biomarkers
  --nboots NBOOTS               number of bootstraps datasets
  --memory MEMEORY	            memory in each node in GB
  --queue QUEUE                 queue name
  --ncores                      number of scores for each node
  --walltime WALLTIME	     	maximum walltime of the server in seconds
  --resn                        result prefix
  --sif                         singularity container
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
  --Afreq EDGE_FREQ            matrix of edge frequencies from bootstrap results
  --freq FREQENCY              bootstrap frequecy for the visualization
  --ntop N_TOP                 number of top sub-networks to visualize
  --coef COEF                  coefficient of estimation for the original dataset
  --vis.genepos                gene position file
  --resv                       result prefix
```

#### example
```
signet -v 
```


## Appendix

### Data Format
* Gene Expression Data (`GeneExpression/jpt.ge` \& `GeneExpression/jpt.gpos`):
    + `jpt.ge` includes the sample IDs in the first column, and the rest is an $n\times p$ matrix with $p$ genes for each of $n$ individuals;
    + `jpt.gpos` is a gene annotation file, including four columns with the first one for *Gene Symbol*, the second one for *Chromosome No.*, the third for *Start Position*, and the last for *End Position*.

* Genotype Data (`Genotype/jpt.map` \& `Genotype/jpt.ped`):
    + `jpt.ped` includes pedgree information, i.e., [family_ID individual_ID mother_ID father_ID gender phenotype] in the first six columns, followed by $2p$ columns with two columns for each of $p$ SNPs.
    + `jpt.map` includes SNP location information with four columns, i.e., [chromosome SNP_name genetic_distance locus] for each of $p$ SNPs.


### Configuration File

config.ini file is under the main folder and saving the costomized parameters for all of the stages of signet process. Settings in config.ini are orgnized by different sections. 

Users can change the tspls process by modifying the paramter settings in the configuration file.


```bash
# basic settings
# basic settings
[basic]
nchr = 22
ncore_local = 20
cohort = TCGA

[geno]
(TCGA)
ped.file = ./data/geno-prep/test.ped
map.file = ./data/geno-prep/test.map
gmap = /work/jiang_bio/NetANOVA/real_data/GTEx_lung/impute_genotype_combined/chr
ref = /work/jiang_bio/NetANOVA/real_data/GTEx_lung/impute_genotype_combined/ref_panel_38/chr
int = 5000000
resg.tcga = res/resg/signet

(GTEx)
vcf0 = /work/jiang_bio/NetANOVA/real_data/GTEx_lung/genotype/Geno_GTEx.vcf
vcf.file = /work/jiang_bio/NetANOVA/real_data/GTEx_lung/genotype_after_phasing/Geno_GTEx.vcf
read.file = /work/jiang_bio/NetANOVA/real_data/GTEx_lung/gexp/GTEx_gene_reads.gct
anno = /work/jiang_bio/NetANOVA/real_data/GTEx_lung/genotype_after_phasing/GTEx_Analysis_v8_Annotations_SampleAttributesDS.txt
tissue = Lung
resg.gtex = res/resg/signet

[gexp]
(TCGA)
gexp.file = ./data/gexp-prep/TCGA-LUAD.htseq_counts.tsv
pmap.file = ./data/gexp-prep/gencode.v22.gene.gtf
rest.tcga = res/rest/signet

(GTEx)
reads.file = sdfs
tpm.file = sfd
gtf.file = sdfsd
rest.gtex = res/rest/signet

[adj]
cli.file = ./data/clinical.tsv
resa = res/resa/signet

[plink]
mind = 0.1
geno = 0.1
hwe = 0.0001

[ciseqtl]
snps.map = ./res/resa/signet_new.Geno.map
snps.maf = ./res/resa/signet_new.Geno.maf
matched.gexp = ./res/resa/signet_gexp_rmpc.data
matched.gexp.withpc = ./res/resa/signet_gexp.data
matched.geno = ./res/resa/signet_geno.data
gene.pos = ./res/rest/signet_gene_pos
alpha.cis = 0.05
nperms = 100
upstream = 100000
downstream = 100000
resc = res/resc/signet

[network]
net.gexp.data = ./data/network/signet_net.gexp.data
net.geno.data  = ./data/network/signet_all.eQTL.data
sig.pair = ./data/network/all.sig.pValue_0.05
net.genename = ./data/network/signet_net.genename
net.genepos = ./data/network/signet_net.genepos
ncis = 3
cor = 0.9
nboots = 10
ncores = 128
queue = standby
memory = 256
walltime = 4:00:00
resn = res/resn/signet
sif = signet0.0.4.sif

[netvis]
Afreq = res/resn/signet_Afreq
freq = 1
ntop = 3
coef = tmp/tmpn/stage2/output/CoeffMat0
vis.genepos = tmp/tmpn/net.genepos
resv = res/resv/signet
```

### File Structure

```bash
# script folder save all the code
- script/
    - gexp_prep
    - geno_prep
    - adj
	- cis-eQTL/
	- network/ 
	- netvis/
```


