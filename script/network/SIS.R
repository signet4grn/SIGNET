SIS <- function(x, y, family = c("gaussian", "binomial", "poisson", "cox"), penalty = c("SCAD", "MCP", "lasso","adalasso"),
    concavity.parameter = switch(penalty, SCAD = 3.7, 3), tune = c("bic", "ebic", "aic", "cv"), nfolds = 10,
    type.measure = c("deviance", "class", "auc", "mse", "mae"), gamma.ebic = 1, nsis = NULL, iter = TRUE, iter.max = ifelse(greedy ==
        FALSE, 10, floor(nrow(x)/log(nrow(x)))), varISIS = c("vanilla", "aggr", "cons"), perm = FALSE, q = 1,
    greedy = FALSE, greedy.size = 1, seed = 0, standardize = TRUE) {

    this.call = match.call()
    family = match.arg(family)
    penalty = match.arg(penalty)
    tune = match.arg(tune)
    type.measure = match.arg(type.measure)
    varISIS = match.arg(varISIS)

    if (is.null(x) || is.null(y))
        stop("The data is missing!")
    if (class(concavity.parameter) != "numeric")
        stop("concavity.parameter must be numeric!")
    if (class(nfolds) != "numeric")
        stop("nfolds must be numeric!")
    if (class(seed) != "numeric")
        stop("seed must be numeric!")

    if (family == "cox" && penalty %in% c("SCAD", "MCP"))
        stop("Cox model currently not implemented with selected penalty")

    if (type.measure %in% c("class", "auc") && family %in% c("gaussian", "poisson", "cox"))
        stop("'class' and 'auc' type measures are only available for logistic regression")

    if (type.measure %in% c("class", "auc", "mse", "mae") && penalty %in% c("SCAD", "MCP"))
        stop("Only 'deviance' is available as type.measure for non-convex penalties")

    fit = switch(family, gaussian = sisglm(x, y, "gaussian", penalty, concavity.parameter, tune, nfolds, type.measure,
        gamma.ebic, nsis, iter, iter.max, varISIS, perm, q, greedy, greedy.size, seed, standardize), binomial = sisglm(x,
        y, "binomial", penalty, concavity.parameter, tune, nfolds, type.measure, gamma.ebic, nsis, iter, iter.max,
        varISIS, perm, q, greedy, greedy.size, seed, standardize), poisson = sisglm(x, y, "poisson", penalty,
        concavity.parameter, tune, nfolds, type.measure, gamma.ebic, nsis, iter, iter.max, varISIS, perm, q,
        greedy, greedy.size, seed, standardize), cox = sisglm(x, y, "cox", penalty, concavity.parameter, tune,
        nfolds, type.measure, gamma.ebic, nsis, iter, iter.max, varISIS, perm, q, greedy, greedy.size, seed,
        standardize))
    fit$call = this.call
    class(fit) = c(class(fit), "SIS")
    return(fit)
}

