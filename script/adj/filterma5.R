## filterma5.R
## Filter out SNPs with minor alleles less than 5
#
library(data.table)
ma=fread("matched.Geno.ma", header=F)
idx5=as.matrix(which(ma>=5))
fwrite(idx5, "snps5.idx", quote=F, sep=" ", col.names=F, row.names=F);
