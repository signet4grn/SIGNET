### grpsnps.R
### Separate SNPs based on minor allele frequency:
###     Rare variants: MAF<0.01
###     Low frequency variants: MAF>=0.01 & MAF<0.05
###     Common variants: MAF>=0.05
map=read.table(Sys.getenv("snps_map"))
map=as.matrix(map)
maf=read.table(Sys.getenv("snps_maf"))
maf=as.matrix(maf)

rareidx=which(maf<0.01)
write.table(paste0("$", rareidx), "rare.snps.idx", row.names=F, col.names=F, quote=F, eol=",")
lowidx=which(maf>=0.01&maf<0.05)
write.table(paste0("$", lowidx), "low.snps.idx", row.names=F, col.names=F, quote=F, eol=",")
commonidx=which(maf>=0.05)
write.table(paste0("$", commonidx), "common.snps.idx", row.names=F, col.names=F, quote=F, eol=",")

raremap=map[rareidx,]
write.table(raremap,"rare.Geno.map",row.names=F,col.names=F,quote=F,sep=" ")
print(paste0("There are ", nrow(raremap), " ultra-low-frequency SNPs"))
lowmap=map[lowidx,]
write.table(lowmap,"low.Geno.map",row.names=F,col.names=F,quote=F,sep=" ")
print(paste0("There are ", nrow(lowmap), " low-frequency SNPs"))
commonmap=map[commonidx,]
write.table(commonmap,"common.Geno.map",row.names=F,col.names=F,quote=F,sep=" ")
print(paste0("There are ", nrow(commonmap), " common SNPs"))
