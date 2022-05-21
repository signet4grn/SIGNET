
# SIGNET User's Manual

## Copyright of SIGNET

The core of current version of SIGNET is to use the two-stage least squares approach proposed by [Chen et al. (2018)](https://www.jmlr.org/papers/volume19/16-225/16-225.pdf) to construct genome-wide gene regulatory networks. 

## System Requirement 

SIGNET runs on a **UNIX bash shell**. Check your shell with `echo $SHELL` to make sure that you are running on UNIX bash shell. SIGNET uses the [**Slurm Workload Manager**](https://slurm.schedmd.com/) for high performance computing (HPC) clusters in its stage of constructing the gene regulatory network in parallel. **Zhongli: How to check whether the system uses SLURM?**



## Quick Installation of SIGNET 

First you should clone the directory to the path in your server and add the path where you install the software to enable directly running the command without specifying a particular path.
```bash
git clone https://github.itap.purdue.edu/jiang548/SIGNET.git
cd SIGNET
export PATH=/path/to/signet:$PATH
```
where `/path/to/signet` should be replaced with your path to **SIGNET**.


## Installation of Required Packages

There are two ways to install the required packages for SIGNET: (1) Install Singularity and copy the Singularity container file `signet.sif` to your server; (2) Install all the required packages to your sever by yourselves (not recommended).

### Required packages by SIGNET

While you can install all of these packages in your sever, we would rather suggest you to install Singularity and use the Singularity container `signet.sif` coming with SIGNET. A list of packages SIGNET are listed on DEPENDENCY.md:

- PLINK 
- IMPUTE2
- R & its libararies.




### Use Singularity container for required packages 

If you are using the linux system, you could install singularity following https://sylabs.io/guides/3.8/user-guide/quick_start.html#quick-installation-steps. If you are a windows/mac user, you could find the installation guide in https://sylabs.io/guides/3.8/admin-guide/installation.html. You could also choose to skip the container, and instead install all the packages required mannually. 

1. The Singularity Image Format file **signet.sif** comes with all the required pacakges for *SIGNET*, and an environment that *SIGNET* could run smoothly in. You could first pull the image from our repository and rename it as "signet.sif", after which you could append the path of package to singularity so it could execute *SIGNET* smoothly. You may also need to bind a path in case container doesn't recognize your file. The environment variables have to be exported **everytime you start a new terminal**.
```bash
singularity pull library://geomeday/signet/signet:0.05
export SINGULARITYENV_APPEND_PATH="/path/to/signet"
export SINGULARITY_BIND="/path/to/bind"
```
where */path/to/signet* should be replaced with your path to *SIGNET*, and "/path/to/bind" should be replaced with the desired bath to bind.

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
All the intermediate result for each step will by default return to the corresponding folders in the tmporary directory starting with 'tmp' and all the final result will return to the result folders starting with 'res'.  You could also change the path of result files in the configuration file named config.ini, or use signet -s described below. Please be careful if you are using the relative path instead of the absolute path. The config.ini will record the path relative to the folder that **SIGNET is installed**, in order to reach file mangement consistency. It's highly recommended to run command where signet is installed.  In each of the process, you could specify the result path, and you will be asked to whether purge the tmporary files, if you already have those. It's also suggested you keep a copy of the temporary files for each analysis, in case you need them in later steps. Please **run each analysis at a time under the same folder, as a latter process will overwrite the previous tmporary files**. 


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

Here we set the number of autosomes to 22, so the chromosomes we study are 1-22.

```bash
signet -s --nchr 22
```

We can use the command to check below to check autosome number
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


#### 4. Gene Expression Preprocess

For preprocessing transcriptomic (gene expression) data
```bash
signet -t
```


#### 5. cis-eQTL Analysis

For cis-eQTL analysis.
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

`signet -s` command is used for look up and modify parameter in the configuration file config.ini. You don't have to modify the parameters at the very beginning, as you will have options to change your input parameters in each step. 

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

`signet -t` command will take the matrix of log2(x+1) transcriptome count data and preprocess it. 


#### Usage

```bash
signet -t [--g GEXP_FILE] [--p MAP_FILE]
```


#### Description

```bash
 --g | --gexp                   gene expression file
 --p | --pmap                   genecode gtf file
 --restrict                     restrict the chromosomes of study
 --r | --rest                   result prefix
```
* `gexp`: include the log2(x+1) count data for genes. It's a matrix with first column to be the ENSEMBEL ID and the first row to be sample names.  In the rest of the data,  rows represent the data for gene, where columns encodes data for samples. Note that the last 5 rows are not considered in the analysis since they contain ambigous gene information that is convention by UCSC..
* `pmap`: genecode v22 gtf file.  
* `restrict`: include the chromosome of interst. Could be dash separated, e.g. 1-22; comma separated, e.g. 1,2,3; or simply a number, e.g. 1.


#### Result

Output of `gexp-prep` will be saved to `res/rest`. 
- `signet_gexp`: gene expression data after pre-processing.
- `signet_gene_name`: corresponding gene name.
- `signet_gene_pos`: correspongding gene position.
- `signet_gexpID`: correspdonding sample ID.


#### Example

```bash
# List the paramter
signet -t --help
## Display the help page 

# Modify the paramter
signet -t --g data/gexp-prep/TCGA-LUAD.htseq_counts.tsv \
          --p data/gexp-prep/gencode.v22.gene.gtf \
	  --restrict 1
	  
## The preprocessed gene expresion result with correpsonding position file will be stored in /res/rest/
```

(GTEx)


#### Usage

```bash
signet -t [--r READS_FILE] [--tpm TPM_FILE]
```


#### Description

```bash
 --r | --read                    gene reads file in gct format
 --t | --tpm                     gene tpm file
 --g | --gtf                     genecode gtf file
 --rest                          result prefix
```

* `read`:  GTEx reads file in gct format.
* `tpm`:  GTEx TPM file in gct format. 
* `gtf`:  collapse gene code v26 gtf file. 

#### Example

```bash
# List the paramter
signet -t --help
## Display the help page 

# Modify the paramter
signet -t --reads data/gexp/GTEx_gene_reads.gct \
          --tpm data/gexp/GTEx_gene_tpm.gct \
          --gtf data/gexp-prep/gencode.v26.GRCh38.genes.gtf
	  
## The preprocessed gene expresion result with correpsonding position file will be stored in /res/rest/
```




### Geno-prep

(TCGA)

`signet -g` command provide the user the interface of preprocessing genotype data. We will do quality control, after which we will use IMPUTE2 for imputation. 


#### Usage

```bash
signet -g [OPTION VAL] ...
```


#### Description

```                           
  --p | --ped                   ped file
  --m | --map                   map file
  --mind                        missing rate per individual cutoff
  --geno                        missing rate per marker cutoff
  --hwe                         Hardy-Weinberg equilibrium cutoff
  --r | --ref                   reference file for imputation
  --gmap                        genomic map file
  --i | --int                   interval length for impute2
  --ncores                      number of cores
  --resg                        result prefix
```
- `ped`: includes pedgree information, i.e.,[family_IDindividual_IDmother_IDfather_ID gender phenotype] in the ﬁrst six columns, followed by 2p columns with two columns for each of p SNPs
- `map`: includes SNP location information with four columns,i.e.,[chromosomeSNP_name genetic_distance locus] for each of p SNPs.
- `mind`: missing rate cutoff for individuals. It's a value in [0, 1].
- `geno`: missing rate cutoff for SNPs. It's a value in [0, 1].
- `hwe`: Hardy-Weinberg equilibrium cutoff. It's a value in (0, 1].
- `ref`: Reference file for imputation. It could be downloaded from http://mathgen.stats.ox.ac.uk/impute/impute_v2.html. 
- `gmap`: Genomic map file for imputation. It could be downloaded from http://mathgen.stats.ox.ac.uk/impute/impute_v2.html. 
- `int`: interval length for imputation. Should be a positive number.
- `ncores`: Number of cores in the current server. It's an integer larger than 1.


#### Example

```bash
# List the paramter
signet -g --help
## Display the help page 

# Modify the paramter
signet -g --ped data/geno-prep/test.ped \
          --map data/geno-prep/test.map \
	  --ref data/ref_panel_38/chr \
	  --gmap data/gmap/chr
```

#### Result

Output of `geno-prep` will be saved under `/res/resg`:
- `signet_Geno`: Genotype data with each row denoting the SNP data for each individual.
- `signet_Genotype.sampleID`: Sample ID for each individual, which uses the reading barcode.





(GTEx)
`signet -g` command provide the user the interface of preprocessing genotype data. We will first extract the genotype data that has corresponding samples from gene expression data for a particular tissue. 



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
- `vcf`: includes SNP data from GTEx v8 before phasing in vcf format
- `vcf0`: includes SNP data from GTEx v8 after phasing in vcf format
- `read`: gene count data in tpm format
- `anno`: GTEx v8 annotation file
- `tissue`: tissue type, lower/upper case must exactly map to what is included in the annotation file 


#### Example
```bash
# Set the cohort
signet -s --cohort GTEx


# Modify the paramter
signet -g --vcf0 data/geno-prep/Geno_GTEx.vcf \
          --vcf data/genotype_after_phasing/Geno_GTEx.vcf \
          --read data/gexp/GTEx_gene_reads.gct \
	  --anno data/GTEx_Analysis_v8_Annotations_SampleAttributesDS.txt \
	  --tissue Lung
```






### Adj

`signet -a` command provide users the interface of matching genotype and gene expression file and the calculation for minor allele frequency (MAF)
`signet -a` read the output from `geno-prep` and `gexp-prep`
output of `adj` will be saved under `/res/resa`:

(TCGA)

- `c`:  clinical file from TCGA project. Should contain at least a column of submitter id.


#### Usage

```bash
signet -a [--c CLINIVAL_FILE]
```


#### Description

```bash
 --c | clinical                   clinical file for your cohort
 --resa                           result prefix
```
- `c`:  clinical file from TCGA project. Should contain at least columns of submitter id, gender and race.


#### Example

```bash
signet -a --c ./data/clinical.tsv
```
Output of `adj` will be saved to `res/resa`:
- `signet_geno.data`: matched genotype data, with rows representing samples and columns representing SNPs.
- `signet_gexp.data`: matched gene expression datat o be used further for network analysis, adjusted for covariates but don't include PCs, with rows representing samples and columns representing gene expressions.
- `signet_gexp_rmpc.data`: matched gene expression data to be used further for cis-eQTL analysis, adjusted for covariates including PCs, with rows representing samples and columns representing gene expressions.
- `signet_matched.gexp`:  matched gene expression data, without ajusting for covariates, with rows representing samples and columns representing gene expressions.
- `signet_new.Geno.maf`: MAF file for genotype data. 
- `signet_new.Geno.map`: MAP file for genotype data.


(GTEx)


#### Usage

```bash
signet -a [--p PHENOTYPE_FILE]
```


#### Description

```
 --pheno                          GTEx phenotype file
 --resa                           result prefix
```
-`pheno`:  phenotype file from the GTEx v8.


#### Example

```bash
signet -a --pheno \
./data/pheno.txt 
```


### Cis-eqtl

`signet -c` command provide the basic tool for cis-eQTL analysis.  `signet -c` command receive the input file from the previous preprocess step.



#### Usage

```
signet -c [OPTION VAL] ...
```


#### Description

```
  --gexp                        gene expression file after matching with genotype data
  --gexp.withpc                 gene expression file without adjusting for principal components, after matching with genotype data
  --geno                        genotype file after matching with gene expression data
  --map MAP_FILE                snps map file path
  --maf MAF_FILE                snps maf file path
  --gene_pos                    gene position file
  --alpha | -a			significance level for cis-eQTL
  --nperms N_PERMS	        number of permutations
  --upstream UP_STREAM		upstream region to flank the genetic region
  --downstram DOWN_STREAM	downstream region to flank the genetic region
  --resc                        result prefix
```
- `gexp ` :  includes preprocessed gene expression infoamtion after matching with genotype data.  It's a matrix where each row encodes information for a sample, and columns encodes information for a gene.
- `gexp.withpc` :  includes preprocessed gene expression infoamtion after matching with genotype data, without adjusting for PC as covariate.  It's a matrix where each row encodes information for a sample, and columns encodes information for a gene.
- `snps.map` : includes snp position. It's a matrix in .map file format.
- `snps.maf` : includes snp minor allele frequency data from previous step. It's a q * 1 matrix where q is the number of snps after preprocessing.
- `matched.geno` :  includes snp minor allele count data from previous step. It's a matrix of values 0, 1, 2, with  each row encodes information for a sample, and columns encodes information for a SNP.
- `gene.pos` : includes gene position information. Where the first column is the gene name, second column is the chromosome index, e.g. "chr1", the third and fourth columns are for the start and the end positions, respectively. Please note that they are ranged in the order of the genes in the gexp and gexp.withpc file. 
- `alpha.cis` : significance level for selecting cis-eQTLs. Should be a value in (0, 1). 
- `nperms`: number of permutations. 
- `upstream`: upstream region to flank the genetic region
- `downstream`: downstream region to flank the genetic region


#### Results

Output of `cie-eQTL` will be saved to `res/resc`:

* `signet_net.Gexp.data`: is the expression data for gene expression, wo removing the PC by default.
* `signet_net.genepos`: include the position for genes in `signet_net.Gexp.data`, has four columns: gene name, chromosome number, start and end position, respectively.
* `signet_cis.name`: genes with cis-eQTLs.
* `signet_[common|low|rare|all].eQTL.data`: includes the genotype data for marginally significant [ common | low | rare | all ] cis-eQTL;
* `signet_[common|low|rare|all].sig.pValue_alpa`: includes the p-value of each pair of gene and its marginally significant [ common | low | rare | all ]  cis-eQTL, where Column 1 is Gene Index, Column is SNP Index in `common.eQTL.data`, and Column 3 is p-Value.
* `signet_[common|low|rare|all].sig.weight_alpha`: includes the weight of collapsed SNPs for marginally significant cis-eQTL. The first column is the gene index, the second column is the SNP index, the third column is the index of collapsed SNP group, and the fourth column is the weight of each SNP in its collapsed group (with value 1 or -1).


#### Example

```
 signet -c --upstream 100000 --downstream 100000 --nperms 100 --alpha 0.1
```


### Network

`signet -n` command provide the tools for constructing a gene regulatory network (GRN) following the two-stage penalized least squares (2SPLS) approach proposed by [D. Zhang, M. Zhang, Ren, and Chen](https://arxiv.org/abs/1511.00370).

`network` receive the input from the previous step, or it could be the output data from your own pipeline:

**Caution**
**Please don't directly use the singularity container to run this trunk** as it is integrated in the analysis. 


#### Usage

```
signet -n [OPTION VAL] ...
```


#### Description

```
  --net.gexp.data               gene expression data for network analysis
  --net.geno.data               marker data for network analysis
  --sig.pair        	        significant index pairs for gene expression and markers
  --net.genename                gene name files for gene expression data
  --net.genepos                 gene position files for gene expression data
  --ncis                        maximum number of biomarkers for each gene
  --cor                         maximum correlation between biomarkers
  --nboots NBOOTS               number of bootstraps datasets
  --memory MEMEORY	        memory in each node in GB
  --queue QUEUE                 queue name
  --ncores                      number of cores to use for each node
  --walltime WALLTIME	     	maximum walltime of the server in seconds
  --resn                        result prefix
  --sif                         singularity container
  --email                       send notification emails for both two stages if you have mail installed in Linux
```
* `net.gexp.data`: output from `signet -c`, includes the expression data for genes with cis-eQTL.  It's a n * p matrix, with each row encodes the gene expression data for each sample. 
* `net.geno.data`: output from `signet -c`, includes the genotype data for marginally significant  cis-eQTL. It's a n * p matrix, with each row encodes the genotype data for each sample. 
* `sig.pair`: output from `signet -c`, includes the p-value of each pair of gene and its marginally significant (p-Value < 0.05) cis-eQTL, where Column 1 is Gene Index (in `net.Gexp.data`), Column is SNP Index (in `all.Geno.data`), and Column 3 is p-Value.
 ....The third column is the p value for each pair. 
* `net.genename`:  includes information of gene name. It's a  p * 1 vector.
* `net.genepos`:  includes information of gene position. It's a  p * 4 matrix, with first column to be gene names, second columns chromosome index, e.g, "chr1", third and fourth columns are the start and end position of genes in the chromosome, respectly. 
* `ncis`:  maximum number of biomarkers associated with each gene. An integer.
* `cor`: maximum correlation between biomarkers. A value in [-1, 1].
* `nboots`: number of bootstraps in calculation. An integer. 
* `queue`: queue name in the cluster. A string.
* `ncores`: number of cores for each node.   
* `memory`: memory of each node, in GB.
* `walltime`: maximum wall time for cluster.
* `sif`:  A singularity container, in .sif format.
* `email`: The email you want to receive notification with. Default F, if no notification is preferred.


#### Results

- `signet_Afreq`: Ajacency matrix for final list of genes. A[i, j]=1 if gene i is regulated by gene j. 0 entry indicates no regulation. 
- `signet_CoeffMat0`: Coefficient matrix of estimated regulatory effect on the original data set.
- `signet_net.genepos`: Corresponding gene name, followed by chromsome location, start and end position. 


#### Example

```
signet -n --nboots 100 --queue standby --walltime 4:00:00 --memory 256
```


### Netvis

`signet -v` provide tools to visualize our constructed gene regulatory networks. Users can choose the bootstrap frequency threshold  and number of subnetworks to visualize the network.

 
You should first ssh -Y $(hostname) to a server with DISPLAY if you would like to use the singularity container, and the result can be viewed through a pop up firefox web browser

#### Usage

```
signet -v [OPTION VAL] ...
```


#### Description


```
  --Afreq EDGE_FREQ            matrix of edge frequencies from bootstrap results
  --freq FREQENCY              bootstrap frequecy for the visualization
  --ntop N_TOP                 number of top sub-networks to visualize
  --coef COEF                  coefficient of estimation for the original dataset
  --vis.genepos                gene position file
  --id                         NCBI taxonomy id, e.g. 9606 for Homo sapiens, 10090 for Mus musculus
  --assembly                   genome assembly, e.g. hg38 for Homo sapiens, mm10 for Mus musculus
  --tf                         transcirption factor file, you dont have to specify any file if its for human
  --resv                       result prefix
```
- `Afreq`:  Includes the estimated bootstrap frequency for each directed edge. With (i, j)-th element encodes the frequency of i-th gene regulated by j-th gene.  It's a p1 * p2 (p1 >= p2) **comma seperated** file where p1 is the number of genes in study and p2 is the number of genes with cis-eQTLs.   
- `freq`: The bootstrap frequency cutoff. A number in [0, 1].
- `ntop`: The number of top subnetworks to visualize. An integer number.
- `coef`: Includes the estimation of coefficients from the original data. It's a p1 * p2 (p1 >= p2) file where p1 is the number of genes in study and p2 is the number of genes with cis-eQTLs. Positive/Negative value will determine up/down regulation, with respectively. 
- `vis.genepos`: Includes the position of genes to be visualized. It's a p * 4 matrix where p1 is the number of genes in study, where the first column is the name of genes, second column is the chromosome index, e.g. "chr1",  the thrid and fourth column is the gene start and end position in the chromosome, respectively. 
- `id`: NCBI taxonomy id number. e.g, 9606 for homo sapiens.
- `assembly`: Genome assembly. e.g, hg38 for homo sapiens.
- `tf`: Includes the names of genes that are transcription factors. Should be a p1 * 1 matrix. Only need to be specified if the study is **not** for homo sapiens.


#### Result

- `signet_edgelist*`: Edgelist file includes infromation for all regulation for given cutoff. Includes gene symbol, chromosme number, start and end posistion for both source and target gene, followed by bootstrap frequency and coefficient estimated from the original data. 
- `signet_top*.html`: HTML file for largest sub-networks visualization.
- `signet_top*.name.txt`: Gene name list fo largest sub-networks, given bootstrap cutoff.


#### Example

```
signet -v 
```


## Appendix


### Configuration File

config.ini file is under the main folder and saving the costomized parameters for all of the stages of signet process. Settings in config.ini are orgnized by different sections. 

Users can change the SIGNET process by modifying the paramter settings in the configuration file.


### File Structure

```bash
# script folder save all the code
    - script/
    - gexp_prep
    - geno_prep
    - adj
    - cis-eQTL
    - network 
    - netvis
```
