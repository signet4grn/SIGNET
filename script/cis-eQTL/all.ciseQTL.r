setwd("../../data/cis-eQTL")
library(data.table)

args = commandArgs(T)
alpha = args[1]

############################################################
### index of combined eQTL
n1=44
n2=3

common=read.table(paste("new.common.sig.pValue_",alpha,sep=""))
low=read.table(paste("low.sig.pValue_",alpha,sep=""))
low[,2]=(n1+1):(n1+n2)
all=rbind(common,low)

############################################################
### obtain expression data for genes with eQTL
data=fread("final.gexpdata0")
data=as.matrix(data)

uniqy=unique(all[,1])

############################################################
### index of gene in net.gexp.data

ly=nrow(all)
newy=matrix(0,ly,1)
for (i in 1:ly){
  newy[i]=which(uniqy==all[i,1])
}
all[,1]=newy

### new index of gene and eQTL
length(unique(all[,1])) 
#20 genes
length(unique(all[,2]))
#47  SNPs
nrow(all) 
#47 gene-eQTL pairs
write.table(all,paste("all.sig.pValue_",alpha,sep=""),row.names=F,col.names=F,quote=F,sep=" ")
