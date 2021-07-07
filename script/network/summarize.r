setwd(paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpn/stage2/output"))

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
fwrite(Afreq, paste0(Sys.getenv("SIGNET_RESULT_ROOT"), "/resn/Afreq"), row.names=F,col.names=F)

