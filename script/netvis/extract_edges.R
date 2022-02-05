library(data.table)

eps <- .Machine$double.eps

########################################################
### edge list with gene symbol
Afreq=as.matrix(read.table(Sys.getenv("Afreq"), sep=","))
#threlist=c(0.8,0.9,0.95)
genePOS <- read.table(Sys.getenv("genepos"))
genePOS=as.matrix(genePOS)
freq <- as.numeric(Sys.getenv("freq"))

Coeff=as.matrix(fread(Sys.getenv("coef")))

#for (thre in threlist){
  A=(Afreq > (freq-eps) )
    
  edgeidx=which(A!=0,arr.ind=T)
  target=genePOS[edgeidx[,1],]
  source=genePOS[edgeidx[,2],]
  
  edgefreq=Afreq[edgeidx]
  edgecoeff=Coeff[edgeidx]

  edgelist_genesymbol=cbind(source,target,edgefreq,edgecoeff) #Col 1-4 is source, Col 5-8 is target, Col 9 is frequency

  write.table(edgelist_genesymbol,paste0(Sys.getenv("resv"), "_edgelist_",freq),row.names=F,col.names=c("source_gene_symbol","source_chr","source_start","source_end","target_gene_symbol","target_chr","target_start","target_end","frequency","coefficient"),quote=F,sep=",")
#}

