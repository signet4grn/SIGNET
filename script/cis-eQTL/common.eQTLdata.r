### common.eQTLdata.R
### Obtain genotype for eQTL data
#
library(data.table)

args <- commandArgs(TRUE)
eval(parse(text=args))

data=fread("common.Geno.data")
data=as.matrix(data)
sigp=read.table(paste(Sys.getenv("SIGNET_RESULT_ROOT"), "/resc/common.sig.pValue_",alpha,sep=""))
names(sigp)=c("y","x","p")

uniqx=unique(sigp$x)

eQTL=data[,uniqx]
write.table(eQTL,paste(Sys.getenv("SIGNET_RESULT_ROOT"),"/resc/common.eQTL.data", sep=""),row.names=F,col.names=F,quote=F,sep=" ")

lx=nrow(sigp)
newx=matrix(0,lx,1)
for (i in 1:lx){
  newx[i]=which(uniqx==sigp$x[i])
}
sigp$x=newx
write.table(sigp,paste(Sys.getenv("SIGNET_RESULT_ROOT"),"/resc/new.common.sig.pValue_",alpha,sep=""),row.names=F,col.names=F,quote=F,sep=" ")
