
### Predict y using x in Stage 1, Ridge Regression  
### Screening and variable selection for y(i) on y(-i) hat in Stage 2

setwd('../../data/network')
### load data
library(data.table)
y=fread("nety") #expression data for all genes
y=as.matrix(y)
x=fread("netx") #cis-eQTL data
x=as.matrix(x)
netyx_idx=read.table("netyx_idx") #Col 1 is index of gene, Col 2 is index of corresponding cis-eQTL
netyx_idx=as.matrix(netyx_idx)
y=y[,1:20]
##change 
uniqy_idx=read.table("uniqy_idx")
##change2
py1 = dim(uniqy_idx)[1]
if(20 > py1){
  stop("Please reset 20")
}
N=dim(y)[1]
py=dim(y)[2]
px=dim(x)[2]
library(MASS)


### index of instruments for each gene
y_idx=unique(netyx_idx[,1]) #unique index of gene
y_idx=y_idx[1:20]
IV_idx=list()
for (i in 1:py){
  IV_idx[[i]]=netyx_idx[which(netyx_idx[,1]==y_idx[i]),2] #index of cis-eQTL (IV) for each gene
}

### Bootstrap
idx=read.table('IDX50')
idx=as.matrix(idx)
y=y[idx,]
x=x[idx,]

### Stage 1: prediction for y using x (after removing constant columns)

### remove constant columns in x
ncx=x[,which(apply(x,2,sd)!=0)]
ncpx=dim(ncx)[2]

### Ridge Regression; CV to select # of components 
lambda=matrix(0,py,1)
coeff=matrix(0,ncpx,py)
ypre=matrix(0,N,py)
lambdaseq=seq(0,0.1,0.001)
for (i in 1:py) {
  fit=lm.ridge(y[,i]~ncx,lambda=lambdaseq)
  lambda[i]=lambdaseq[which.min(fit$GCV)]
  coeff[,i]=fit$coef[,which.min(fit$GCV)]
  ypre[,i]=scale(ncx,center=T,scale=fit$scales)%*%coeff[,i]+mean(y[,i]) 
  print(i)  
}

write.table(ypre,file='./stage1/ypre50_1-20',row.names=F,col.names=F,quote=F,sep=" ")
