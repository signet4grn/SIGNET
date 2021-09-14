## genosum.R
##Calculate the minor allel counts for a chromosome
#
library(data.table)
data <- fread("matched.Geno_chr1.data");
ma <- as.matrix(t(colSums(data)))
fwrite(ma, "matched.Geno.ma_chr1", sep=" ", quote=F, col.names=F, row.names=F);
