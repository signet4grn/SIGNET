# orderge.R
### Order extracted gene expression data by extracted Geno Sample ID (R)
setwd('../../data/match')
EGexp=read.table('EGexp');
EGexp=as.matrix(EGexp);
EGenoID=read.table('EGenoID');
EGenoID=as.matrix(EGenoID);
L=dim(EGenoID)[1];
idx=matrix(0,L,1);
for (i in 1:L){
  idx[i]=which(EGexp[,1]==EGenoID[i]);
}
MGexp=EGexp[idx,];
write.table(MGexp,'MGexp',quote=F,row.names=F,col.names=F)
