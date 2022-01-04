setwd(paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpn/stage2/output"))

eps <- .Machine$double.eps 

library(data.table)
Afiles=list.files(pattern='AdjMat')
##remove original
Afiles <- Afiles[-1]
A=lapply(Afiles,fread)
N=length(A)
N

Afreq <- 0

for (i in 1:N) {
    Afreq=Afreq+as.matrix(A[[i]]/N)
    print(i)
}
fwrite(Afreq, paste0(Sys.getenv("resn"), "_Afreq"), row.names=F,col.names=F)

freq <- c(0.8, 0.85, 0.9, 0.95, 0.98, 0.99, 1)
for(freqi in freq){
  freq_count <- matrix(0, nrow(Afreq), ncol(Afreq))
  freq_count[Afreq > (freqi-eps) ] <- 1
  edge_count <- sum(freq_count)
  node <- which(freq_count!=0, arr.ind=T)
  node_count <- length(unique((c(node[, 1], node[, 2]))))  
  cat(paste0("There are ", node_count, " genes and  ", edge_count, " connections in the network with bootstrap frequency at least ", freqi, "\n")) 
}
