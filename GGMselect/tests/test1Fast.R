library(GGMselect)
itest=1
# +++++++++++++++++++++++++++++++++++++++++++++++++
p=30
n=30
eta=0.13
dmax=3
iG = 4
iS = 20
set.seed(iG)
Gr <- simulateGraph(p,eta)
set.seed(iS*(pi/3.1415)**iG)
X <- rmvnorm(n, mean=rep(0,p), sigma=Gr$C)

K=2.5
# ptm <- proc.time()
print(selectFast(X, dmax, K, family=c("EW","LA","C01")))
# cat("Elapsed time ",  proc.time()-ptm,"\n")
cat ("End of test ", itest)

