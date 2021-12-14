args <- commandArgs(TRUE)
eval(parse(text=args))

library(data.table)
### input files
##change
y <- as.matrix(fread(Sys.getenv("net_gexp")))
x <- fread(Sys.getenv("net_geno")); #genotype data
res <- read.table(Sys.getenv("sig_pair")) 
y=as.matrix(y);
x=as.matrix(x);
res=as.matrix(res);

y_idx=res[,1]; #index of gene
uniqy_idx=unique(y_idx); #index of unique gene
ly=length(uniqy_idx);
x_idx=list();
for (i in 1:ly){
  x_idx[[i]]=res[which(res[,1]==uniqy_idx[i]),2] #index of cis-eQTL for each gene
}
pval=list();
for (i in 1:ly){
  pval[[i]]=res[which(res[,1]==uniqy_idx[i]),3] #p value of cis-eQTL for each gene
}

uncorx_idx=list(); #index of uncorrelated cis-eQTL (up to 3) for each gene
#idx1: index of the most significant cis-eQTL for each gene in x_idx (in 1st run)
#idx2: index of the most significant cis-eQTL for each gene in x_idx1 (in 2nd run)
#idx3: index of the most significant cis-eQTL for each gene in x_idx2 (in 3rd run)
#uncorx_idx1: index of the most significant cis-eQTL for each gene (in 1st run)
#uncorx_idx2: index of the most significant cis-eQTL for each gene (in 2nd run)
#uncorx_idx3: index of the most significant cis-eQTL for each gene (in 3rd run)
x_cor1=list(); #correlation between cis-eQTL for each gene (after 1st run)
x_cor2=list(); #correlation between cis-eQTL for each gene (after 2nd run)
x_idx1=list(); #index of cis-eQTL for each gene (after 1st run)
x_idx2=list(); #index of cis-eQTL for each gene (after 2nd run)
pval1=list(); #p value of cis-eQTL (after 1st run)
pval2=list(); #p value of cis-eQTL (after 2nd run)
rmlist=NULL; #list of cis-eQTL to be removed, remove cis-eQTL which are already selected by previous genes


########################################
### index of uncorrelated cis-eQTL (up to 3) for each gene
for (i in 1:ly){
  rmidx=which(x_idx[[i]] %in% rmlist) #idx of cis-eQTL to be removed
  #remove cis-eQTL which are already selected by previous genes
  if (length(rmidx)>0){
    x_idx[[i]]=x_idx[[i]][-rmidx]
    pval[[i]]=pval[[i]][-rmidx]
  }
  
  #if gene has only one cis-eQTL
  if (length(x_idx[[i]])==1){
    uncorx_idx[[i]]=x_idx[[i]]; #index of uncorrelated cis-eQTL
  } else{ 
    idx1=which(pval[[i]]==min(pval[[i]]))[1]; #index of the most significant cis-eQTL in x_idx (in 1st run)
    uncorx_idx1=x_idx[[i]][idx1]; #index of the most significant cis-eQTL (in 1st run)
    x_cor1[[i]]=cor(x[,x_idx[[i]]]); #correlation between cis-eQTL (after 1st run)
    x_idx1[[i]]=x_idx[[i]][abs(x_cor1[[i]][idx1,])<=r]; #index of cis-eQTL (after 1st run)
    pval1[[i]]=pval[[i]][abs(x_cor1[[i]][idx1,])<=r]; #result of cis-eQTL (after 1st run) 
    
    #if gene has no cis-eQTL after first run
    if (length(x_idx1[[i]])==0){      
      uncorx_idx[[i]]=uncorx_idx1; #index of uncorrelated cis-eQTL 
    } else if (length(x_idx1[[i]])==1){ #if gene has one cis-eQTL after first run 
      uncorx_idx[[i]]=c(uncorx_idx1,x_idx1[[i]]); #index of uncorrelated cis-eQTL
    } else{ 
      idx2=which(pval1[[i]]==min(pval1[[i]]))[1]; #index of the most significant cis-eQTL in x_idx1 (in 2nd run)
      uncorx_idx2=x_idx1[[i]][idx2]; #index of the most significant cis-eQTL (in 2nd run)
      x_cor2[[i]]=cor(x[,x_idx1[[i]]]); #correlation between cis-eQTL (after 2nd run)
      x_idx2[[i]]=x_idx1[[i]][abs(x_cor2[[i]][idx2,])<=r]; #index of cis-eQTL (after 2nd run)
      pval2[[i]]=pval1[[i]][abs(x_cor2[[i]][idx2,])<=r]; #result of cis-eQTL (after 2nd run) 
      
      #if gene has no cis-eQTL after 2nd run
      if (length(x_idx2[[i]])==0){
        uncorx_idx[[i]]=c(uncorx_idx1,uncorx_idx2); #index of uncorrelated cis-eQTL 
      } else if (length(x_idx2[[i]])==1){
        uncorx_idx[[i]]=c(uncorx_idx1,uncorx_idx2,x_idx2[[i]]); #index of uncorrelated cis-eQTL 
      } else{ 
        idx3=which(pval2[[i]]==min(pval2[[i]]))[1]; #index of the most significant cis-eQTL in x_idx2 (in 3rd run)
        uncorx_idx3=x_idx2[[i]][idx3]; #index of the most significant cis-eQTL (in 3rd run)
        uncorx_idx[[i]]=c(uncorx_idx1,uncorx_idx2,uncorx_idx3);
      }
    }  
  }
  rmlist=unlist(uncorx_idx[1:i]) #list of cis-eQTL to be removed, remove cis-eQTL which are already selected by previous genes
}
uncory_idx=list(); #index of gene with uncorrelated cis-eQTL
for (i in 1:ly){
  uncory_idx[[i]]=rep(uniqy_idx[i],length(uncorx_idx[[i]]))
}

