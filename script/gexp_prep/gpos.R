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


if(Sys.getenv("restrict")!="no"){
source(paste0(Sys.getenv("SIGNET_SCRIPT_ROOT"), "/gexp_prep/restrict.R"))
chr_ori <- substring(gpos[, 2], 4)
chr_restrict <- restrict(Sys.getenv("restrict"))
cat(paste0("The study will focus on genes on chromosomes ", toString(chr_restrict), "\n"))
restrict_id <- which(as.matrix(chr_ori)%in%as.matrix(chr_restrict))
gpos <- gpos[restrict_id, ]
gexp.filtered <- gexp.filtered[, restrict_id] 
}

write.table(gexpID, paste0(Sys.getenv("rest"), "_gexpID"), quote = F,row.names = F,col.names = F,sep= " ")
write.table(gpos, paste0(Sys.getenv("rest"), "_gene_pos"), quote = F,row.names = F,col.names = F,sep= " ")
write.table(gpos[, 1], paste0(Sys.getenv("rest"), "_gene_name"), quote = F,row.names = F,col.names = F,sep= " ")
write.table(gexp.filtered, paste0(Sys.getenv("rest"), "_gexp"),quote = F,row.names = F,col.names = F,sep= " ")
