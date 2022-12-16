##This script will combine all the significant cis-eQTLs and create the corresponding gene expression data 
### index of combined eQTL
### comb.sigcis.R
### index of combined eQTL
#
args <- commandArgs(TRUE)
eval(parse(text=args))

library(data.table)
common=read.table(paste0(Sys.getenv("resc"),"_new.common.sig.pValue_", alpha))
if(file.size(paste0(Sys.getenv("resc"),"_low.sig.pValue_", alpha))>0){
low=read.table(paste0(Sys.getenv("resc"),"_low.sig.pValue_", alpha))
}else{
low <- NULL
}
if(file.size(paste0(Sys.getenv("resc"), "_rare.sig.pValue_", alpha))>0){
rare=read.table(paste0(Sys.getenv("resc"),"_rare.sig.pValue_",alpha))
}else{
rare <- NULL
}

# number of common cis-eQTL:
n1 <- as.numeric(system("head -1 ${resc}_common.eQTL.data | tr ' ' '\n' | wc -l",intern=T))
# number of collapsed low-freq cis-eQTL:
n2 <- as.numeric(system("head -1 ${resc}_low.eQTL.data | tr ' ' '\n' | wc -l",intern=T))
# number of collapsed rare cis-eQTL:
n3 <- as.numeric(system("head -1 ${resc}_rare.eQTL.data | tr ' ' '\n' | wc -l",intern=T))

if(! is.null(low)){
low[,2]=(n1+1):(n1+n2)
}
if(! is.null(rare)){
rare[,2]=(n1+n2+1):(n1+n2+n3)
}
all=rbind(common,low,rare)


### obtain expression data for genes with eQTL
data=fread(Sys.getenv("gexp_withpc"))
data=as.matrix(data)
uniqy=unique(all[,1])
netdata=cbind(data[,uniqy],data[,-uniqy])
write.table(netdata,paste0(Sys.getenv("resc"), "_net.gexp.data"),row.names=F,col.names=F,quote=F,sep=" ")

### gene name and gene position
pos=fread(Sys.getenv("gene_pos"))
pos=as.matrix(pos)
name <- pos[, 1]
uniqy=unique(all[,1])

netpos=rbind(pos[uniqy,], pos[-uniqy,])
netname <- c(name[uniqy], name[-uniqy])
cisname <- name[uniqy]

write.table(netpos,paste0(Sys.getenv("resc"), "_net.genepos"),row.names=F,col.names=F,quote=F,sep=" ")
write.table(netname, paste0(Sys.getenv("resc"), "_net.genename"),row.names=F,col.names=F,quote=F,sep=",")
write.table(cisname, paste0(Sys.getenv("resc"), "_cis.name"),row.names=F,col.names=F,quote=F,sep=",")

### index of gene in net.gexp.data
ly=nrow(all)
newy=matrix(0,ly,1)
for (i in 1:ly){
  newy[i]=which(uniqy==all[i,1])
}
all[,1]=newy

### new index of gene and eQTL
write.table(all,paste0(Sys.getenv("resc"), "_all.sig.pValue_", alpha),row.names=F,col.names=F,quote=F,sep=" ")

cat(paste0("There are ", length(unique(all[,1])), " genes\n"))
cat(paste0("There are ", length(unique(all[,2])), " SNPs or SNP regions\n"))
cat(paste0("There are ", nrow(all), " gene-eQTL pairs\n"))
