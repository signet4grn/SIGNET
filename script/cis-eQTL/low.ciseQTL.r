### low.ciseQTL.R
### Calculate p-values of low-freq cis-eQTL via permutation
#
y=fread(Sys.getenv("gexp"))
x=fread('low.Geno.data')
idx=read.table('low.cispair.idx')
y=as.matrix(y)
x=as.matrix(x)
idx=as.matrix(idx)
yidx=unique(idx[,1])
ylen=length(yidx)

alpha0=0.1 #the cut-off value; 
           #if the marginal p-value of an SNP is less than alpha0 and 
           #its marginal regression coefficient is negative,
           #we flip its coding;
B=100 #the number of permutations

source(paste0(Sys.getenv("SIGNET_SCRIPT_ROOT"), '/cis-eQTL/SumTest.r'))
source(paste0(Sys.getenv("SIGNET_SCRIPT_ROOT"), '/cis-eQTL/rSumTest.r'))

w <- NULL
aSumP <- NULL
theoP <- NULL
for (i in YYstartYY:YYendYY){
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

        fit0 <- rSumTest(Y,Xs,B,alpha0)
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

            fit0 <- rSumTest(Y,Xs,B,alpha0)
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

            fit0 <- rSumTest(Y,Xs,B,alpha0)
            u0 <- fit0[1,1]
            v0 <- fit0[1,2]
            a <- fit0[1,3]
            b <- fit0[1,4]
            pv0 <- fit0[,5]

            aSumP <- rbind(aSumP, c(yidx[i], j, sum(pv>pv0)/length(pv0)) ) #permutation-based p value
            theoP <- rbind(theoP, c(yidx[i], j, as.numeric(1 - pchisq(abs(((u-u0)^2/v0-b)/a),1)) ) ) 
        }
    }    

    if((i%%10000)==0) print(i)
}

write.table(w,"low.ciseQTL.weightYYY",row.names=F,col.names=F,quote=F,sep=" ")
#Col 1: index of collapsed SNPs for a gene, Col 2: weight of collapsed SNPs
write.table(aSumP,"low.aSumPYYY",row.names=F,col.names=F,quote=F,sep=" ")
#Col 1: index of gene, Col 2: index of collapsed SNPs for a gene, Col 3: p-value
write.table(theoP,"low.theoPYYY",row.names=F,col.names=F,quote=F,sep=" ")
#Col 1: index of gene, Col 2: index of collapsed SNPs for a gene, Col 3: p-value
