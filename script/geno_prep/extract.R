args <- commandArgs(TRUE)
eval(parse(text=args))

suppressMessages(library(dplyr))
suppressMessages(library(data.table))
##extract id from annotation file
annotation <- read.delim(anno)
annotation <- as.data.frame(annotation)

##First summarize by genotype wb data  
##extract sample ids from whole blood  
sampid_wb <- annotation %>% filter(SMTSD=="Whole Blood") %>% select(SAMPID)
sampid_wb <- as.matrix(sampid_wb)
##3288

sampid_geno <- as.matrix(read.table("GTEx.vcf_sample.txt"))
##838 

sampid_geno_wb <- as.matrix(intersect(sampid_wb, sampid_geno))
##779 which matched the description  

##Find their platform 
plat_geno_wb <- annotation %>% filter(SAMPID %in% sampid_geno_wb) %>% select(SMGEBTCHT)
#<!-- > unique(plat_geno_wb) -->
#<!--                                 SMGEBTCHT -->
#<!-- 1       PCR+ 30x Coverage WGS v2 (HiSeqX) -->
#<!-- 8   PCR-Free 30x Coverage WGS v1 (HiSeqX) -->
#<!-- 514     PCR+ 30x Coverage WGS (HiSeq2000) -->

##Then summarize by gexp tissue data 

##extract sample ids from tissue tissue
sampid_tissue <- annotation %>% filter(SMTSD==tissue) %>% select(SAMPID)
sampid_tissue <- as.matrix(sampid_tissue)
##867  
gtex_read <- as.data.frame(fread(read, header = T, sep = '\t', skip = 2))
##gtex_tpm <- as.data.frame(fread("../gexp/GTEx_gene_tpm.gct", header = T, sep = '\t', skip = 2))

##first two column:names 

##check if they match
##sum(names(gtex_read)==names(gtex_tpm))
sampid_gct <- names(gtex_read)

##take their intercection
sampid_gexp_tissue <- as.matrix(intersect(sampid_gct, sampid_tissue))
##578 

##Find common subjects   
gen_subj <- function(x){
  first <- unlist(strsplit(x, "-"))[1]
  second <- unlist(strsplit(x, "-"))[2]
  res <- paste(first, second, sep="-")
  return(res)
}

subj_geno_wb <- apply(sampid_geno_wb, 1, gen_subj)
#unique(subj_geno_wb)
##779, so they are from unique individuals and there is a unique mapping in the genotype file  
subj_gexp_tissue <- apply(sampid_gexp_tissue , 1, gen_subj)
subj_common <- as.matrix(intersect(subj_geno_wb, subj_gexp_tissue))
##482  

write.table(subj_common, "subjid_wb_common.txt", row.names=F, col.names=F, quote=F)
