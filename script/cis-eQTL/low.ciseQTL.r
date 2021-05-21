setwd("../../data/cis-eQTL")
args = commandArgs(T)
nperms = args[1]  #the number of permutations

library(data.table)

y=as.matrix(fread('final.gexpdata0'))
x=as.matrix(fread('low.snpsdata0'))
idx=read.table('low.cispair.idx')
idx=as.matrix(idx)
yidx=unique(idx[,1])
ylen=length(yidx)

#15997

#alpha0=0.1 #the cut-off value; 
           #if the marginal p-value of an SNP is less than alpha0 and 
           #its marginal regression coefficient is negative,
           #we flip its coding;
alpha0=0.1

source("../../script/cis-eQTL/SumTest.r")
source("../../script/cis-eQTL/rSumTest.r")

B = nperms

w <- NULL
aSumP <- NULL
theoP <- NULL
for (i in 1:20){
    Y <- y[,yidx[i]]
    X <- x[,idx[idx[,1]==yidx[i],2]]
    Y <- as.matrix(Y)
    X <- as.matrix(X)

    ng <- ncol(X)
    wsize <- 50
    nw <- ng %/% wsize
   
    if (nw==0){
        Xs <- X[,1:ng]
        Xs <- as.matrix(Xs)
        fit <- SumTest(Y,Xs,alpha0)
        u <- fit[1,1]
        v <- fit[1,2]
        pv <- fit[1,4] #p-value 
        w <- rbind(w, cbind(rep(1,ng), fit[,5])) #weight of X

        fit0 <- rSumTest(Y,X,B,alpha0)
        u0 <- fit0[1,1]
        v0 <- fit0[1,2]
        a <- fit0[1,3]
        b <- fit0[1,4]
        pv0 <- fit0[,5]

        aSumP <- rbind(aSumP, c(yidx[i], 1, sum(pv>pv0)/length(pv0)) ) #permutation-based p value
        theoP <- rbind(theoP, c(yidx[i], 1, as.numeric(1 - pchisq(abs(((u-u0)^2/v0-b)/a),1)) ) )        
    } else{
        for (j in 1:nw){
            Xs <- X[,((j-1)*wsize+1):(j*wsize)]
            Xs <- as.matrix(Xs)
            fit <- SumTest(Y,Xs,alpha0)
            u <- fit[1,1]
            v <- fit[1,2]
            pv <- fit[1,4] #p-value  
            w <- rbind(w, cbind(rep(j,wsize), fit[,5])) #weight of X

            fit0 <- rSumTest(Y,X,B,alpha0)
            u0 <- fit0[1,1]
            v0 <- fit0[1,2]
            a <- fit0[1,3]
            b <- fit0[1,4]
            pv0 <- fit0[,5]

            aSumP <- rbind(aSumP, c(yidx[i], j, sum(pv>pv0)/length(pv0)) ) #permutation-based p value
            theoP <- rbind(theoP, c(yidx[i], j, as.numeric(1 - pchisq(abs(((u-u0)^2/v0-b)/a),1)) ) )    
        }
        
        if (ng%%wsize!=0){
            j <- nw+1
            Xs <- X[,(nw*wsize+1):ng]
            Xs <- as.matrix(Xs)
            fit <- SumTest(Y,Xs,alpha0)
            u <- fit[1,1]
            v <- fit[1,2]
            pv <- fit[1,4] #p-value   
            w <- rbind(w, cbind(rep(j,ng%%wsize), fit[,5])) #weight of X

            fit0 <- rSumTest(Y,X,B,alpha0)
            u0 <- fit0[1,1]
            v0 <- fit0[1,2]
            a <- fit0[1,3]
            b <- fit0[1,4]
            pv0 <- fit0[,5]

            aSumP <- rbind(aSumP, c(yidx[i], j, sum(pv>pv0)/length(pv0)) ) #permutation-based p value
            theoP <- rbind(theoP, c(yidx[i], j, as.numeric(1 - pchisq(abs(((u-u0)^2/v0-b)/a),1)) ) ) 
        }
    }    

    print(i)
}

write.table(w,"low.ciseQTL.weight1",row.names=F,col.names=F,quote=F,sep=" ")
#Col 1: index of collapsed SNPs for a gene, Col 2: weight of collapsed SNPs
write.table(aSumP,"low.aSumP1",row.names=F,col.names=F,quote=F,sep=" ")
#Col 1: index of gene, Col 2: index of collapsed SNPs for a gene, Col 3: p-value
write.table(theoP,"low.theoP1",row.names=F,col.names=F,quote=F,sep=" ")
#Col 1: index of gene, Col 2: index of collapsed SNPs for a gene, Col 3: p-value
