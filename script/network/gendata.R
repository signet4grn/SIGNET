setwd(paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpn"))
args <- commandArgs(TRUE)
eval(parse(text=args))

n <- as.numeric(system("wc -l < nety", intern=T))

set.seed(123)
for (i in 1:nboots){
  idx=sample.int(n,size=n,replace=T) #n is the sample size
  idxname=paste('IDX',as.character(i),sep='')
  write.table(idx,idxname,quote=F,col.names=F,row.names=F)
}
IDX0 <- seq(1, n)
write.table(IDX0,"IDX0",quote=F,col.names=F,row.names=F)
