##preprocess the sample name since it's subject name in vcf file  
name <- read.table("GTEx.vcf_sample0.txt", sep=";")
name[838] <- unlist(strsplit(as.matrix(name[838]), ","))[[1]]
gen_subj <- function(x){
  first <- unlist(strsplit(x, "-"))[1]
  second <- unlist(strsplit(x, "-"))[2]
  res <- paste(first, second, sep="-")
  return(res)
}
subj <- apply(t(as.matrix(name)), 1, gen_subj)
subj_vcf <- read.table("GTEx.vcf_subject.txt")
sum(subj==as.matrix(subj_vcf))
write.table(t(as.matrix(name)), "GTEx.vcf_sample.txt", row.names=F, col.names=F, quote=F)
