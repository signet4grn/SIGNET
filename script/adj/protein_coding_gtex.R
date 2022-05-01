
##Filter and order genes 
library(data.table)
library(rtracklayer)
print(Sys.getenv("gtf"))
gtf <- rtracklayer::import(Sys.getenv("gtf"))
gtf <- as.data.frame(gtf)
gtf[, 1] <- substring(gtf[, 1], 4)

data_rmpc <- as.matrix(fread("tmp_rmpc.gexp.data"))

data <- as.matrix(fread("tmp.gexp.data"))

gexp1 <- fread(paste0(Sys.getenv("rest"), "_expression_normalized_igt2log_GTEx_", Sys.getenv("tissue"), ".expression.bed.gz")) # gene by sample
POS <- gexp1[, c(1:4)]
names(POS) <-c("chr","start","end","gene")

gtf_cut <- gtf[which(gtf$gene_id %in% as.matrix(POS[, 4])), ]
idx_pc <- (gtf_cut[ ,12]=="protein_coding")&(gtf_cut[ ,7]=="gene")

#ensembl id
#POS <- unique(gtf_cut[idx_pc, c(10, 1, 2, 3)])
#gene name
POS <- unique(gtf_cut[idx_pc, c(13, 1, 2, 3)])
names(POS) <- c("gene","chr","start","end")
##16762 protein coding genes

data <- data[, match(as.matrix(POS[, 1]), as.matrix(gexp1[, 4]))]
data_rmpc <- data_rmpc[, match(as.matrix(POS[, 1]), as.matrix(gexp1[, 4]))]

# remove genes whose size is greater than 2.3Mb
distance=POS$end-POS$start
idx <- which(distance<=2.3e6)

POS <- POS[idx,] #16761 genes left
POS[, 2] <- paste0("chr", POS[, 2])
data <- data[,idx]
data_rmpc <- data_rmpc[, idx]

fwrite(POS, paste0(Sys.getenv("resa"), "_gene_pos"),row.names=F,col.names=F,quote=F,sep=" ")
fwrite(data, paste0(Sys.getenv("resa"), "_gexp.data"),row.names=F,col.names=F,quote=F,sep=" ")
fwrite(data_rmpc, paste0(Sys.getenv("resa"), "_gexp_rmpc.data"),row.names=F,col.names=F,quote=F,sep=" ")
