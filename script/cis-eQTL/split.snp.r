

args=commandArgs(T)
map_file=args[1]
maf_file=args[2]

setwd("../../")
map=read.table(map_file)
map=as.matrix(map)
maf=read.table(maf_file)
maf=as.matrix(maf)

setwd("./data/cis-eQTL")

rareidx=which(maf<0.01)
write.table(paste0("$", rareidx), "rare.snps.idx", row.names=F, col.names=F, quote=F, eol=",")
lowidx=which(maf>=0.01&maf<0.05)
write.table(paste0("$", lowidx), "low.snps.idx", row.names=F, col.names=F, quote=F, eol=",")
commonidx=which(maf>=0.05)
write.table(paste0("$", commonidx), "common.snps.idx", row.names=F, col.names=F, quote=F, eol=",")

raremap=map[rareidx,]
write.table(raremap,"rare.snps.map",row.names=F,col.names=F,quote=F,sep=" ")
lowmap=map[lowidx,]
write.table(lowmap,"low.snps.map",row.names=F,col.names=F,quote=F,sep=" ")
commonmap=map[commonidx,]
write.table(commonmap,"common.snps.map",row.names=F,col.names=F,quote=F,sep=" ")
