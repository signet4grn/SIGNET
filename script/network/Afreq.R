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
fwrite(Afreq,'Afreq',row.names=F,col.names=F)


########################################################

### number of edges with bootstrap frequency > thre
Afreq=as.matrix(fread('Afreq'))
threlist=c(0.8,0.9,0.95,1)
Afreq <- round(Afreq, 3)

for (thre in threlist){
  A=(Afreq>=thre)
  print(sum(A))
}


thre=0.8: 27594
thre=0.9: 12776
thre=0.95: 7017
thre=1: 2557

########################################################
### edge list with gene symbol
library(data.table)
Afreq=as.matrix(fread('Afreq'))
Afreq <- round(Afreq, 3)
threlist=c(0.8,0.9,0.95,1)
len=length(thre)

genename <- read.table("net.genename", sep="\t")
gtf <- read.delim("gencode.v26.GRCh38.genes.gtf", comment.char="#", as.is=TRUE, header=FALSE)

##sort by gene_comb
gene_gtf <- gtf[gtf$V3=="gene", ]
gene_id <- sapply(gene_gtf$V9, function(x)(strsplit(x, split=" ")[[1]][2]), USE.NAMES=FALSE)
gene_id <- sapply(gene_id, function(x)(strsplit(x, split=";")[[1]][1]), USE.NAMES=FALSE)
gene_name <- sapply(gene_gtf$V9, function(x)(strsplit(x, split=" ")[[1]][8]), USE.NAMES=FALSE)
genename <- gene_name[match(as.matrix(genename), gene_id)]
genename <- sapply(genename, function(x)(strsplit(x, split=";")[[1]][1]), USE.NAMES=F)

genepos <- read.table("net.genepos")
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

  write.table(edgelist_genesymbol,paste0("edgelist_",thre),row.names=F,col.names=c("source_gene_symbol","source_chr","source_start","source_end","target_gene_symbol","target_chr","target_start","target_end","frequency","coefficient"),quote=F,sep=",")
}
