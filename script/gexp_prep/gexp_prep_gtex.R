args <- commandArgs(TRUE)
eval(parse(text=args))

suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(data.table))
##extract id from annotation file
annotation <- read.delim(anno)
annotation <- as.data.frame(annotation)

##extract sample ids from tissue tissue
sampid_tissue <- annotation %>% filter(SMTSD==tissue) %>% select(SAMPID)
sampid_tissue <- as.matrix(sampid_tissue)
##867  

gtex_read <- as.data.frame(fread(reads, header = T, sep = '\t', skip = 2))
gtex_tpm <- as.data.frame(fread(tpm, header = T, sep = '\t', skip = 2))

##first two column:names 

##check if they match
##sum(names(gtex_read)==names(gtex_tpm))
sampid_gct <- names(gtex_read)

##take their intercection
sampid_gexp_tissue <- as.matrix(intersect(sampid_gct, sampid_tissue))
##578 

gen_subj <- function(x){
  first <- unlist(strsplit(x, "-"))[1]
  second <- unlist(strsplit(x, "-"))[2]
  res <- paste(first, second, sep="-")
  return(res)
}

SUBJID <- apply(sampid_gexp_tissue, 1 , gen_subj)
lookup <- cbind(sampid_gexp_tissue, SUBJID)
colnames(lookup) <- c("SAMPID", "SUBJID")

##Truncate to common ones with genotype data 
subjid_common <- as.matrix(read.table("subjid_wb_common.txt"))
##extract the rows mapping the genotype data information
lookup <- lookup[which(SUBJID %in% subjid_common), ]
##482
subjid_tissue <- lookup[, 2]

cat(paste0("There are ", length(unique(subjid_tissue)), " matched samples\n"))
##482

#Causion, output the file for python
write.table(lookup, "lookup_sample_subject_tissue.txt", row.names=F, col.names=T, quote=F, sep="\t")
write.table(lookup[, 1], "sample_ids_tissue.txt", row.names=F, col.names=F, quote=F)
write.table(subjid_tissue, "ordered_subjid_tissue.txt", row.names=F, col.names=F, quote=F)
