setwd("../../data/network")
n <- 90
Nb=50 ## number of bootstrap data sets
set.seed(123)
for (i in 1:Nb){
  idx=sample.int(n,size=n,replace=T) #n is the sample size
  idxname=paste('IDX',as.character(i),sep='')
  write.table(idx,idxname,quote=F,col.names=F,row.names=F)
}
IDX0 <- seq(1, n)
write.table(IDX0,"IDX0",quote=F,col.names=F,row.names=F)
write.table(Nb, "NB.txt", quote=F,row.names=F,col.names=F)
