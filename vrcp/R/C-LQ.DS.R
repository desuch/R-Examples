# Linearizable C-LQ
# Common variance for both segments
# Smoothness

llsearch.LQ.CDS <- function(x, y, n, jlo, jhi)
{
  fj <- matrix(0, n)
  fxy <- matrix(0, jhi - jlo + 1)
  
  jgrid <- expand.grid(jlo:jhi)
  k.ll <- apply(jgrid, 1, p.estFUN.LQ.CDS, x = x, y = y, n = n)
  
  fxy <- matrix(k.ll, nrow = jhi-jlo+1)
  rownames(fxy) <- jlo:jhi
  
  z <- findmax(fxy)
  jcrit <- z$imax + jlo - 1
  list(jhat = jcrit, value = max(fxy))
}

#  Function for deriving the ML estimates of the change-points problem.

p.estFUN.LQ.CDS <- function(j, x, y, n){
  a <- p.est.LQ.CDS(x,y,n,j)
  s2 <- a$sigma2
  t2 <- a$tau2
  return(p.ll.CDS(n, j, s2, t2))
}

p.est.LQ.CDS <- function(x,y,n,j){
  xa <- x[1:j]
  ya <- y[1:j]
  jp1 <- j+1
  xb <- x[jp1:n]
  yb <- y[jp1:n]
  x1 <- x
  x2 <- (2*x[j]*(x[j] - x) + (x^2-x[j]^2)) * (x >= x[j])
  
  fun <- lm(y ~ x1 + x2) # points(x, predict(fun), type = "l", col = "red")
  
  a0 <- summary(fun)$coe[1]
  a1 <- summary(fun)$coe[2]
  b2 <- summary(fun)$coe[3]
  b1 <- a1 - 2*b2*x[j]
  b0 <- a0+(a1-b1)*x[j]-b2*x[j]^2
  beta <-c(a0, a1, b0, b1, b2)  
  s2<- sum((ya-a0 - a1*xa)^2)/j
  t2 <- sum((ya-b0 - b1*xb - b2*xb^2)^2)/(n-j)
  list(a0=beta[1],a1=beta[2],b0=beta[3],b1=beta[4],b2=beta[5],sigma2=s2,tau2=t2,xj=x[j])
}

#  Function to compute the log-likelihood of the change-point problem

p.ll.CDS <- function(n, j, s2, t2){
  q1 <- n * log(sqrt(2 * pi))
  q2 <- 0.5 * n  * (1 + log(s2))
  q3 <- 0.5 * (n - j) * (1 + log(t2))
  - (q1 + q2 + q3)
}

findmax <-function(a)
{
  maxa<-max(a)
  imax<- which(a==max(a),arr.ind=TRUE)[1]
  jmax<-which(a==max(a),arr.ind=TRUE)[2]
  list(imax = imax, jmax = jmax, value = maxa)
}

