args <- commandArgs(TRUE)
eval(parse(text=args))
library(DESeq2)
library(GenomicRanges)
library(data.table)

print(paste0("preprocessing file", file))

mcounts=fread(file)
geneinfo=mcounts[,1]
#fwrite(mcounts[,1],"gene_id")
mcounts=mcounts[,-1]

#undo the log transformation
mcounts=as.matrix(mcounts)
mcounts=(2^mcounts)-1

# Quality Control: Exclude samples with total counts < 2.5M (NIH Standard)
stcounts <- colSums(mcounts)  # total count of each sample
lowcount.id <- which(stcounts<2500000)
#round the counts into integers
mcounts=round(mcounts)
#mcounts <- mcounts[,-lowcount.id]    
#LUSC and LUAD: none removed

sampleinfo <- matrix(factor(1),nrow=576)
rownames(sampleinfo) <- colnames(mcounts)
colnames(sampleinfo) <- "SampleID"

dds <- DESeqDataSetFromMatrix(countData=mcounts,colData=sampleinfo,design=~1)
gidx <- (rowSums(counts(dds))>(576/5))
dds <- dds[gidx,]
geneinfo <- geneinfo[gidx,]

ge_mad=apply(counts(dds),1,mad)
##remove genes showing no variability
no_v=which(ge_mad>0)
dds=dds[no_v,]
geneinfo <- geneinfo[no_v,]

vsd <- vst(dds,blind=FALSE)


ge <- t(assay(vsd))  # Normalized gene expression

#plots for data exploration:

#plotSparsity(dds,normalized = F)
#plotPCA(vsd,intgroup="SampleID")

#obtain gene position information
write.table(ge, 'Gexp', col.names = F, quote = F)
write.table(geneinfo, 'gene_pos', col.names = F, quote = F)
