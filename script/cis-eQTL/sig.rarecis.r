### sig.rarecis.R
### Select significant collapsed rare-freq cis-eQTL (p<0.05)
#
args <- commandArgs(TRUE)
eval(parse(text=args))

pval=read.table("rare.theoP")
names(pval)=c("y","cx","p")
sigp=pval[pval$p<alpha,] # significant cis-eQTL
lyx=nrow(sigp) #number of gene&collapsed cis-eQTL pairs

y=unique(sigp$y)
ly=length(y) #number of genes that have cis-eQTL

### check whether genes have unique collapsed cis-eQTL
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
# make sure each gene has a unique collapsed cis-eQTL!

### save p-values and weights for significant collapsed cis-eQTL
sigp$cx <- 1:lyx
write.table(sigp,paste(Sys.getenv("resc"),"_rare.sig.pValue_",alpha,sep=""),row.names=F,col.names=F,quote=F,sep=" ")
write.table(sigw,paste(Sys.getenv("resc"),"_rare.sig.weight_",alpha,sep=""),row.names=F,col.names=F,quote=F,sep=" ")
