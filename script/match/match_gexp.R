library(data.table)
geno_id=fread(paste0(Sys.getenv("SIGNET_RESULT_ROOT"), "/resg/Genotype.sampleID"), header=F)
geno_id$geno_idx=1:dim(geno_id)[1]

gexp=fread(paste0(Sys.getenv("SIGNET_RESULT_ROOT"), "/rest/gexp"))
gexp <- gexp[, -1]
gexp_id=fread(paste0(Sys.getenv("SIGNET_RESULT_ROOT"), "/rest/gexpID"), header=F)
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
#LUSC: 51 normal
#LUAD: 59 normal

#average different vials for the same patient
dup=gexp_id[duplicated(gexp_id$patient) | duplicated(gexp_id$patient, fromLast=T),]
g2=as.data.frame(gexp)
#tpm.2=tpm_format[3:587,]
g2=g2[canc,]

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
merged=merged[-remove,]

#note: some patients have gene expression data for multiple tumor sites.
#LUAD: one patient has data for multiple tumors. Data is 80% correlated. just remove one.
#merged=merged[unique(merged$patient),]

#save files.
write.table(merged$geno_idx,paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpg/geno_idx"),quote=F,col.names = F, row.names = F)
write.table(merged$V1.x,paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpg/geno_id"),quote=F,col.names = F, row.names = F)

#reorder gene expression.
gexp <- gexp[merged$gexp_idx, ] 
fwrite(gexp,paste0(Sys.getenv("SIGNET_RESULT_ROOT"), "/resm/matched.gexp"), row.names = F, col.names = F, quote=F, sep = " ")
