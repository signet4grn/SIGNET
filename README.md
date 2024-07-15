# SIGNET User's Manual

## Citation
```
@article{jiang2023signet,
  title={SIGNET: transcriptome-wide causal inference for gene regulatory networks},
  author={Jiang, Zhongli and Chen, Chen and Xu, Zhenyu and Wang, Xiaojian and Zhang, Min and Zhang, Dabao},
  journal={Scientific Reports},
  volume={13},
  number={1},
  pages={19371},
  year={2023},
  publisher={Nature Publishing Group UK London}
}
```

## Reference to SIGNET

SIGNET is based on the paper [Jiang et al. (2023)](https://www.nature.com/articles/s41598-023-46295-6). The core of the current version of SIGNET is to use the two-stage penalized least squares (2SPLS) method proposed by [Chen et al. (2018)](https://www.jmlr.org/papers/volume19/16-225/16-225.pdf) to construct genome-wide gene regulatory networks (GW-GRNs). An application of 2SPLS to yeast data can be found in [Chen et al. (2019)](https://www.nature.com/articles/s41598-018-37667-4).

While current SIGNET constructs the GW-GRN with transcriptomic and genotype data collected from on population, we are developing SIGNET to simultaneiously construct and compare GW-GRNs for two or more populations for the purpose of (i) more powerful to establish comment reguations shared across different populations; (ii) more effectively identify population-specific (e.g., cancer-specific) gene regulations.


## System Requirement 

SIGNET runs on a **UNIX bash shell**. Check your shell with `echo $SHELL` to make sure that you are running on UNIX bash shell. SIGNET uses the [**Slurm Workload Manager**](https://slurm.schedmd.com/overview.html) for high performance computing (HPC) clusters in its stage of constructing the gene regulatory network in parallel.


## Quick Installation of SIGNET 

First you should clone the directory to the path in your server and add the path where you install the software to enable directly running the command without specifying a particular path.
```bash
git clone https://github.com/signet4grn/SIGNET.git
cd SIGNET
export PATH=/path/to/signet:$PATH
```
where `/path/to/signet` should be replaced with your path to **SIGNET**.


### Installation of Required Packages

SIGNET runs dependent on several packages such as PLINK, IMPUTE2, and R (with its libraries). While you may install all of these packages by yourself, we also provide a Singularity container `signet.sif` which packs all the packages required by SIGNET. The Singularity container `signet.sif` provides an environment in which *SIGNET* can smoothly run, so you don't have to separately install any of the required packages for SIGNET.

Before having the Singularity container `signet.sif`, first you have to install **Singularity** following https://sylabs.io/guides/3.8/user-guide/quick_start.html#quick-installation-steps.

You can pull the image from [our repository](https://cloud.sylabs.io/library/geomeday/signet/signet) and rename it as `signet.sif`, after which you can append the path of package to singularity so it can execute SIGNET smoothly. You may also need to bind a path in case container doesn't recognize your file. The environment variables have to be exported **everytime you start a new terminal**.
```bash
singularity pull library://jiang548/signet/signet:0.0.6
export SINGULARITYENV_APPEND_PATH="/path/to/signet"
export SINGULARITY_BIND="/path/to/bind"
```
where `/path/to/signet` should be replaced with your path to SIGNET, and `/path/to/bind` should be replaced with the desired bath to bind.

You can use the image by attaching a prefix ahead of the original commands you want to execute, which are described in details in sections below.
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

**Caution:** All the intermediate result for each step will by default return to the corresponding folders in the tmporary directory starting with 'tmp' and all the final result will return to the result folders starting with 'res'.  You could also change the path of result files in the configuration file named config.ini, or use signet -s described below. Please be careful if you are using the relative path instead of the absolute path. The config.ini will record the path relative to the folder that **SIGNET is installed**, in order to reach file mangement consistency. It's highly recommended to run command where signet is installed.  In each of the process, you could specify the result path, and you will be asked to whether purge the tmporary files, if you already have those. It's also suggested you keep a copy of the temporary files for each analysis, in case you need them in later steps. Please **run each analysis at a time under the same folder, as a latter process will overwrite the previous tmporary files**. 



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


## Quick Start

#### 1. Prepare the DataSet

We highly recommand you to prepare the gene expression data and genotype data first, and place them to a specific data folder, to organize each step as it may involve many files.


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
signet -s --nchr --d
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

The command `signet -t` will take the matrix of base-2 logarithm transformed gene count data and preprocess it. Each row represents the data for each gene, and each column represents the data for each sample, while the first row is the sample name, and the first column is the gene name. Note that the last 5 rows are not considered in the analysis since they contain ambigous gene information by [UCSC](https://xenabrowser.net/datapages/).

In this step, we will filter out genes with total counts less than 2.5 million according to NIH standard and are counted in less than 20% of the samples, after which we will apply variance stablizing transformation by DESeq2 to normalize data. Furthermore, we will only focus on protein coding genes. 


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
- `gexp`: the base-2 logarithm transformed count data for genes as a matrix with the first column containing the ENSEMBEL ID, the first row containing sample names, the rest rows include data for genes and rest columns encode data for samples (however, the last 5 rows are not included in the following analysis since they contain ambigous gene information by UCSC);
- `pmap`: collapsed genecode v22 gtf file, an annotation file which combines all isoforms of a gene into a single transcript. The detailed information could be found in [collapsed gene model](https://github.com/broadinstitute/gtex-pipeline/tree/master/gene_model);
- `restrict`: specifing chromosome(s) of interest, which may be dash separated, e.g. 1-22; comma separated, e.g. 1,2,3; or simply a number, e.g. 1.

#### Result files

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

We adopted and modified the code from [GTEx pipeline](https://github.com/broadinstitute/gtex-pipeline/tree/master/qtl).  

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

The command `signet -g` provides the user interface of preprocessing genotype data. We first use [**PLINK**](https://zzz.bwh.harvard.edu/plink/) to conduct quality control, filtering out samples and SNPs with high missing rates and filtering SNPs discordant with Hardy Weinberg equilibruim. We then use [**IMPUTE2**](https://mathgen.stats.ox.ac.uk/impute/impute_v2.html) to impute missing genotypes in parallel. 


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
  --restrict                    restrict to the chromosome of interest
  --r | --ref                   reference file for imputation
  --gmap                        genomic map file
  --i | --int                   interval length for IMPUTE2
  --ncores                      number of cores
  --resg                        result prefix
```
- `ped`: includes pedgree information, i.e.,[family_ID, individual_ID, mother_ID, father_ID, gender,phenotype] in the ﬁrst six columns, followed by 2p columns with two columns for each of p SNPs;
- `map`: includes SNP location information with four columns, i.e., [chromosome, SNP_name, genetic_distance,locus] for each of p SNPs;
- `mind`: missing rate cutoff for individuals, a value in [0, 1]. By default 0.1;
- `geno`: missing rate cutoff for SNPs, a value in [0, 1]. By default 0.1;
- `hwe`: Hardy-Weinberg equilibrium cutoff, a value in (0, 1]. By default 10^-4;
- `restrict`: specifing chromosome(s) of interest, which may be dash separated, e.g. 1-22; comma separated, e.g. 1,2,3; or simply a number, e.g. 1.
- `ref`: reference file for imputation, can be downloaded from website of [IMPUTE2]( http://mathgen.stats.ox.ac.uk/impute/impute_v2.html);
- `gmap`: genomic map file for imputation, can be downloaded from website of [IMPUTE2]( http://mathgen.stats.ox.ac.uk/impute/impute_v2.html); 
- `int`: a positive number specifying the interval length for imputation. By default 5 * 10^6;
- `ncores`: an integer larger than 1 specifying number of cores in the current server. By default 20.

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

#### Result files

Two files will be generated from preprocessing the genoytpe data (The filename begins with `signet` by default, you are able to customize it by setting an additional flag `--resg`. e.g. `--resg res/resg/[younameit]`):

- `signet_Geno`: Genotype data with each row denoting the SNP data for one subject;
- `signet_Genotype.sampleID`: Sample ID for each individual, which uses the reading barcode.




(GTEx)  
`signet -g` command provide the user the interface of preprocessing genotype data. We will first extract the genotype data that has corresponding samples from gene expression data for a particular tissue, and then select SNPs that have at least count 5.


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
- `vcf0`: includes SNP data from GTEx v8 before phasing in vcf format, could be downloaded from [dbGaP](https://www.ncbi.nlm.nih.gov/projects/gap/cgi-bin/study.cgi?study_id=phs000424.v8.p2);
- `vcf`: includes SNP data from GTEx v8 after phasing in vcf format, could be downloaded from [dbGaP](https://www.ncbi.nlm.nih.gov/projects/gap/cgi-bin/study.cgi?study_id=phs000424.v8.p2);
- `read`: gene count data in tpm format, could be downloaded from [GTEx_portal](https://gtexportal.org/home/datasets);
- `anno`: GTEx v8 annotation file, could be downloaded from [GTEx_portal](https://gtexportal.org/home/datasets); 
- `tissue`: tissue type, lower/upper case must exactly map to what is included in the annotation file.


#### Example
```bash
# Set the cohort to GTEx
signet -s --cohort GTEx


# Modify the paramter
signet -g --vcf0 data/geno-prep/Geno_GTEx.vcf \
          --vcf data/genotype_after_phasing/Geno_GTEx.vcf \
          --read data/gexp/GTEx_gene_reads.gct \
	  --anno data/GTEx_Analysis_v8_Annotations_SampleAttributesDS.txt \
	  --tissue Lung
```

#### Result files
Output of `signet -g` will be saved to res/resg.
- `signet_clean_Genotype_repNA.data`: cleaned SNP data.
- `signet_snps.maf`: minor allele frequency file for selected SNPs.
- `signet_snps.map`: map file for selected SNPs.


### Adj

The command `signet -a` provides users the interface to match genotype and gene expression files, calculate principal components (PCs) for population stratification, adjust for covariates effect by top PCs, races and gender. Then calculate the minor allele frequency (MAF).

Note that `signet -a` reads the output from `signet -g` and `signet -t`.

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
- `c`:  specifying a TSV file including clinical information, with at least columns of submitter id, gender and race in TCGA data.


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

Now that we have completed all necessary preprocessing, normalization, and data cleaning, we are ready to perform cis-eQTL mapping. If you want to construct GRN with your own data (rather than TCGA or GTEx data), you should preprocess your data by yourself (instead of above functions provided by **SIGNET**) and then use **SIGNET** from this step. 

**Before you start this step, please make sure that you have the following files ready:**
- Gene expression file including preprocessed gene expressions matched with preprocessed genotype data, adjusted for all covariates including top PCs (for `--gexp`);
- Gene expression file including preprocessed gene expressions matched with preprocessed genotype data, adjusted for all covariates other than top PCs (for `--gexp.withpc`);
- Genotype file including SNP minor allele count data as a matrix of values 0, 1, 2, with each row encoding for one subject and each column encoding for one SNP (for `--geno`);
- Map file including SNP positions as a matrix in .map file format;
- MAF file including SNP minor allele frequency data as one column where each value is the number of SNPs after preprocessing (for `--maf`);
- Gene position information file with the first column specifying the gene name, second column specifying the chromosome index (e.g. "chr1"), the third and fourth columns specifying the start and the end positions of the gene, respectively (for `--gene_pos`). 

**Caution:** Genes in the two gene expression files are arranged according to the order of genes in the gene position information file.

For each gene, we will use an adaptive rank sum permutaion test to identify its cis-eQTL as instrumental variables. Therefore, the possible instrumental variables of a specific gene include any genetic variants within its coding region as well as upstream and downstream regions up to certain ranges which will be specified by options `--upstream` and `--downstream`, respectivly. 

#### Usage

```
signet -c [OPTION VAL] ...
```


#### Description

```
  --gexp                        file of gene expressions adjusted for all covariates, matched with genotype data
  --gexp.withpc                 file of gene expressions adjusted for all covariates other than top PCs, matched with genotype data
  --geno                        file of genotype data matched with gene expression data
  --map                         snps map file path
  --maf                         snps maf file path
  --gene_pos                    gene position file
  --alpha | -a			significance level for cis-eQTL
  --nperms                 	number of permutations
  --upstream               	number of base pairs upstream the genetic region
  --downstream                  number of base pairs downstream the genetic region
  --resc                        result prefix
  --help | -h			user guide
```
- `gexp `:  specifying the gene expression file including preprocessed gene expressions matched with preprocessed genotype data, adjusted for all covariates including top PCs;
- `gexp.withpc`: specifying the gene expression file including preprocessed gene expressions matched with preprocessed genotype data, adjusted for all covariates other than top PCs;
- `map`: specify the file including SNP positions as a matrix in .map file format;
- `maf`: specify the MAF file inlcuding SNP minor allele frequency data as one column where each value is the number of SNPs after preprocessing;
- `geno`: specifying the genotype file including SNP minor allele count data as a matrix of values 0, 1, 2, with each row encoding for one subject and each column encoding for one SNP;
- `gene_pos`: specifying the gene position information file with the first column specifying the gene name, second column specifying the chromosome index (e.g. "chr1"), the third and fourth columns specifying the start and the end positions of the gene, respectively (for `--gene_pos`). 
- `alpha` : specifying a value in (0, 1) as the significance level for identifying instrumental variables. By default 0.05;
- `nperms`: specifying the number of permutations. By default 100;
- `upstream`: specifying the number of base pairs upstream each genetic region. By default 1000;
- `downstream`: specifying the number of base pairs downstream each genetic region. By default 1000.


#### Result files

Output of `cie-eQTL` will be saved to `res/resc`:

* `signet_net.Gexp.data`: is the expression data for gene expression, wo removing the PC by default.
* `signet_net.genepos`: include the position for genes in `signet_net.Gexp.data`, has four columns: gene name, chromosome number, start and end position, respectively.
* `signet_cis.name`: genes with cis-eQTLs.
* `signet_[common|low|rare|all].eQTL.data`: includes the genotype data for marginally significant [ common | low | rare | all ] cis-eQTL;
* `signet_[common|low|rare|all].sig.pValue_alpa`: includes the p-value of each pair of gene and its marginally significant [ common | low | rare | all ]  cis-eQTL, where Column 1 is Gene Index, Column is SNP Index in `common.eQTL.data`, and Column 3 is p-Value.
* `signet_[common|low|rare|all].sig.weight_alpha`: includes the weight of collapsed SNPs for marginally significant cis-eQTL. The first column is the gene index, the second column is the SNP index, the third column is the index of collapsed SNP group, and the fourth column is the weight of each SNP in its collapsed group (with value 1 or -1).


#### Example

```
 signet -c --upstream 1000 \
           --downstream 1000 \
	   --nperms 100 \
	   --alpha 0.05
```


### Network

The command `signet -n` provides the tools for constructing a GRN using the two-stage penalized least squares (2SPLS) approach proposed by Chen et al. (2018). Note that the same set of data will be bootstrapped `nboots` times and each bootstrapping data set will be used to construct a GRN. The frequencies of the regulations appeared in the `nboots` GRNs will be used to evaluate the robustness of constructed GRN with higher frequency implying more robust regulation. 

`network` receive the input from the previous step, or it could be the output data from your own pipeline:

**Caution**
**Please make sure that you are using the SLURM system. Please also don't run this step inside a container, as the singularity container is integrated as part of the procedure.**


#### Usage

```
signet -n [OPTION VAL] ...
```


#### Description

```
  --net.gexp.data               gene expression data for GRN construction
  --net.geno.data               marker data for GRN construction
  --sig.pair        	        significant index pairs for gene expression and markers
  --net.genename                gene name files for gene expression data
  --net.genepos                 gene position files for gene expression data
  --ncis                        maximum number of biomarkers for each gene
  --cor                         maximum correlation between biomarkers
  --nboots                      number of bootstraps datasets
  --memory                      memory in each node in GB
  --queue                       queue name
  --ncores                      number of cores to use for each node
  --walltime       		maximum walltime of the server
  --interactive                 T, F for interactive job scheduling or not
  --resn                        result prefix
  --sif                         singularity container
  --email                       send notification emails after each stage is compeleted if you have mail installed in Linux, and interactive=F
```
- `net.gexp.data`: output from `signet -c`, including the expression data of genes with cis-eQTL, a n*p matrix with each row encoding the gene expression data for one subject;
- `net.geno.data`: output from `signet -c`, including the genotype data of significant cis-eQTL, a n*p matrix with each row encoding the genotype data for one subject; 
- `sig.pair`: output from `signet -c`, including the p-value of each pair of gene and its significant cis-eQTL with Column 1 specifying Gene Index (in `net.Gexp.data`), Column specifying SNP Index (in `all.Geno.data`), and Column 3 specifying p-value;
- `net.genename`:  gene name in a  p*1 vector;
- `net.genepos`:  gene position as a  p*4 matrix, with first column including gene names, second column including chromosome index (e.g, "chr1"), third and fourth columns including the start and end position of genes in the chromosome, respectly;
- `ncis`:  an integer as the maximum number of biomarkers associated with each gene. By default 3;
- `cor`: a value in [-1, 1] specifying the maximum correlation between biomarkers. By default 0.6;
- `nboots`: an integer as the number of bootstrapping data sets taken in calculation. By deault 100; 
- `queue`: a string for queue name in the cluster;
- `ncores`: number of cores for each node. By default 128;
- `memory`: memory of each node, in GB. By default 256;
- `walltime`: maximum wall time for cluster. By default 4:00:00;
- `sif`:  a Singularity container, in .sif format;
- `email`: the email address from which you can receive notification, with default value `F` meaning no notification and is only enabled where interactive=F.


#### Result files

- `signet_Afreq`: Ajacency matrix for final list of genes. A[i, j]=1 if gene i is regulated by gene j. 0 entry indicates no regulation. 
- `signet_CoeffMat0`: Coefficient matrix of estimated regulatory effect on the original data set.
- `signet_net.genepos`: Corresponding gene name, followed by chromsome location, start and end position. 


#### Example

```
signet -n --nboots 100 \
          --queue standby \
	  --walltime 4:00:00 \
	  --memory 256
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
  --Afreq                      matrix of regulation frequencies from bootstrap results
  --freq                       bootstrap frequecy for the visualization
  --ntop                       number of top sub-networks to visualize
  --coef                       coefficient of estimation for the original dataset
  --vis.genepos                gene position file
  --id                         NCBI taxonomy id, e.g. 9606 for Homo Sapiens, 10090 for Mus musculus
  --assembly                   genome assembly, e.g. hg38 for Homo Sapiens, mm10 for Mus musculus
  --tf                         transcirption factor file, only sepecified for non-human data
  --resv                       result prefix
  --help                       usage
```
- `Afreq`: specifying the estimated bootstrap frequencies for regulations in a matrix with *(row, column)*-th entry encoding the frequency of *row* gene regulated by *column* gene;   
- `freq`: specifying the bootstrap frequency cutoff as a value in [0, 1]. By default 1;
- `ntop`: specifying the number of top subnetworks to visualize. By default 1;
- `coef`: specifying the file including the estimation of coefficients from the original data, a matrix with its *(row,column)* value for the *row* gene regulated by *column* gene; 
- `vis.genepos`: specifying the file including the position of genes to be visualized, a matrix with the first column including the gene name, second column including its chromosome index (e.g. "chr1"), the thrid and fourth column including its start and end positions in the chromosome, respectively; 
- `id`: specifying NCBI taxonomy id number, e.g, `9606` for Homo Sapiens. By default `9606`;
- `assembly`: specifying Genome assembly. e.g, `hg38` for Homo Sapiens. By default `hg38`;
- `tf`: specifying a file with the names of genes that are transcription factors, only needed for the study which is **not** for Homo Sapiens.



#### Result files

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
