### R code from vignette source 'gstat.Rnw'

###################################################
### code chunk number 1: gstat.Rnw:74-84
###################################################
library(sp)
data(meuse)
class(meuse)
names(meuse)
coordinates(meuse) = ~x+y
class(meuse)
summary(meuse)
coordinates(meuse)[1:5,]
bubble(meuse, "zinc", 
	col=c("#00ff0088", "#00ff0088"), main = "zinc concentrations (ppm)")


###################################################
### code chunk number 2: gstat.Rnw:89-92
###################################################
print(bubble(meuse, "zinc", 
	col=c("#00ff0088", "#00ff0088"), main = "zinc concentrations (ppm)")
)


###################################################
### code chunk number 3: gstat.Rnw:113-126
###################################################
data(meuse.grid)
summary(meuse.grid)
class(meuse.grid)
coordinates(meuse.grid) = ~x+y
class(meuse.grid)
gridded(meuse.grid) = TRUE
class(meuse.grid)
image(meuse.grid["dist"])
title("distance to river (red = 0)")
library(gstat)
zinc.idw = idw(zinc~1, meuse, meuse.grid)
class(zinc.idw)
spplot(zinc.idw["var1.pred"], main = "zinc inverse distance weighted interpolations")


###################################################
### code chunk number 4: gstat.Rnw:129-130
###################################################
print(spplot(zinc.idw["var1.pred"], main = "zinc inverse distance weighted interpolations"))


###################################################
### code chunk number 5: gstat.Rnw:139-141
###################################################
plot(log(zinc)~sqrt(dist), meuse)
abline(lm(log(zinc)~sqrt(dist), meuse))


###################################################
### code chunk number 6: gstat.Rnw:150-155
###################################################
lzn.vgm = variogram(log(zinc)~1, meuse)
lzn.vgm
lzn.fit = fit.variogram(lzn.vgm, model = vgm(1, "Sph", 900, 1))
lzn.fit
plot(lzn.vgm, lzn.fit)


###################################################
### code chunk number 7: gstat.Rnw:158-159
###################################################
print(plot(lzn.vgm, lzn.fit))


###################################################
### code chunk number 8: gstat.Rnw:165-169
###################################################
lznr.vgm = variogram(log(zinc)~sqrt(dist), meuse)
lznr.fit = fit.variogram(lznr.vgm, model = vgm(1, "Exp", 300, 1))
lznr.fit
plot(lznr.vgm, lznr.fit)


###################################################
### code chunk number 9: gstat.Rnw:172-173
###################################################
print(plot(lznr.vgm, lznr.fit))


###################################################
### code chunk number 10: gstat.Rnw:182-184
###################################################
lzn.kriged = krige(log(zinc)~1, meuse, meuse.grid, model = lzn.fit)
spplot(lzn.kriged["var1.pred"])


###################################################
### code chunk number 11: gstat.Rnw:187-188
###################################################
print(spplot(lzn.kriged["var1.pred"]))


###################################################
### code chunk number 12: gstat.Rnw:192-195
###################################################
lzn.condsim = krige(log(zinc)~1, meuse, meuse.grid, model = lzn.fit, 
    nmax = 30, nsim = 4)
spplot(lzn.condsim, main = "four conditional simulations")


###################################################
### code chunk number 13: gstat.Rnw:198-199
###################################################
print(spplot(lzn.condsim, main = "four conditional simulations"))


###################################################
### code chunk number 14: gstat.Rnw:204-207
###################################################
lzn.condsim2 = krige(log(zinc)~sqrt(dist), meuse, meuse.grid, model = lznr.fit, 
    nmax = 30, nsim = 4)
spplot(lzn.condsim2, main = "four UK conditional simulations")


###################################################
### code chunk number 15: gstat.Rnw:210-211
###################################################
print(spplot(lzn.condsim2, main = "four UK conditional simulations"))


###################################################
### code chunk number 16: gstat.Rnw:220-223
###################################################
lzn.dir = variogram(log(zinc)~1, meuse, alpha = c(0, 45, 90, 135))
lzndir.fit = vgm(.59, "Sph", 1200, .05, anis = c(45, .4))
plot(lzn.dir, lzndir.fit, as.table = TRUE)


###################################################
### code chunk number 17: gstat.Rnw:226-227
###################################################
print(plot(lzn.dir, lzndir.fit, as.table = TRUE))


###################################################
### code chunk number 18: gstat.Rnw:260-262
###################################################
lznr.dir = variogram(log(zinc)~sqrt(dist), meuse, alpha = c(0, 45, 90, 135))
plot(lznr.dir, lznr.fit, as.table = TRUE)


###################################################
### code chunk number 19: gstat.Rnw:265-266
###################################################
print(plot(lznr.dir, lznr.fit, as.table = TRUE))


###################################################
### code chunk number 20: gstat.Rnw:283-286
###################################################
vgm.map = variogram(log(zinc)~sqrt(dist), meuse, cutoff = 1500, width = 100, 
	map = TRUE)
plot(vgm.map, threshold = 5)


###################################################
### code chunk number 21: gstat.Rnw:289-290
###################################################
print(plot(vgm.map, threshold = 5))


###################################################
### code chunk number 22: gstat.Rnw:303-314
###################################################
g = gstat(NULL, "log(zn)", log(zinc)~sqrt(dist), meuse)
g = gstat(g, "log(cd)", log(cadmium)~sqrt(dist), meuse)
g = gstat(g, "log(pb)", log(lead)~sqrt(dist), meuse)
g = gstat(g, "log(cu)", log(copper)~sqrt(dist), meuse)
v = variogram(g)
g = gstat(g, model = vgm(1, "Exp", 300, 1), fill.all = TRUE)
g.fit = fit.lmc(v, g)
g.fit
plot(v, g.fit)
vgm.map = variogram(g, cutoff = 1500, width = 100, map = TRUE)
plot(vgm.map, threshold = 5, col.regions = bpy.colors(), xlab = "", ylab = "")


###################################################
### code chunk number 23: gstat.Rnw:317-318
###################################################
print(plot(v, g.fit))


###################################################
### code chunk number 24: gstat.Rnw:321-322
###################################################
print(plot(vgm.map, threshold = 5, col.regions = bpy.colors(), ylab = "", xlab = ""))


