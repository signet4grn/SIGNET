### rSumTest.R
#
rSumTest <- function(Y,X,k,alpha0){
    Yg <- Y
    n <- length(Yg)

    u0 <- v0 <- pv0 <- NULL    
    for(sim in 1:k){
       set.seed(sim)
       pidx <- sample.int(n,size=n,replace=FALSE)       
       Y <- Yg[pidx]

       fit0 <- SumTest(Y,X,alpha0)
       u0 <- c(u0, fit0[1,1])
       v0 <- c(v0, fit0[1,2])
       pv0 <- c(pv0,as.numeric(fit0[1,4]))
    }   

    x <- (u0-mean(u0))^2/var(u0)
    a <- sqrt(var(x)/2)
    b <- mean(x)-a
    
    return(cbind(rep(mean(u0),k), rep(var(u0),k) ,rep(a,k), rep(b,k), pv0))
}
