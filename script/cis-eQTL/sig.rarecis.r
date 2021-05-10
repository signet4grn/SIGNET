### sig.rarecis.R
### Select significant collapsed rare cis-eQTL (p<0.05)
#
pval=read.table("rare.theoP")
names(pval)=c("y","cx","p")
sigp=pval[pval$p<0.05,] # significant cis-eQTL
lyx=nrow(sigp) #number of gene&collapsed cis-eQTL pairs
y=unique(sigp$y)
ly=length(y) #number of genes that have cis-eQTL

### check whether all genes have unique collapsed cis-eQTL
weight <- read.table("rare.ciseQTL.weight")
names(weight) <- c("y","x","cx","w")
sigw <- weight[paste(weight$y,weight$cx)%in%paste(sigp$y,sigp$cx),]
sex=matrix(0,ly,3) #start and end SNP of collapsed cis-eQTL for a gene
sex[,1]=y
for (i in 1:ly){
  sex[i,2]=sigw$x[which(sigw$y==y[i])[1]]
  sex[i,3]=sigw$x[which(sigw$y==y[i])[sum(sigw$y==y[i])]]
}
lx=nrow(unique(sex[,2:3]))
# make sure all genes have at least one unique collapsed cis-eQTL

### save p-values and weights for significant collapsed cis-eQTL
sigp$cx <- 1:lyx
write.table(sigp,"rare.sig.pValue_0.05",row.names=F,col.names=F,quote=F,sep=" ")
write.table(sigw,"rare.sig.weight_0.05",row.names=F,col.names=F,quote=F,sep=" ")
