##Adjust for covariates and truncate the genotype data
args <- commandArgs(TRUE)
eval(parse(text=args))

library(data.table)
library(plyr)
library(ggplot2)
evec <-read.table(paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpa/Geno.pca.evec"))
evecid <- evec[, 1]
evec <-evec[,2:11]
#load the 10 PCA
pca = as.matrix(evec)
## for common varints

clinic=read.table(clifile,sep="\t",header=T)
id=fread(paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpg/geno_id"),header=F)
tmpid <- sapply(id, substring, 1, 12)
##identify whose genotype data have outliers
rmidx <- which(is.na(match(tmpid, evecid)))
if(length(rmidx)>0){
id <- id[-rmidx, ]
}
id <- as.data.frame(id)
clinic$submitter_id=as.character(clinic$submitter_id)
id$patient=sapply(strsplit(id$V1,split = "-"),`[`,3)
clinic$patient=sapply(strsplit(clinic$submitter_id,split = "-"),`[`,3)
clinic=clinic[!duplicated(clinic$patient),]
if(length(rmidx)>0){
pca <- pca[match(tmpid[-rmidx, ], evecid), ]
}
id2=cbind(pca,id)
merged=join(id2, clinic, by="patient")
ggplot(aes(x=V2,y=V3,color=race),data=merged)+geom_point()

# #pca$x
# #pc.comp <- pca$x
# ##replace CellType with name of datasets
#merged$race
# library(ggplot2)
#ggplot(evec, aes(x=V2, y=V3, color=race)) +geom_point(size = 2) + theme_classic() + theme_classic(base_size=20)+ ggtitle("PCA")+   theme(plot.title = element_text(hjust = 0.5))
#
#
#
#
#merged$year_of_birth
#merged$gender

#
vst_gexp <- as.matrix(fread(paste0(Sys.getenv("SIGNET_RESULT_ROOT"), "/resa/matched.gexp"))) # gene by sample
vst_gexp<-t(vst_gexp)
##remove the genes whose genotyoe data is considered outliers.
if(length(rmidx)>0){
vst_gexp <- vst_gexp[, -rmidx]
}
# merged$age_at_diagnosis=as.character(merged$age_at_diagnosis)
# merged$age_at_diagnosis=as.integer(merged$age_at_diagnosis)
# #impute missing with mean
# merged$age_at_diagnosis[is.na(merged$age_at_diagnosis)]=mean(merged$age_at_diagnosis[!is.na(merged$age_at_diagnosis)])
# merged$age_at_diagnosis=as.integer(merged$age_at_diagnosis)
idx=which(merged$race!="american indian or alaska native")
merged=merged[merged$race!="american indian or alaska native", ]
merged$race[merged$race=="not reported"]="white"
vst_gexp=vst_gexp[,idx]

p = dim(vst_gexp)[1]
n = dim(vst_gexp)[2]

#levels(merged$race)
merged$race=as.factor(merged$race)
#levels(merged$race)=c("white","black or african american","asian")
tmp=factor(unclass(merged$race))
#levels(tmp)
levels(tmp)=c("asian","black or african american","white")
merged$race=tmp

gexp_int_pca <- matrix(0,p,n)
gexp_int <- gexp_int_pca
coeff_mat=matrix(0,p,5)


print("Begin to adjust for covariates effect for race and gender")
#merged$race[merged$race=="not reported"]="white"
cat("\n")
for( i in 1:p)
{
  # inverse gaussian transformation
  tmp_int <- vst_gexp[i,]
  #tmp_int <- qnorm(R/(n+1))
  tmpfit <- lm(tmp_int ~  factor(merged$race) + factor(merged$gender))
  #tmpfit$coefficients[2:11]
  if(npc==0){
  tmpfit <- lm(tmp_int ~  factor(merged$race) + factor(merged$gender))
  }else{
  tmpfit_pca <- lm(tmp_int ~  as.matrix(merged[, 1:npc]) + factor(merged$race) + factor(merged$gender))
  }

  gexp_int[i, ] <- resid(tmpfit)
  gexp_int_pca[i, ] <- resid(tmpfit_pca)

  if(i%%1000==0) print(paste0(i, " genes finished"))
}

cat("\n")

gexp_int <- t(gexp_int)
gexp_int_pca <- t(gexp_int_pca)
# output results
write.table(gexp_int,file=paste0(paste0(Sys.getenv("SIGNET_RESULT_ROOT"), "/resa/gexp.data")),quote=F,row.names=F,col.names=F)
write.table(gexp_int_pca,file=paste0(paste0(Sys.getenv("SIGNET_RESULT_ROOT"), "/resa/gexp_rmpc.data")),quote=F,row.names=F,col.names=F)
geno <- fread(paste0(paste0(Sys.getenv("SIGNET_RESULT_ROOT"), "/resa/new.Geno")))
if(length(rmidx)>0){
geno <- geno[-rmidx, ]
}
geno <- geno[idx, ]
fwrite(geno,file=paste0(paste0(Sys.getenv("SIGNET_RESULT_ROOT"), "/resa/geno.data")),quote=F,sep= " ",col.names = F, row.names = F)

