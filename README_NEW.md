

# Documentation for TSPLS streamline project


## Getting started 
First you should clone the directory to your path in server and add the path you installed the software to enable directly running the command without specifying a particular path
```bash
git clone https://github.itap.purdue.edu/jiang548/2SPLS.git

export PATH=$PATH:/path/to/tslps
```
**Caution**
```bash
All the result for each step will return to the corresponding folders in the res_root directory in the configuration file config.ini, by default, the /res directory where the package is installed. You should change the res_root directory in the config.ini file if you want to start a new analysis.
```

## Introduction

This streamline project provide users easy linux user interface for constructing whole-genome gene regulatory networks using transciptomic data (frome RNA sequence) and genotypic data. 

Procedures of constructing gene regulatory networks can be split into five main steps:
1. genenotype preprocess
2. gene expression preprocess
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
# List the paramter
signet -s --nchr
## echo: 22

# Replace s with settings would also work
signet -settings --nchr 

# Modify the paramter
signet -s --nchr 22
## echo: Modification applied to nchr
```

#### Error input handling 
```bash
# If you input wrong format such as "-nchr" or " "
signet -s -nchr
signet -s 
echo: The usage and description instruction.

# If you input wrong name such as "-nchro"
echo: Please check the file name
```



### Transcript 

This command will take the matrix of transcriptome count data and preprocess it. Each row represent the data for each gene, each column represeing the data for each sample, while the first row is the sample name, and the first column is the gene name.

#### Usage
```bash
signet -t [--g GEXP_FILE] [--p MAP_FILE]
```


#### Description
```bash
    --g | --gexp, set gene expression file
    --p | --pmap, set the USSC xena probemap file
```


#### Example
```bash
# List the paramter
signet -t --help
## Display the help page 

