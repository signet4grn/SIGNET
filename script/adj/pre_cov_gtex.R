## Sex, 0 for male, 1 for female
library(data.table)
pheno <- as.matrix(read.delim("../genotype_after_phasing/pheno.txt", skip=10))
gexp <- fread("expression_normalized_withoutigt_GTEx_lung.expression.bed.gz", header=T)
subj <- names(gexp)[-c(1:4)]
sex <- as.numeric(pheno[match(subj, pheno[, 2]), 4])-1
sex <- t(cbind(subj, sex))
rownames(sex) <- c("ID", "SEX_d")
write.table(sex, "sex_lung.txt", row.names=T, col.names=F, quote=F, sep="\t")

## First 2 PCs
library(data.table)
gexp <- fread("expression_normalized_withoutigt_GTEx_lung.expression.bed.gz", header=T)
subj <- names(gexp)[-c(1:4)]
evec <- read.table("Geno.pca.evec")
name_dup <- as.matrix(evec[, 1])
sep <- function(x) {unlist(strsplit(x, ":"))[1]}
name_tot <- apply(name_dup, 1, sep)

pc2 <- evec[match(as.matrix(subj), as.matrix(name_tot)), 1:3]
pc2[, 1] <- subj
pc2 <- as.data.frame(t(pc2))
rownames(pc2) <- c("ID", "C1", "C2")
write.table(pc2, "pc_lung.txt", row.names=T, col.names=F, quote=F, sep="\t")

## Sequencing Platform (illumina Hiseq2000(0) or Hiseq X(1)) 
library(dplyr)
library(data.table)
gexp <- fread("expression_normalized_withoutigt_GTEx_lung.expression.bed.gz", header=T)
subj <- names(gexp)[-c(1:4)]
##extract id from annotation file
annotation <- read.delim("../genotype_after_phasing/GTEx_Analysis_v8_Annotations_SampleAttributesDS.txt")
annotation <- as.data.frame(annotation)
sampid_geno <- as.matrix(read.table("../genotype/GTEx.vcf_sample.txt"))
plat <- annotation[match(sampid_geno, annotation[, 1]), c(1, 16)]

gen_subj <- function(x){
  first <- unlist(strsplit(x, "-"))[1]
  second <- unlist(strsplit(x, "-"))[2]
  res <- paste(first, second, sep="-")
  return(res)
}
subj_geno <- apply(sampid_geno, 1, gen_subj)

get_plat <- function(x){
if((x=="PCR+ 30x Coverage WGS (HiSeq2000)")||(x=="PCR+ 30x Coverage WGS v1 (HiSeq2000)")){
  res <- 0
}  
  else{
  res <- 1 
}
  return(res)
} 

plat_ind <- apply(as.matrix(plat[match(subj, subj_geno), 2]), 1, get_plat)
plat_ind <- t(cbind(subj, plat_ind))
rownames(plat_ind) <- c("ID", "plat")
write.table(plat_ind, "plat_lung.txt", row.names=T, col.names=F, quote=F, sep="\t")


## Sequencing protocol (PCR_based(0) or PCR_free(1))
get_protocol <- function(x){
  if(startsWith(x, "PCR+")){
    res <- 0
  }
  else{
    res <- 1
  }
  return(res)
}

protocol <- apply(as.matrix(plat[match(subj, subj_geno), 2]), 1, get_protocol)
protocol <- t(cbind(subj, protocol))
rownames(protocol) <- c("ID", "protocol")
write.table(protocol, "protocol_lung.txt", row.names=T, col.names=F, quote=F, sep="\t")

explicit_cov_lung <- rbind(sex, as.matrix(plat_ind[-1, ,drop=F]), as.matrix(protocol[-1, ,drop=F]))

write.table(explicit_cov_lung, "explicit_cov_lung.txt", row.names=T, col.names=F, quote=F, sep="\t")

