### snps5.R
### Generate a map file for SNPs with >=5 minor alleles
#
setwd('../../data/match')
map=read.table("clean_Genotype.map")
map=as.matrix(map)
idx5=read.table("snps5.idx")
idx5=as.matrix(idx5)

map5=map[idx5,]
write.table(map5,"new.Geno.map",row.names=F,col.names=F,quote=F,sep=" ")

dataidx5=c(1,idx5+1)
write.table(paste0("$", dataidx5), "new.Geno.idx", row.names=F, col.names=F, quote=F, eol=",")
