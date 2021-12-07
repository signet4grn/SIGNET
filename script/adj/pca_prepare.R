setwd(paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpa"))
library(data.table)
geno=fread(paste0(Sys.getenv("resa"), "_new.Geno"))
geno=t(geno)
write.table(geno,"new.Geno.eigenstratgeno",quote=F,col.names=F,row.names=F,sep="")

map=fread(paste0(Sys.getenv("resa"), "_new.Geno.map"))
map=map[,c(2,1,3,4)]
map$V2=seq(1,nrow(map))
map <- cbind(map, -9, -9)
write.table(map,"new.Geno.snp",quote=F,col.names=F,row.names=F,sep=" ")


fam=fread(paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpg/clean_Genotype.fam"))
id=fread(paste0(Sys.getenv("SIGNET_TMP_ROOT"),"/tmpg/geno_id"),header=F)
merged=merge(id,fam,by="V1")
#eigenstrat has a max length of id for some reason
merged$V1=sapply(merged$V1,substring,1,12)
merged$gender[merged$V5==1]="M"
merged$gender[merged$V5==2]="F"
merged=merged[,c(1,6,7)]
write.table(merged,"new.Geno.ind",quote=F,col.names=F, row.names=F, sep= " ")
