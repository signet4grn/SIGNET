### common.eQTLdata.R
### Obtain genotype for eQTL data
#
.libPaths(c("/depot/bigcare/data/2020/Rlibs","~/R/x86_64-pc-linux-gnu-library/3.6",.libPaths()))
setwd("../../data/cis-eQTL")

library(data.table)

args=commandArgs(T)
alpha=args[1]

data=fread("common.snpsdata0")
data=as.matrix(data)
sigp=read.table(paste("common.sig.pValue_",alpha,sep=""))
names(sigp)=c("y","x","p")

uniqx=unique(sigp$x)

eQTL=data[,uniqx]
write.table(eQTL,"common.eQTLdata0",row.names=F,col.names=F,quote=F,sep=" ")

lx=nrow(sigp)
newx=matrix(0,lx,1)
for (i in 1:lx){
  newx[i]=which(uniqx==sigp$x[i])
}
sigp$x=newx
write.table(sigp,paste("new.common.sig.pValue_",alpha,sep=""),row.names=F,col.names=F,quote=F,sep=" ")
