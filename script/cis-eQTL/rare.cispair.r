setwd('../../data/cis-eQTL')
args = commandArgs(T)
upstream = 1000
downstream = 1000
# load data
genepos=read.table('final.genepos');#Column 1 is chr#; Column 2 is start pos; Column 3 is end pos;
SNPpos=read.table('rare.SNPpos');#Column 1 is chr#; Column 2 is SNP pos;
ly=dim(genepos)[1];

# index of cis-SNP
cisSNP_idx=list();
for (i in 1:ly) {
	
  cisSNP_idx[[i]]=which((SNPpos[,1]==genepos[i,1])&((genepos[i,2]-upstream)<=SNPpos[,2])&(SNPpos[,2]<=(genepos[i,3]+downstream))); #the same chromosome, up 1kb, down 1kb
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

write.table(cispair_idx,"rare.cispair.idx",row.names=F,col.names=F,quote=F,sep=" ")

