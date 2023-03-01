
### Predict y using x in Stage 1, Ridge Regression  
### Screening and variable selection for y(i) on y(-i) hat in Stage 2
### load data
library(MASS)
library(data.table)
netyfile <- list.files(path="/SIGNET", pattern="nety", full.names=T)[1]
if(length(netyfile) > 0){
y=fread(netyfile) #expression data for all genes
}else{
cat("The nety file doesn't exist")
}
y=as.matrix(y)
netxfile <- list.files(path="/SIGNET", pattern="netx", full.names=T)[1]
if(length(netxfile) > 0){
x=fread(netxfile) #cis-eQTL data
}else{
cat("The netx file doesn't exist")
}
x=as.matrix(x)
netyx_idxfile <- list.files(path="/SIGNET", pattern="netyx_idx", full.names=T)[1]
if(length(netyx_idxfile) > 0){
netyx_idx=read.table(netyx_idxfile) #Col 1 is index of gene, Col 2 is index of corresponding cis-eQTL
}else{
cat("The netyx_idx file doesn't exist")
}

netyx_idx <- as.matrix(nety_idx)
y=y[,YYfirstYY:YYlastYY]
##change 
uniqy_idxfile <- list.files(path="/SIGNET", pattern="uniqy_idx", full.names=T)[1]
if(length(uniqy_idxfile)>0){
uniqy_idx=read.table(uniqy_idxfile)
}else{
cat("The uniqy_idx file doesn't exist")
}
##change2
py1 = dim(uniqy_idx)[1]
if(YYlastYY > py1){
  stop("Please reset YYlastYY")
}
N=dim(y)[1]
py=dim(y)[2]
px=dim(x)[2]


### index of instruments for each gene
y_idx=unique(netyx_idx[,1]) #unique index of gene
y_idx=y_idx[YYfirstYY:YYlastYY]
IV_idx=list()
for (i in 1:py){
  IV_idx[[i]]=netyx_idx[which(netyx_idx[,1]==y_idx[i]),2] #index of cis-eQTL (IV) for each gene
}

### Bootstrap
idxfile <- list.files(path="/SIGNET", pattern="IDXXXbsXX$", full.names=T)[1]
if(length(idxfile) > 0){
idx=read.table(idxfile)
}else{
cat("The idx file doesn't exist")
}
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

write.table(ypre,file='/SIGNET/ypreXXbsXX_YYfirstYY-YYlastYY',row.names=F,col.names=F,quote=F,sep=" ")
