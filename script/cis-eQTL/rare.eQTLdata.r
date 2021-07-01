### rare.eQTLdata.R
### Obtain genotype for collapsed cis-eQTL of each gene
#
library(data.table)
args <- commandArgs(TRUE)
eval(parse(text=args))

x <- fread("rare.Geno.data")
x <- as.matrix(x)
sigw <- read.table(paste(Sys.getenv("SIGNET_RESULT_ROOT"), "/resc/rare.sig.weight_",alpha,sep=""))
names(sigw) <- c("y","x","cx","w")

n <- nrow(x)
uniqyx <- unique(paste(sigw$y,sigw$cx))
lyx <- length(uniqyx)
eQTL <- matrix(0,n,lyx)

for (i in 1:lyx){
  widx <- which(paste(sigw$y, sigw$cx)==uniqyx[i])
  eQTL[,i] <- as.matrix(x[,sigw$x[widx]]) %*% sigw$w[widx]
}

write.table(eQTL,paste0(Sys.getenv("SIGNET_RESULT_ROOT"), "/resc/rare.eQTL.data"),row.names=F,col.names=F,quote=F,sep=" ")