# Modify the paramter
signet -t --g ./data/gexp-prep/test.gexp --p ./data/gexp-prep/hugo_gencode_good_hg19_V24lift37_probemap
## The preprocessed gene expresion result with correpsonding position file will be stored in /res/gexp-prep
```


### geno-prep

`geno-prep` command provide the user the interface of preprocessing genotype data

`geno-prep` receive the `map` file and `ped` file as input:
- `data.map`: includes SNP location information with four columns,i.e.,[chromosomeSNP_name genetic_distance locus] for each of p SNPs.
- `data.ped`: includes pedgree information, i.e.,[family_IDindividual_IDmother_IDfather_ID gender phenotype] in the ﬁrst six columns, followed by 2p columns with two columns for each of p SNPs

Output of `geno-prep` will be saved under `/data/geno-prep`:

• `Geno`: each row is a sample and each column is a SNP, with the ﬁrst column for Sample ID; 
• `clean_Genotype.map`: the corresponding map ﬁle; 
• `clean_Genotype_chr$i.map`: map ﬁle for ith chromosome, with i =1,2,··· 

#### Usage

```bash
geno-prep [--map MAP_FILE] [--ped PED_FILE][--imputation]
```

**Comments**

Following my previous suggestion,
```bash
signet -g [--map MAP_FILE] [--ped PED_FILE][--imput]
```
Does ``--imput`` imply to impute the missing genotype values? Are there any other options on how to impute the missing genotypes?


#### Options

```
-p | --ped, set ped file
-m | --map, set map file
-i | --imputaion, use 1000genome for imputation
```

**Comments**

**1.** Do you mean to use `-p` instead of `--p`? Anyway, we should unify the way to set up options/configurations.

**2.** Should the intermediate results be saved in `./tmp/tmpg/`? I would replace `./data/` with either `./tmp/[tmpg/]` or `./res/[tmpg/]`, depending on whether you want to save the results for users. 




### match
`match` command provide users the interface of matching genotype and gene expression file and the calculation for maf

`match` read the output from `geno-prep` and `gexp-prep`

output of `match` will be saved under `/data/match`:
- `new.Geno`: genotype ﬁle; 
- `new.Geno.idx`: index of SNPs selected to new.Geno;  
- `new.Geno.map`: map ﬁle;
- `new.Geno.maf`: each element is the minor allele frequency (MAF) for each SNP.

**Comments**

**1.** `match` should be replaced by `signet -match` (or simply `signet -m`)?

**2.** The output should be saved under `./res/` or `./tmp/`?

**2.** Should we unify all files with `new.Geno*` by `matched.Geno*` (any better names)?


#### usage
```bash
match [--ma 5]
```





#### option

```bash
--ma | -m, minor alleles threshold 
```

**Comments**

Have to separate it from `-match`: should we use `--amin` for *minimum number of alleles*?


### cis-eqtl

`cis-eqtl` command provide the basic tool for cis-eQTL analysis.  `cis-eqtl` command receive the input file from the previous preprocess step. We will automatically copy the following output from the precious preprocess step to `data/cis-eQTL`:
- `snps.map` : snp map data
- `snps.maf` : snp maf data from previous step
- `gexp.file` : gene expression file
- `matched.geno` : matched genotype file from previous step
- `gene.pos` : gene position file


The results of `cis-eqtl` are output in to the following files, and they are all saved under  `/data/cis-eQTL`:

* `net.Gexp.data`: is the expression data for genes with cis-eQTL;
* `net.genepos`: include the position for genes in `net.Gexp.data`;
* `[common|low|rare|all].eQTL.data`: includes the genotype data for marginally significant [ common | low | rare | all ] cis-eQTL;
* `[common|low|rare|all].sig.pValue_0.05`: includes the p-value of each pair of gene and its marginally significant [ common | low | rare | all ]  cis-eQTL, where Column 1 is Gene Index, Column is SNP Index in `common.eQTL.data`, and Column 3 is p-Value.
* `[common|low|rare|all].sig.weight_0.05`: includes the weight of collapsed SNPs for marginally significant cis-eQTL. The first column is the gene index, the second column is the SNP index, the third column is the index of collapsed SNP group, and the fourth column is the weight of each SNP in its collapsed group (with value 1 or -1).

**Comments**

**1.** Why shouldn't we directly access the output from the previous steps instead as we should try to minimize the usage of space?

**2.** Use `signet -c` instead of `cis-eqtl`?

**3.** The outputs should be saved into `./tmp/[tmpc/]` or `./res/[resc/]`?

**4.** While we may allow users to specify the output file names, we should have default file names at the same time so users may not have to specify.


#### Usage
```bash
  cis-eqtl --alpha 0.5 --ncis 9 --maxcor 1 --nperms 5 --upstream 1000 --downstream 1000 --map ./data/cis-eQTL/snps.map --maf ./data/cis-eQTL/snps.maf
  ```

**Comments**

**1.** Would suggest:
```bash
signet -c --alpha 0.05 --ncis 5 --maxcor 0.8 --nperms 100 --up 1000 --down 1000
```

**2.** Use
```
  --rmax MAX_COR		maximum corr. coeff. b/w cis-eQTL of same gene
  --up UP_STREAM		upstream region to flank the genetic region 
  --down DOWN_STREAM	downstream region to flank the genetic region
  --map MAP_FILE		snps map file path  [file or path?]
  --maf MAF_FILE		snps maf file path  [file or path?]
  --gexp GEXP_FILE		gene expression file path [file or path?]
  --geno GENO_FILE		genotype file path [file or path?]
```


#### Options
```
  --alpha | -a			significant level for cis-eQTL
  --ncis NCIS			maximum number of cis-eQTL for each gene
  --maxcor MAX_COR		maximum corr. coeff. b/w cis-eQTL of same gene
  --nperms N_PERMS		numer of permutations
  --upstream UP_STREAM		upstream region to flank the genetic region 
  --downstream DOWN_STREAM	downstream region to flank the genetic region
  --map MAP_FILE		snps map file path
  --maf MAF_FILE		snps maf file path
  --gexp GEXP_FILE		gene expression file path
  --geno GENO_FILE		genotype file path
  --help | -h			user guide
