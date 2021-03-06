x2weight.robCov <-
function(xMat)
{
  tmc=qchisq(0.9, ncol(xMat[,-1]))
  dist=mahalanobis(xMat[,-1],
                  cov.rob(xMat[,-1], method="mve")$center,
                  cov.rob(xMat[,-1], method="mve")$cov)  
 return(ifelse(dist<tmc, 1, tmc/dist))
}