sisglm <- function(x, y, family, penalty, concavity.parameter, tune, nfolds, type.measure, gamma.ebic, nsis,
    iter, iter.max, varISIS, perm, q, greedy, greedy.size, seed, standardize, s1 = NULL, s2 = NULL, split.tries = 0) {

    storage.mode(x) = "numeric"
    n = dim(x)[1]
    p = dim(x)[2]
    models = vector("list")
    if (is.null(nsis) == TRUE)
        nsis = calculate.nsis(family = family, varISIS = varISIS, n = n, p = p)
    if (is.null(s1) == TRUE) {
        set.seed(seed)
        split.sample = sample(1:n)
        s1 = split.sample[1:ceiling(n/2)]
        s2 = setdiff(split.sample, s1)
    }
    old.x = x
    if (standardize == TRUE) {
        x = scale(x)
    }
    iterind = 0
    
    if (iter == TRUE) {
        ix0 = sort(obtain.ix0(x = x, y = y, s1 = s1, s2 = s2, family = family, nsis = nsis, iter = iter, varISIS = varISIS,
            perm = perm, q = q, greedy = greedy, greedy.size = greedy.size, iterind = iterind))
        repeat {
            iterind = iterind + 1
            cat("Iter", iterind, ", screening: ", ix0, "\n")
            if (penalty == "adalasso"){
                selection.fit=adalasso(x[,ix0], y, k=10)
                ix1=sort(ix0[which(!selection.fit[[8]]==0)])
                cx1=selection.fit[[8]][which(!selection.fit[[8]]==0)]
            } else{
                selection.fit = tune.fit(old.x[,ix0,drop = FALSE], y, family , penalty , concavity.parameter, tune, nfolds , type.measure , gamma.ebic)
                coef.beta = selection.fit$beta
                a0 = selection.fit$a0
                lambda  = selection.fit$lambda
                lambda.ind = selection.fit$lambda.ind
                ix1 = sort(ix0[selection.fit$ix])
            }
            #if (length(ix1) == 0) {
            #    split.tries = split.tries + 1
            #    split.sample = sample(1:n)
            #    s1 = split.sample[1:ceiling(n/2)]
            #    s2 = setdiff(split.sample, s1)
            #    cat("Sample splitting attempt: ", split.tries, "\n")
            #    if (split.tries == 20) {
            #      varISIS = "vanilla"
            #      perm = TRUE
            #      greedy = FALSE
            #      tune = "cv"
            #      cat("No variables remaining after ", split.tries, " sample splitting attempts! \n")
            #      cat("Trying a more conservative variable screening approach with a data-driven threshold for marginal screening! \n")
            #      return(sisglm(old.x, y, family, penalty, concavity.parameter, tune, nfolds, type.measure, gamma.ebic,
            #        nsis, iter, iter.max, varISIS, perm, q, greedy, greedy.size, seed, standardize, s1 = NULL,
            #        s2 = NULL))
            #    } else return(sisglm(old.x, y, family, penalty, concavity.parameter, tune, nfolds, type.measure, gamma.ebic,
            #      nsis, iter, iter.max, varISIS, perm, q, greedy, greedy.size, seed, standardize, s1, s2, split.tries))
            #}
            cat("Iter", iterind, ", selection: ", ix1, "\n")
            if (length(ix1) >= nsis || iterind >= iter.max) {
                ix0 = ix1
                if (length(ix1) >= nsis)
                  cat("Maximum number of variables selected \n")
                if (iterind >= iter.max)
                  cat("Maximum number of iterations reached \n")
                break
            }

            models[[iterind]] = ix1
            flag.models = 0
            if (iterind > 1) {
                for (j in 1:(iterind - 1)) {
                  if (identical(models[[j]], ix1) == TRUE)
                    flag.models = 1
                }
            }
            if (flag.models == 1) {
                cat("Model already selected \n")
                break
            }

            candind = setdiff(1:p, ix1)
            pleft = nsis - length(ix1)
            newix = sort(obtain.newix(x = x, y = y, candind = candind, ix1 = ix1, s1 = s1, s2 = s2, family = family,
                pleft = pleft, varISIS = varISIS, perm = perm, q = q, greedy = greedy, greedy.size = greedy.size,
                iterind = iterind))
            cat("Iter", iterind, ", conditional-screening: ", newix, "\n")
            ix1 = sort(c(ix1, newix))
            if (setequal(ix1, ix0)) {
               flag.models = 1
            }
            ix0 = ix1
        }  # end repeat

    } else {
        # end if(iter==TRUE)
        ix0 = sort(obtain.ix0(x = x, y = y, s1 = s1, s2 = s2, family = family, nsis = nsis, iter = iter, varISIS = varISIS,
            perm = perm, q = q, greedy = greedy, greedy.size = greedy.size, iterind = iterind))
        if (penalty == "adalasso"){
            selection.fit=adalasso(x[,ix0], y, k=10)
            ix1=sort(ix0[which(!selection.fit[[8]]==0)])
            cx1=selection.fit[[8]][which(!selection.fit[[8]]==0)]
        } else {
            selection.fit = tune.fit(old.x[,ix0,drop = FALSE], y, family , penalty , concavity.parameter, tune, nfolds , type.measure , gamma.ebic)
            coef.beta = selection.fit$beta
            a0 = selection.fit$a0
            lambda = selection.fit$lambda
            lambda.ind = selection.fit$lambda.ind
            ix1 = sort(ix0[selection.fit$ix])
        }
    }



    if (family == "cox") {
      names(coef.beta) = paste("X", ix1, sep = "")
    }  else {
      if (!penalty == "adalasso"){
          coef.beta = c(a0, coef.beta)
          names(coef.beta) = c("(Intercept)", paste("X", ix1, sep = ""))
      }
    }

    if (penalty == "adalasso"){
        return(list(ix = ix1, cx = cx1, lambda = selection.fit$lambda.adalasso))
    } else {
        return(list(ix = ix1, coef.est = coef.beta, fit = selection.fit$fit, lambda = lambda, lambda.ind = lambda.ind))
    }
}
