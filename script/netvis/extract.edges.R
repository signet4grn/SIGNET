library(data.table)

args <- commandArgs(TRUE)
eval(parse(text=args))

########################################################
### edge list with gene symbol
Afreq=as.matrix(fread("Afreq"))
#threlist=c(0.8,0.9,0.95)
genePOS <- read.table(paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpv/net.genepos"))
genePOS=as.matrix(genePOS)

Coeff=as.matrix(fread(paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpn/stage2/output/CoeffMat0")))

#for (thre in threlist){
  A=(Afreq>=freq)
    
  edgeidx=which(A!=0,arr.ind=T)
  target=genePOS[edgeidx[,1],]
  source=genePOS[edgeidx[,2],]

  edgefreq=Afreq[edgeidx]
  edgecoeff=Coeff[edgeidx]

  edgelist_genesymbol=cbind(source,target,edgefreq,edgecoeff) #Col 1-4 is source, Col 5-8 is target, Col 9 is frequency

  write.table(edgelist_genesymbol,paste0(Sys.getenv("SIGNET_RESULT_ROOT"), "/resv/edgelist_",freq),row.names=F,col.names=c("source_gene_symbol","source_chr","source_start","source_end","target_gene_symbol","target_chr","target_start","target_end","frequency","coefficient"),quote=F,sep=" ")
#}
