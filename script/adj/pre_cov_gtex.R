## Sex, 0 for male, 1 for female
suppressMessages(library(dplyr))
suppressMessages(library(data.table))

args <- commandArgs(TRUE)
eval(parse(text=args))

pheno <- as.matrix(read.delim(Sys.getenv("pheno"), skip=10))
gexp <- fread(paste0(Sys.getenv("rest"), "_expression_normalized_igt2log_GTEx_", Sys.getenv("tissue"), ".expression.bed.gz"), header=T)
subj <- names(gexp)[-c(1:4)]
sex <- as.numeric(pheno[match(subj, pheno[, 2]), 4])-1
sex <- t(cbind(subj, sex))
rownames(sex) <- c("ID", "SEX_d")
write.table(sex, paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpa/sex_lung.txt"), row.names=T, col.names=F, quote=F, sep="\t")

## First 2 PCs
evec <- read.table(paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpa/Geno.pca.evec"))
name_dup <- as.matrix(evec[, 1])
sep <- function(x) {unlist(strsplit(x, ":"))[1]}
name_tot <- apply(name_dup, 1, sep)
npc <- as.numeric(npc)
pc2 <- evec[match(as.matrix(subj), as.matrix(name_tot)), 1:(1+npc)]
pc2[, 1] <- subj
pc2 <- as.data.frame(t(pc2))
rownames(pc2) <- c("ID", paste0("C", seq(npc)))
write.table(pc2, paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpa/pc.txt"), row.names=T, col.names=F, quote=F, sep="\t")

## Sequencing Platform (illumina Hiseq2000(0) or Hiseq X(1)) 
##extract id from annotation file
annotation <- read.delim(Sys.getenv("anno"))
annotation <- as.data.frame(annotation)
sampid_geno <- as.matrix(read.table(paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpg/GTEx.vcf_sample.txt")))
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
}else{
  res <- 1 
}
  return(res)
} 

plat_ind <- apply(as.matrix(plat[match(subj, subj_geno), 2]), 1, get_plat)
plat_ind <- t(cbind(subj, plat_ind))
rownames(plat_ind) <- c("ID", "plat")
write.table(plat_ind, paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpa/plat.txt"), row.names=T, col.names=F, quote=F, sep="\t")


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
write.table(protocol, paste0(Sys.getenv("SIGNET_TMP_ROOT"),"/tmpa/protocol.txt"), row.names=T, col.names=F, quote=F, sep="\t")

explicit_cov_lung <- rbind(sex, as.matrix(plat_ind[-1, ,drop=F]), as.matrix(protocol[-1, ,drop=F]))

write.table(explicit_cov_lung, paste0(Sys.getenv("SIGNET_TMP_ROOT"),"/tmpa/explicit_cov.txt"), row.names=T, col.names=F, quote=F, sep="\t")

