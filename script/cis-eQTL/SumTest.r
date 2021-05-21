### SumTest.R
#
SumTest <- function(Y,X,alpha0){
    pv <- NULL
    beta <- NULL
    for(i in 1:ncol(X)){
       fit  <- lm(Y~X[,i])
       beta <- c(beta,fit$coefficients[-1])
       pv <- c(pv,as.numeric(summary(fit)$coefficients[,4][-1]))
    }
    
    Xg <- X    
    Xgb <- Xg-mean(Xg)
    n <- nrow(Xgb)
   
    #U <- t(Xg) %*% (Y-mean(Y)) #score vector, needs to be modified for normal distribution
    #CovS <- mean(Y)*(1-mean(Y))*(t(Xgb) %*% Xgb)  #variance of score vector  
    U <- (t(Xg) %*% (Y-mean(Y))) * (n-1) / as.numeric(t(Y-mean(Y)) %*% (Y-mean(Y))) #score vector
    CovS <- (t(Xgb) %*% Xgb) * (n-1) / as.numeric(t(Y-mean(Y)) %*% (Y-mean(Y))) #variance of score vector

    w <- rep(1, length(U))
    w[beta<0 & pv<alpha0] <- -1
      
    u <- sum(t(w)%*%U) #adaptive score vector
    v <- as.numeric(t(w) %*% CovS %*% (w)) #variance of adaptive score vector

    Tsum <- u/sqrt(v) #test statistic
    pTsum <- as.numeric( 1-pchisq(Tsum^2, 1) ) #p-value

    return(cbind(u,v,Tsum,pTsum,w))
}
