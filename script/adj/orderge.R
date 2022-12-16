library(data.table)
setwd("../../luad_rerun/GeneExpression/")
geno_id=fread("../Genotype/Genotype.sampleID",header=F)
geno_id$geno_idx=1:dim(geno_id)[1]

gexp_id=fread("GexpID",header=F)
gexp_id$gexp_idx=1:dim(gexp_id)[1]

#remove the non-cancer samples from gexp. TCGA-xx-xxxx-10 or greater is a normal.
#report number of normal samples, how many have both, for each type
type=as.integer(substring(gexp_id$V1,14,16))
length(which(type>9))
gexp_id=gexp_id[which(type<10),]
#LUSC: 51 normal
#LUAD: 59 normal


#xxxx-xx-PPPP corresponds to a unique patient.
geno_id$patient=sapply(strsplit(geno_id$V1,split = "-"),`[`,3)
gexp_id$patient=sapply(strsplit(gexp_id$V1,split = "-"),`[`,3)

merged=merge(geno_id,gexp_id, by="patient")
merged=merged[order(merged$geno_idx,decreasing = F),]

#length(unique(merged$patient))          
#LUSC: 35 patients have genotype data for both the blood and tissue.
#take tissue samples only.
# merged$m_id=1:nrow(merged)
# dup=merged[duplicated(merged$patient) | duplicated(merged$patient, fromLast=T),]
# dup$type=sapply(strsplit(dup$V1.x,split = "-"),`[`,4)
# dup=dup[dup$type!="NT" & dup$type != "11A" & dup$type != "11B",]
# remove=dup$m_id
# merged=merged[-remove,]


#note: some patients have gene expression data for multiple tumor sites.
#LUAD: one patient has data for multiple tumors. Data is 80% correlated. just remove one.
#merged=merged[unique(merged$patient),]

#save files.
write.table(merged$geno_idx,"../Genotype/geno_idx",quote=F,col.names = F, row.names = F)
write.table(merged$V1.x,"../Genotype/geno_id",quote=F,col.names = F, row.names = F)

#reorder gene expression.
gexp=fread("Gexp")
gexp=gexp[merged$gexp_idx,]
fwrite(gexp,"matched.Gexp", row.names = F, col.names = F, quote=F, sep = " ")
