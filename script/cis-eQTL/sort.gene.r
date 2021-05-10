library(data.table)

setwd("../../")
args=commandArgs(T)
gene_pos_file=args[1]
gexp_file=args[2]

POS=as.data.frame(read.csv(gene_pos_file, header=F)) ##82 genes 
names(POS)=c("gene","chr","start","end")
data=fread(gexp_file)
data=as.matrix(data)

setwd("./data/cis-eQTL")

# remove genes whose size is greater than 2.3Mb
distance=POS$end-POS$start
idx=which(distance<=2.3e6)

POS=POS[idx,] #82 genes
data=data[,idx]

# remove genes which are not on autosomal
idx=which(POS$chr%in%1:22)

POS=POS[idx,] #80 genes
data=data[,idx]

# remove genes whose expression values are constant
idx=which(apply(data,2,sd)!=0)

POS=POS[idx,] #80 genes
data=data[,idx]

# order gene position
idx=order(as.numeric(as.character(POS$chr)), POS$start)

POS=POS[idx,]
data=data[,idx]

## use "," to seperate beacuse some names will take 2 cols
write.table(POS,"final.genePOS",row.names=F,col.names=F,quote=F,sep=",")
write.table(data,"final.gexpdata0",row.names=F,col.names=F,quote=F,sep=" ")
