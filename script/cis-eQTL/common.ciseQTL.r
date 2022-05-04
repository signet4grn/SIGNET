### common.ciseQTL.R
### Calculate p-values of all common cis-eQTL
#
library(data.table)
y=fread(Sys.getenv("gexp"))
x=fread('common.Geno.data')
y=as.matrix(y)
x=as.matrix(x)
y=scale(y)
x=scale(x)
idx=read.table('common.cispair.idx')
len=dim(idx)[1]

p=matrix(0,len,1)
for (i in 1:len){
  if(any(is.nan(x[,idx[i,2]])))
    p[i] <- 1
  else {
    fit=lm(y[,idx[i,1]]~x[,idx[i,2]])
    p[i]=summary(fit)$coefficients[2,4]
  }
  if( (i%%10000)==0)  print(i)
}

p=cbind(idx,p) # Col 1 is index of gene, Col 2 is index of its cis-SNP, Col 3 is p-value
write.table(p,"common.pValue",row.names=F,col.names=F,quote=F,sep=" ")
