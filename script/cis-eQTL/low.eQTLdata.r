### low.eQTLdata.R
### Obtain genotype for collapsed cis-eQTL of each gene
#

setwd("../../data/cis-eQTL")
args=commandArgs(T)
alpha=args[1]


x <- read.table("low.snpsdata0")
x <- as.matrix(x)
sigw <- read.table(paste("low.sig.weight_",alpha,sep=""))
names(sigw) <- c("y","x","cx","w")

n <- nrow(x)
uniqyx <- unique(paste(sigw$y,sigw$cx))
lyx <- length(uniqyx)
eQTL <- matrix(0,n,lyx)

for (i in 1:lyx){
  widx <- which(paste(sigw$y, sigw$cx)==uniqyx[i])
  eQTL[,i] <- as.matrix(x[,sigw$x[widx]]) %*% sigw$w[widx]
}

write.table(eQTL,"low.eQTLdata0",row.names=F,col.names=F,quote=F,sep=" ")
