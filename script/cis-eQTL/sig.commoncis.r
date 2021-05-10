setwd("../../data/cis-eQTL")
pval=read.table("common.pValue")
names(pval)=c("y","x","p")
args=commandArgs(T)
alpha=args[1]

sigp=pval[pval$p<alpha,] # significant cis-eQTL
lyx=nrow(sigp) # number of gene&cis-eQTL pairs
##4316
y=unique(sigp$y)
ly=length(y) # number of genes that have cis-eQTL
##2019
x=unique(sigp$x)
lx=length(x) # number of SNPs that are cis-eQTL of certain genes
##4298

tablex=as.data.frame(table(sigp$x))
uniqx=tablex[tablex$Freq==1,1]
lux=length(uniqx) #number of SNPs that are cis-eQTL of only one gene
##4280

ind=matrix(0,ly,1)
for (i in 1:ly){
  ind[i]=sum(sigp$x[sigp$y==unique(sigp$y)[i]] %in% uniqx)
}
uniqy=y[ind!=0]
luy=length(uniqy) # number of genes that have at least one unique cis-eQTL
##2000

### p-value for genes that have at least one unique cis-eQTL
uniqsigp=sigp[sigp$y%in%uniqy,]
write.table(uniqsigp,paste("common.sig.pValue_",alpha,sep=""),row.names=F,col.names=F,quote=F,sep=" ")
