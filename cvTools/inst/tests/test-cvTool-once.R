context("cvTool - one replication")


## load packages
library("cvTools", quietly=TRUE)

## set seed for reproducibility
set.seed(1234)

## generate data for tests
n <- 20
x <- rnorm(n)
y <- x + rnorm(n)
x <- as.matrix(x)
xy <- data.frame(x, y)

## set up function call to lm() and lts()
lmCall <- call("lm", y~x)
ltsCall <- call("ltsReg", alpha=0.75)

## set up cross-validation folds
K <- 5
R <- 1
folds <- cvFolds(n, K, R)


## run tests

test_that("matrix of results has correct dimensions", {
        ## LS fit
        lmCV <- cvTool(lmCall, data=xy, y=xy$y, cost=rmspe, folds=folds)
        
        expect_is(lmCV, "matrix")
        expect_equal(dim(lmCV), c(R, 1))
        
        ## reweighted and raw LTS fits
        ltsCV <- cvTool(ltsCall, x=x, y=y, cost=rtmspe, folds=folds, 
            predictArgs=list(fit="both"))
        
        expect_is(ltsCV, "matrix")
        expect_equal(dim(ltsCV), c(R, 2))
    })

test_that("including standard error gives list of two numeric vectors", {
        ## LS fit
        lmCV <- cvTool(lmCall, data=xy, y=xy$y, cost=rmspe, folds=folds, 
            costArgs=list(includeSE=TRUE))
        
        expect_is(lmCV, "list")
        expect_equal(length(lmCV), 2)
        lmRMSPE <- lmCV[[1]]
        expect_is(lmRMSPE, "numeric")
        expect_equal(length(lmRMSPE), 1)
        lmSE <- lmCV[[2]]
        expect_is(lmSE, "numeric")
        expect_equal(length(lmSE), 1)
        
        ## reweighted and raw LTS fits
        ltsCV <- cvTool(ltsCall, x=x, y=y, cost=rtmspe, folds=folds, 
            predictArgs=list(fit="both"), costArgs=list(includeSE=TRUE))
        
        expect_is(ltsCV, "list")
        expect_equal(length(ltsCV), 2)
        ltsRTMSPE <- ltsCV[[1]]
        expect_is(ltsRTMSPE, "numeric")
        expect_equal(length(ltsRTMSPE), 2)
        ltsSE <- ltsCV[[2]]
        expect_is(ltsSE, "numeric")
        expect_equal(length(ltsSE), 2)
    })
