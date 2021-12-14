setwd(paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpn"))
args <- commandArgs(TRUE)
eval(parse(text=args))

n <- as.numeric(system("wc -l < nety", intern=T))

system("scp netx netx_back")
system("scp nety nety_back")
system("scp uniqy_idx uniqy_idx_back")
system("scp netyx_idx netyx_idx_back")

suppressMessages(library(dataPreparation))
suppressMessages(library(data.table))
suppressMessages(library(parcor))
suppressMessages(library(MASS))

a <- as.matrix(fread("netx"))
b <- as.matrix(fread("nety"))

##change Zhenyu 06/21/2021
##rewrite netx; for a specific gene in nety, combine all the cis-eqtl in netx with linear combination;if there is only
## one cis-eQTL, use that directly; after the rewrite, netx and nety should have same dimension; 
netyx_idx <- as.matrix(fread("netyx_idx"))
uniqy_idx <- as.matrix(fread("uniqy_idx"))
N=dim(b)[1]
py=length(uniqy_idx)
ypre=matrix(0,N,py)
lambdaseq=seq(0,0.1,0.001)
lambda=matrix(0,py,1)
#coeff=matrix(0,ncpx,py)

cis_idx <- NULL
all_zero_idx <- NULL


for (i in 1: length(uniqy_idx)) {
 cis_idx <- which(netyx_idx[,1] == uniqy_idx[i])
 ncx <- NULL
 coeff <- NULL
 for (j in cis_idx) {
 ncx <- cbind(ncx, a[,j])}
 ncx <- matrix(ncx[,which(apply(ncx,2,sd)!=0)], nrow = n)
 ncolx <- dim(ncx)[2]
 
  if (ncolx==0) {all_zero_idx <- c(all_zero_idx, i)}
 
  if (ncolx==1) {
   # else{
   # fit=ridge.cv(ncx, b[,i],lambda=lambdaseq)
   # lambda[i]=fit$lambda.opt
   # coeff=fit$coefficients
   # ypre[,i]=scale(ncx,center=T,scale=F)%*%coeff+mean(b[,i]) 
   ypre[,i]=ncx
 ##  print(i)
   cis_idx <- NULL
 } 
  if (ncolx >1) {
 fit1=lm.ridge(b[,i]~ncx,lambda=lambdaseq)
 lambda[i]=lambdaseq[which.min(fit1$GCV)]
 coeff=fit1$coef[,which.min(fit1$GCV)]
 ypre[,i]=scale(scale(ncx,center=T,scale=fit1$scales)%*%coeff+mean(b[,i]))
## print(i)
 cis_idx <- NULL
 }} 


a <- ypre
## done with change

cons_id <- NULL

cat("Scan for constant columns in x\n")
for(i in 0:nboots){
  idx <- as.matrix(read.table(paste0("IDX", i)))
  x <- a[idx, ]
  sx <- list()
  sx[[1]] <- x[1:n, ]
  # for(j in 2:length(n)){
  #   sx[[j]] <- x[(sum(n[1:(j-1)])+1):sum(n[1:j]), ]
  # }
  for(k in 1:length(n)){
    cons_id <- c(cons_id, which_are_constant(sx[[k]], verbose=F))
  }
  print(i)
  print(cons_id)
}

if(sum(cons_id)==0){
  cat("There are no constant columns in x\n")
}else{
  cat("We will remove the constant columns in x\n")
}
cons_id <- unique(cons_id)

write.table(cons_id,file='cons_id',row.names=F,col.names=F,quote=F,sep=" ")

cat("Scan for constant columns in y\n")
consy_id <- NULL
for(i in 0:nboots){
  idx <- as.matrix(read.table(paste0("IDX", i)))
  y <- b[idx, ]
  sy <- list()
  sy[[1]] <- y[1:n, ]
  # for(j in 2:length(n)){
  #   sy[[j]] <- y[(sum(n[1:(j-1)])+1):sum(n[1:j]), ]
  # }
  for(k in 1:length(n)){
    consy_id <- c(consy_id, which_are_constant(sy[[k]], verbose=F))
  }
}

if(sum(consy_id)==0){
  cat("There are no constant columns in y\n")
}else{
  cat("We will remove the constant columns in y\n")
}

consy_id <- unique(consy_id)
write.table(consy_id,file='consy_id',row.names=F,col.names=F,quote=F,sep=" ")


##Remove constant columns (here we only have to remove those in X)
if(length(cons_id)>0){
a <- a[, -cons_id]
c <- b[, cons_id]
b <- cbind(b[, -cons_id], c)
}

fwrite(a, file='netx',row.names=F,col.names=F,quote=F,sep=" ")
fwrite(b, file='nety',row.names=F,col.names=F,quote=F,sep=" ")

genepos <- read.table(Sys.getenv("net_genepos"))
genename <- read.table(Sys.getenv("net_genename"))
if(length(cons_id)>0){
genepos <- rbind(genepos[-cons_id, ], genepos[cons_id, ])
genename <- rbind(genename[-cons_id, ,drop=F], genename[cons_id, ,drop=F])
}

back <- fread("netx_back")
uniqy_idx <- as.matrix(1:dim(a)[2])
netyx_idx <- as.matrix(cbind(uniqy_idx, uniqy_idx))

fwrite(genepos, file='net.genepos',row.names=F,col.names=F,quote=F,sep=" ")
fwrite(genename, file='net.genename',row.names=F,col.names=F,quote=F,sep=" ")
fwrite(uniqy_idx, file='uniqy_idx',row.names=F,col.names=F,quote=F,sep=" ")
fwrite(netyx_idx, file='netyx_idx', row.names=F, col.names=F, quote=F, sep=" ")
