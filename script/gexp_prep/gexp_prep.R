args <- commandArgs(TRUE)
eval(parse(text=args))

suppressPackageStartupMessages(library(DESeq2))
suppressPackageStartupMessages(library(GenomicRanges))
suppressPackageStartupMessages(library(data.table))

mcounts=fread(file)

##remove last 5 rows
mcounts=head(mcounts, -5)

cat(paste0("Preprocessing gene expression file: ", file, "\n"))


geneinfo=mcounts[,1]
#fwrite(mcounts[,1],"gene_id")
mcounts=mcounts[,-1]

mcounts=round(2^mcounts-1)

# Quality Control: Exclude samples with total counts < 2.5M (NIH standard)
stcounts <- colSums(mcounts)  # total count of each sample
lowcount.id <- which(stcounts<2500000)
#round the counts into integers
if(length(lowcount.id)>0){
mcounts <- mcounts[, -lowcount.id]
}

cat(paste0("Removed ", length(lowcount.id), " samples with total counts < 2.5 M\n"))
cat("Applying variance stabalizing transformation...\n")

sampleinfo <- matrix(factor(1),nrow=ncol(mcounts))
rownames(sampleinfo) <- colnames(mcounts)
colnames(sampleinfo) <- "SampleID"

dds <- DESeqDataSetFromMatrix(countData=mcounts,colData=sampleinfo,design=~1)
gidx <- (rowSums(counts(dds))>(ncol(mcounts)/5))
dds <- dds[gidx,]
geneinfo <- geneinfo[gidx,]

#jpeg(file="maplot")
#plotMA(dds)
#dev.off()

ge_mad=apply(counts(dds),1,mad)
##remove genes showing no variability
no_v=which(ge_mad>0)
dds=dds[no_v,]
geneinfo <- geneinfo[no_v,]

vsd <- vst(dds, nsub=min(1000, nrow(dds)),blind=FALSE)


ge <- t(assay(vsd))  # Normalized gene expression

#plots for data exploration:

#plotSparsity(dds,normalized = F)
#plotPCA(vsd,intgroup="SampleID")

#obtain gene position information
write.table(ge, paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpt/gexp"), col.names = F, quote = F)
write.table(geneinfo, paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpt/genename"), col.names = F, quote = F)
