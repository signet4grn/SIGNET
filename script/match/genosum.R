## genosum.R
##Calculate the minor allel counts for a chromosome
#
library(data.table)
data <- fread("matched.Geno_chrXXX.data");
ma <- as.matrix(t(colSums(data)))
fwrite(ma, "matched.Geno.ma_chrXXX", sep=" ", quote=F, col.names=F, row.names=F);
