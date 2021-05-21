library('data.table')
setwd("../../data/network/stage2/res")

Afiles=list.files(pattern='AdjMat')
##remove original
Afiles <- Afiles[-1]
A=lapply(Afiles,fread)
N=length(A)
N

Afreq=0
for (i in 1:N) {
    Afreq=Afreq+as.matrix(A[[i]]/N)
    print(i)
}
write.table(Afreq,'Afreq',row.names=F,col.names=F)

########################################################
### edge list with gene symbol
#Afreq=as.matrix(fread('Afreq'))
threlist=c(0.8,0.9,0.95)

genename <- read.table("../../../cis-eQTL/net.genename", sep="\t")
genepos <- read.table("../../../cis-eQTL/net.genepos")
genePOS <- cbind(genename, genepos)
genePOS=as.matrix(genePOS)

Coeff=as.matrix(fread("CoeffMat0"))

for (thre in threlist){
  A=(Afreq>=thre)
    
  edgeidx=which(A!=0,arr.ind=T)
  target=genePOS[edgeidx[,1],]
  source=genePOS[edgeidx[,2],]

  edgefreq=Afreq[edgeidx]
  edgecoeff=Coeff[edgeidx]

  edgelist_genesymbol=cbind(source,target,edgefreq,edgecoeff) #Col 1-4 is source, Col 5-8 is target, Col 9 is frequency

  write.table(edgelist_genesymbol,paste0("edgelist_",thre),row.names=F,col.names=c("source_gene_symbol","source_chr","source_start","source_end","target_gene_symbol","target_chr","target_start","target_end","frequency","coefficient"),quote=F,sep=" ")
}
