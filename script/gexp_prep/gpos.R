args <- commandArgs(TRUE)
eval(parse(text=args))
library(data.table)
library(plyr)
library(Rgb)

#format the gexp data
gexp.filtered=fread(paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpt/gexp"))
gexpID <- gexp.filtered[, 1]
gexp.filtered=gexp.filtered[, -1]
gene.id=fread(paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpt/genename"))[, 2]
names(gene.id)="gene_id"
gexp.filtered=as.data.frame(gexp.filtered)


#protein coding only
gtf=read.gtf(file)
gtf=gtf[gtf$feature=="gene",]
gtf=gtf[gtf$transcript_type=="protein_coding",]

# gtf=gtf[which(gtf$transcript_type=="protein_coding" | gtf$transcript_type=="IG_C_gene" | gtf$transcript_type=="IG_D_gene" | gtf$transcript_type=="IG_V_gene"
#         | gtf$transcript_type=="IG_J_gene" | gtf$transcript_type=="TR_C_gene" | gtf$transcript_type=="TR_V_gene" | gtf$transcript_type=="TR_D_gene"
#         | gtf$transcript_type=="TR_J_gene" | gtf$transcript_type=="rRNA" | gtf$transcript_type=="Mt_rRNA" | gtf$transcript_type=="ribozyme"),]

#table(gtf$transcript_type)
gene.id=data.frame(gene_id=gene.id,idx=1:nrow(gene.id))
matched=join(gene.id,gtf,by="gene_id")
gpos=data.frame(matched$gene_name,matched$seqname,matched$start,matched$end)
has.annot=which(complete.cases(gpos))

gpos=gpos[has.annot,]
gexp.filtered=gexp.filtered[,has.annot]


write.table(gexpID, paste0(Sys.getenv("SIGNET_RESULT_ROOT"), "/rest/gexpID"), quote = F,row.names = F,col.names = F,sep= " ")
write.table(gpos, paste0(Sys.getenv("SIGNET_RESULT_ROOT"), "/rest/gene_pos"), quote = F,row.names = F,col.names = F,sep= " ")
write.table(gpos[, 1], paste0(Sys.getenv("SIGNET_RESULT_ROOT"), "/rest/gene_name"), quote = F,row.names = F,col.names = F,sep= " ")
write.table(gexp.filtered, paste0(Sys.getenv("SIGNET_RESULT_ROOT"), "/rest/gexp"),quote = F,row.names = F,col.names = F,sep= " ")