uncoryx_idx=paste(unlist(uncory_idx),unlist(uncorx_idx)) #index of gene and its uncorrelated cis-eQTL
uncoryx_idx=as.matrix(uncoryx_idx)

setwd(paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpn"))
write.table(uncoryx_idx,"uncoryx_idx",row.names=F,col.names=F,quote=F,sep=" ")

########################################
### index of gene and cis-eQTL in network data
uncoryx_idx=read.table("uncoryx_idx")
uncoryx_idx=as.matrix(uncoryx_idx)
uncory_idx=uncoryx_idx[,1] #index of gene
uncorx_idx=uncoryx_idx[,2] #index of cis-eQTL

uniqy_idx=unique(uncoryx_idx[,1]) #unique index of gene
uniqx_idx=unique(uncoryx_idx[,2]) #unique index of cis-eQTL
write.table(uniqy_idx,"uniqy_idx",row.names=F,col.names=F,quote=F,sep=" ")
write.table(uniqx_idx,"uniqx_idx",row.names=F,col.names=F,quote=F,sep=" ")


nety=cbind(y[, uniqy_idx], y[, -uniqy_idx]) #network gene expression data
netx=x[, uniqx_idx] #network cis-eQTL data
write.table(nety,"nety",row.names=F,col.names=F,quote=F,sep=" ")
write.table(netx,"netx",row.names=F,col.names=F,quote=F,sep=" ")

lx=length(uncorx_idx)
netyx_idx=matrix(0,lx,2)
for (i in 1:lx){
  netyx_idx[i,1]=which(uniqy_idx==uncory_idx[i]) #index of gene in network gene data
  netyx_idx[i,2]=which(uniqx_idx==uncorx_idx[i]) #index of cis-eQTL in network cis-eQTL data
}
write.table(netyx_idx,"netyx_idx",row.names=F,col.names=F,quote=F,sep=" ")

### check whether each gene has a unique cis-eQTL & how many genes have one/two/three cis-eQTL
netyx_idx=read.table("netyx_idx")
netyx_idx=as.matrix(netyx_idx)
uniq_nety_idx=unique(netyx_idx[,1])
len=length(uniq_nety_idx)
indicator=matrix(0,len,1)
for (i in 1:len){
   indicator[i]=(sum(!(netyx_idx[which(netyx_idx[,1]==uniq_nety_idx[i]),2]%in%netyx_idx[which(netyx_idx[,1]!=uniq_nety_idx[i]),2]))>=1) #1 if the gene has at least one unique cis-eQTL
}

cat(paste0(sum(table(netyx_idx[,1])==1), " genes have one cis-eQTL\n"))
cat(paste0(sum(table(netyx_idx[,1])==2), " genes have two cis-eQTL\n"))
cat(paste0(sum(table(netyx_idx[,1])==3), " genes have three cis-eQTL\n"))

