library(cda)

gold <- epsAu(seq(400, 800, by=5))

structure <- function(p, a=NULL, epsilon=NULL, printChecks = FALSE){
  
  ## interparticle distances
  d12 <- p[1]
  d23 <- p[2]
  d34 <- p[3]
  ## angles
  t1 <- p[4]
  t2 <- p[5]
  t3 <- p[6]
  if(is.null(a))
    a <- p[7:10]
  
  if(is.null(epsilon))
    epsilon <- min(a)
  
  ## sphere centers
  S1 <- d12*c(-cos(t1), sin(t1), 0)
  S2 <- c(0, 0, 0)
  S3 <- c(d23, 0, 0)
  S4 <- S3 + d34*c(cos(t3)*cos(t2), cos(t3)*sin(t2), sin(t3))
  
  ## remaining distances
  d13 <- sqrt(crossprod(S1 - S3))
  d14 <- sqrt(crossprod(S1 - S4))
  d24 <- sqrt(crossprod(S2 - S4))
  
  if(printChecks){
    message(abs(d12 - (a[1] + a[2])), "\n",
            abs(d23 - (a[2] + a[3])), "\n",
            abs(d34 - (a[3] + a[4])), "\n",
            abs(d13 - (a[1] + a[3])), "\n",
            abs(d14 - (a[1] + a[4])), "\n",
            abs(d24 - (a[2] + a[4]))
            )
  }
  ## checks for collisions
  ## assuming d12, d23, d34 already non-colliding
  
  if((d13 < a[1] + a[3] + epsilon) ||
     (d14 < a[1] + a[4] + epsilon) ||
     (d24 < a[2] + a[4] + epsilon))
    return(list())
  
  positions <- rbind(S1, S2, S3, S4)
  sizes <- cbind(a = a, b = a, c = a)
  angles <- 0*sizes
  
  list(r=positions, sizes=sizes, angles=angles)
}

p0 <- c(100, 120, 130, pi/3, pi/3, pi/4)
a0 <- c(30, 20, 20, 15)
a0 <- rep(20, 4)

cl1 <- structure(p0, a0, printChecks=TRUE)

p0w <- p0
p0w[4] <- pi
structure(p0w, a0)
library(rgl)
rgl.ellipsoids(cl1$r, cl1$sizes, cl1$angles, col="gold")
planes3d(0,0,1, 0, alpha=0.5)
rgl.viewpoint( theta = 0, phi = 20, fov = 70, zoom = 1)

library("GA")

fitness <- function(p, ..., draw=FALSE){
  
  s <- structure(p, ...)
  if(!length(s))
    return(0)
  
  if(draw)
    rgl.spheres(s$r, radius=s$sizes, col=1:4)
  res <- circular_dichroism_spectrum(cluster=s, result.matrix=TRUE,
                                    averaging="cheap",
                                    medium=1.33,
                                    material=gold)
#  max(abs(res[,5]) / max(res[,2])) # max(|g_ext|)
id <- which.max(abs(res[,5]))
abs(res[id,5]) / res[id,2] # max(|g_ext|)

}

test <- fitness(p0, a0)
epsilon <- min(a0)
minp <- c(a0[1]+a0[2]+epsilon,
          a0[2]+a0[3]+epsilon,
          a0[3]+a0[4]+epsilon,
          -pi, -pi, 0)
maxp <- c(800, 800, 800, 
          pi, pi, pi)
  
monitor <- function(object, digits = getOption("digits"), ...) {
  cat(paste("Iter =", object@iter, " | Mean =", 
            format(object@mean[object@iter], digits = digits), 
            " | Best =", format(object@best[object@iter], 
                                digits = digits), "\n"))
}


cl1 <- structure(p0, a0)
open3d()
bg3d("white")
rgl.spheres(cl1$r, radius=cl1$sizes, col=1:4)
planes3d(0,0,1, 0, alpha=0.5)

GA <- ga(type = "real-valued",
          fitness = fitness, keepBest=TRUE,
          min = minp, max = maxp, popSize = 50,
          maxiter = 10, a=a0, monitor=monitor, draw=TRUE)

rgl.snapshot(filename="swarm.png")

GA <- ga(type = "real-valued",
         fitness = fitness, keepBest=TRUE,
         min = minp, max = maxp, popSize = 50,
         maxiter = 100, a=a0, monitor=monitor, draw=FALSE)

cl <- structure(GA@solution, a0, printChecks=TRUE)

open3d()
bg3d("white")
rgl.spheres(cl1$r, radius=cl1$sizes, col=1:4)
planes3d(0,0,1, 0, alpha=0.5)
display <- function(p){
  cl <- structure(p, a0)
  rgl.spheres(cl$r, radius=cl$sizes, col=1:4, alpha=0.2)
}
bestsets <- unique(GA@bestSol)
evolution <- lapply(bestsets, display)

rgl.spheres(cl$r, radius=cl$sizes*1.1, col=1:4)
rgl.spheres(cl$r, radius=cl$sizes*1.2, col="gold",  alpha=0.5)
# rgl.viewpoint( theta = 0, phi = 20, fov = 70, zoom = 1)

rgl.snapshot(filename="solution.png")

first <- circular_dichroism_spectrum(cluster=cl1, result.matrix=FALSE,
                                     averaging="cheap",
                                     medium=1.33,
                                     material=gold)

sol <- circular_dichroism_spectrum(cluster=cl, result.matrix=FALSE,
                                     averaging="cheap",
                                     medium=1.33,
                                     material=gold)
require(ggplot2)
ggplot(subset(sol, variable == "extinction"), aes(wavelength, value))+
  facet_grid(type~., scales="free")+
  geom_line()+
  geom_line(data=subset(first, variable == "extinction"), lty="dotted")

ggsave("cd.pdf")

