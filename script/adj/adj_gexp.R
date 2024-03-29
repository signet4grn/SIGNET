library(data.table)
geno_id=fread(paste0(Sys.getenv("resg"), "_Genotype.sampleID"), header=F)
geno_id$geno_idx=1:dim(geno_id)[1]

gexp=fread(paste0(Sys.getenv("rest"), "_gexp"))
gexp_id=fread(paste0(Sys.getenv("rest"), "_gexpID"), header=F)
gexp_id$gexp_idx=1:dim(gexp_id)[1]

#xxxx-xx-PPPP corresponds to a unique patient.
geno_id$patient=sapply(strsplit(geno_id$V1,split = "-"),`[`,3)
gexp_id$patient=sapply(strsplit(gexp_id$V1,split = "-"),`[`,3)

merged=merge(geno_id,gexp_id, by="patient")
merged=merged[order(merged$geno_idx,decreasing = F),]

#remove the non-cancer samples from gexp. TCGA-xx-xxxx-10 or greater is a normal.
#report number of normal samples, how many have both, for each type
type=as.integer(substring(gexp_id$V1,14,15))
#length(which(type>9))
canc=which(type<10)
gexp_id=gexp_id[which(type<10),]

dup=gexp_id[duplicated(gexp_id$patient) | duplicated(gexp_id$patient, fromLast=T),]

#LUAD: one patient has data for multiple tumors. Data is 80% correlated. just remove one.
#merged=merged[unique(merged$patient),]
#take tissue samples only.
merged$m_id=1:nrow(merged)
dup=merged[duplicated(merged$patient) | duplicated(merged$patient, fromLast=T),]
dup=dup[order(dup$patient),]
dup$type=sapply(strsplit(dup$V1.x,split = "-"),`[`,4)
#remove solid tissue for duplicates
dup=dup[dup$type!="NT" & dup$type != "11A" & dup$type != "11B",]
#length(unique(dup$patient))
remove=dup$m_id
if(sum(remove)>0){
merged=merged[-remove,]
}

#note: some patients have gene expression data for multiple tumor sites.
#LUAD: one patient has data for multiple tumors. Data is 80% correlated. just remove one.
#merged=merged[unique(merged$patient),]

#save files.
write.table(merged$geno_idx,paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpg/geno_idx"),quote=F,col.names = F, row.names = F)
write.table(merged$V1.x,paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpg/geno_id"),quote=F,col.names = F, row.names = F)

#reorder gene expression.
gexp <- gexp[merged$gexp_idx, ] 
fwrite(gexp,paste0(Sys.getenv("resa"), "_matched.gexp"), row.names = F, col.names = F, quote=F, sep = " ")
