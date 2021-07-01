args <- commandArgs(TRUE)
eval(parse(text=args))

upstream=as.numeric(upstream)
downstream=as.numeric(downstream)


size <- file.info("common.SNPpos")$size
if(size==0){
file.create("common.cispair.idx")
quit()
}
# load data
genepos=read.table('genepos');#Column 1 is chr#; Column 2 is start pos; Column 3 is end pos;
SNPpos=read.table('common.SNPpos');#Column 1 is chr#; Column 2 is SNP pos;
ly=dim(genepos)[1];

# index of cis-SNP
cisSNP_idx=list();
for (i in 1:ly) {
	
  cisSNP_idx[[i]]=which((SNPpos[,1]==genepos[i,1])&((genepos[i,2]-downstream)<=SNPpos[,2])&(SNPpos[,2]<=(genepos[i,3]+upstream))); #the same chromosome, down 1kb, down 1kb
  #print(i)
}

# index of gene and its cis-SNP, first column is index of gene, second column is index of SNP
cispair_idx=paste(1,cisSNP_idx[[1]]);
for (i in 2:ly) {
  if (length(cisSNP_idx[[i]]>0)){
    cispair_idx=c(cispair_idx,paste(i,cisSNP_idx[[i]]))
    #print(i)
  }
}
cispair_idx=as.matrix(cispair_idx)

if(length(cisSNP_idx[[1]])==0){
cispair_idx <- cispair_idx[-1, ]
}

write.table(cispair_idx,"common.cispair.idx",row.names=F,col.names=F,quote=F,sep=" ")

