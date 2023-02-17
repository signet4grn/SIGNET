#
### Predict y using x in Stage 1, Ridge Regression  
### Screening and variable selection for y(i) on y(-i) hat in Stage 2
args <- commandArgs(TRUE)
eval(parse(text=args))

memory <- as.numeric(memory)
ncores <- as.numeric(ncores)

### load data
suppressMessages(library(data.table))
suppressMessages(library(MASS))
suppressMessages(library(parcor))
suppressMessages(library(matrixcalc))
library(chron)

y=fread("nety") #expression data for genes
y=as.matrix(y)
x=fread("netx") #cis-eQTL data
x=as.matrix(x)
netyx_idx=read.table("netyx_idx") #Col 1 is index of gene, Col 2 is index of corresponding cis-eQTL
netyx_idx=as.matrix(netyx_idx)
y=y[, 1:10]
##change2
py1 = length(unique(netyx_idx[,1]))
N=dim(y)[1]
py=dim(y)[2]
px=dim(x)[2]

source(paste0(Sys.getenv("SIGNET_SCRIPT_ROOT"), "/network/SIS.R"))
source(paste0(Sys.getenv("SIGNET_SCRIPT_ROOT"), "/network/subfuns.R"))

##ptm <- proc.time()
##change
##change2
y_idx <- c()
if(py1 >= 1){
  y_idx=unique(netyx_idx[,1]) #unique index of gene
  y_idx=y_idx[1:min(10, py1)]
  IV_idx=list()
  for (i in 1:length(y_idx)){
    IV_idx[[i]]=netyx_idx[which(netyx_idx[,1]==y_idx[i]),2] #index of cis-eQTL (IV) for each gene
  }
}

### Bootstrap
idx=read.table('IDX1')
idx=as.matrix(idx)
y=y[idx,]
x=x[idx,]


### predicted y 
#ypre_file <- list.files(path="stage1/output", pattern="ypre1", full.names=T)
#if(length(ypre_file) > 0){
#ypre <- read.table(ypre_file[1])
#}else{
#cat("The ypre file doesn't exists")
#quit()
#}
print(list.files())
ypre=as.matrix(ypre[,1:py1])
nypre=dim(ypre)[2]


### Stage 2: screening and variable selection for y(-i) hat, its instrument is always in the model

### threshold for tuning parameter in SIS
nsis = floor(N/log(N))

### screening and variable selection for y(-i) hat, its instrument is always in the model
ynew=matrix(0,N,py)
iy=list() 
cy=list()
elapse <- NULL
##change
if(py1 >= 1){
  ##change3: iterate from 1 to num of cis-eQTL genes
  for(i in 1:length(y_idx)){
    ### transform the problem into adaptive lasso problem
    st <- proc.time()
    cb=IV_idx[[i]] #index of cis-eQTL for the i-th y in ncy 
    xi=x[,cb]
    xi=as.matrix(xi)
    xi=xi[,which(apply(xi,2,sd)!=0)] #remove constant columns
    xi=as.matrix(xi)
    xi=scale(xi) 
    xi=as.matrix(xi)
    nxi=dim(xi)[2]
    while (nxi>1 & is.singular.matrix(t(xi)%*%xi)){
      xi=xi[,-1]
      nxi=nxi-1
    } #remove one column if t(xi)%*%xi is singular
   #xi=xi[,!duplicated(round(abs(xi),8),MARGIN=2)] #remove one of two columns which have perfect linear correlation

    if (nxi>0){    
      Pi=diag(N)-xi%*%solve(t(xi)%*%xi)%*%t(xi)
      y[,i]=scale(y[,i])
      ynew[,i]=Pi%*%y[,i]
      ynew[,i]=scale(ynew[,i])
      yprenewi=Pi%*%ypre[,-(1-1+i)]
      yprenewi=scale(yprenewi)
      ##tmpy=yprenewi[,-(1-1+i)]

      output=SIS(yprenewi,ynew[,i],family="gaussian",penalty="adalasso",nsis=nsis,iter=F)
      iy[[i]]=sort(output$ix)
      cy[[i]]=output$cx
      print(i)
      elapse <- c(elapse, proc.time() - st)
    }
  }
}




if(py1 < 10){
  ##change3: iterates from the first gene that is not a ciseqtl to the end 
  for(i in (length(y_idx)+1):py){
    ynew[,i]=scale(y[,i])
    yprenewi=scale(ypre)
    
    output=SIS(yprenewi,ynew[,i],family="gaussian",penalty="adalasso",nsis=nsis,iter=F)
    iy[[i]]=sort(output$ix)
    cy[[i]]=output$cx
    print(i)
  }
}



##change
##change2

##change3 move this to before if statement
estimatedA=matrix(0, py, py1)

if(py1 >= 1){
  ### estimated adjacency matrix in ncy
  
  ##change3
  for (i in 1:length(y_idx)) {
    ##change2 change estimatedB
    estimatedB <- matrix(0, 1, (py1-1))
    ##change3
    estimatedB[iy[[i]]] = 1
    estimatedA[i,-(1-1+i)]=estimatedB
  }
}
if(py1 < 10){
  ##change3
  for(i in (length(y_idx)+1):py){
    estimatedA[i,iy[[i]]] = 1
  }
}

##change3
estimatedC=matrix(0, py, py1)


##change2
if(py1 >= 1){
  ### estimated coefficient matrix in ncy
  
  
  for (i in 1:length(y_idx)) {
    ##change2 change estimatedD
    estimatedD=matrix(0, 1, (py1-1))
    ##change3
    estimatedD[iy[[i]]] <- cy[[i]]
    estimatedC[i,-(1-1+i)]=estimatedD
    }
}

if(py1 < 10){
  for(i in (length(y_idx)+1):py){
    estimatedC[i,iy[[i]]] = cy[[i]]
  }
}

maxlap <- max(elapse)
maxmem <- gc()[2, 6]/1024

cat(paste0("The maximum calculation time for Stage 2 is about ", round(maxlap, digit=3), "s for one gene\n"))
cat(paste0("The largest memory used in the process is ", maxmem, "GB\n"))
if(maxmem*ncores>memory){
cat(paste0("Please reset the ncores parameter to less than ", floor(memory/maxmem), "\n"))
}

a <- chron(time=walltime, format=c(times="h:m:s"))
gene_trunk <- floor(0.5*(3600*hours(a)+60*minutes(a)+seconds(a))/maxlap)
cat(paste0("We will include ", min(gene_trunk, ncol(y)), " genes in one script\n"))

write.table(gene_trunk, file="gene_trunk_stage2", row.names=F, col.names=F, quote=F, sep=" ")

### save results and all objects
write.table(estimatedA,'AdjMat1_1-10',row.names=F,col.names=F,quote=F,sep=" ")
write.table(estimatedC,'CoeffMat1_1-10',row.names=F,col.names=F,quote=F,sep=" ")