```

#### Example
```bash
cis-eqtl -a 0.05 --upstream 1000 --map snp.map
```

### network

`network` command provide the tools for constructing a gene regulatory network (GRN) following the two-stage penalized least squares (2SPLS) approach proposed by [D. Zhang, M. Zhang, Ren, and Chen](https://arxiv.org/abs/1511.00370).

`network` receive the input from the previous step:

* `net.Gexp.data`: output from `cis-eqtl`, is the expression data for genes with cis-eQTL:  
* `all.eQTL.data`: output from `cis-eqtl`, includes the genotype data for marginally significant  cis-eQTL:  
* `all.sig.pValue_0.05`: output from `cis-eqtl`,includes the $p$-value of each pair of gene and its marginally significant (p-Value < 0.05) cis-eQTL, where Column 1 is Gene Index (in `net.Gexp.data`), Column is SNP Index (in `all.Geno.data`), and Column 3 is p-Value.
 
The final output files of `network` will be saved under `/data/network/stage2`:
* `adjacency_matrix`: the adjancency matrix for the estimated regulatory effects;
* `coefficient_matrix`: the coefficient matrix for the estimated regulatory effects;

#### usage
```bash
network [OPTION VAL] ...
```

**Comments**

Would rather take the commands
```bash
signet -n [OPTION VAL] ...
```



#### description

```bash
 --ncis NCIS	maximum number of cis-eQTL for each gene
 -r MAX_COR		maximum corr. coeff. b/w cis-eQTL of same gene
 --nnodes N_NODE			
 --ncores N_CORES  		
 --memory MEMORY			
 --walltime WALLTIME	
```

**Comments**

Possible changes:
```bash
 --rmax MAX_COR		maximum corr. coeff. b/w cis-eQTL of same gene
```



### netvis

`netvis` provide tools to visualize our constructed gene regulatory networks. Users can choose the bootstrap frequency threshold  and number of subnetworks to visualize the network.

`netvis` will automatically read the output from `network` step:
* `adjacency_matrix`: the adjancency matrix for the estimated regulatory effects;
* `coefficient_matrix`: the coefficient matrix for the estimated regulatory effects;

In addition, we also need user to provide node information file to identify transcription factor for visualization.


#### usage
```bash
netvis [OPTION VAL] ...
```

**Comments**
Possible changes:
```bash
signet -v [OPTION VAL] ...
```


#### description

```bash
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
# basic settings
[BASIC]
nchr = 26
storage.path = STORAGE_PATH

[GENO]
ped.file = xxx
map.file = PATH/xxx.map


[GENEXP]
ge.file = PATH/xxx.ge
gpos.file = PATH/xxx.gpos

[PLINK]
mind = 0.1
ggeno = 0.1
hwe = 0.0001
recode = A

[CISEQTL]
snps.map = ./data/cis-eQTL/snps.map
snps.maf = ./data/cis-eQTL/snps.maf
gexp.file = ./data/cis-eQTL/gexp_prostate
matched.geno = ./data/cis-eQTL/matched.Geno
gene.pos = ./data/cis-eQTL/prostate_gene_pos
alpha.cis = 0.05
nperms = 100
upstream = 1000
downstream = 500

[NETWORK]
uncor.ncis = 3
uncor.r = 0.5
nboots = 5
nnodes = 500
ncores = 16
memory = 64
walltime = 4

[NETVIS]
freq = 0.8
ncount = 2
ninfo = ./data/netvis/mart_export_protein_coding_37.txt
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
	- main.sh # main entrance 
config.ini
# data folder save all the relavant data and intermediate data
- data/
	- cis-eQTL/
	- network/
	- netvis/
```
