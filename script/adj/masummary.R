## masummary.R
## Calculate minor allele frequency of each SNP
#
library(data.table)
n <- as.integer(fread("sz")) #n is the sample size
ma <- as.matrix(fread("matched.Geno.ma", header=F))
idx5 <- as.matrix(which(ma>=5))
maf5 <- as.matrix(ma[idx5]/(n*2))

sum(maf5<0.01) #maf<0.01
sum(maf5>=0.01&maf5<0.05) #0.01=<maf<0.05
sum(maf5>=0.05) #maf>=0.05

fwrite(maf5, paste0(Sys.getenv("SIGNET_TMP_ROOT"),"/tmpg/new.Geno.maf"), sep=" ", quote=F, row.names=F, col.names=F)

