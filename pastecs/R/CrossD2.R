"CrossD2" <-
function(series, series2, lags=c(1, nrow(series)/3), step=1, plotit=TRUE, add=FALSE, ...) {
    call <- match.call()
	data1 <- deparse(substitute(series))
	data2 <- deparse(substitute(series2))
	if (is.null(class(series)) || class(series)[1] != "mts")
		stop("series must be a multiple regular time series object")
	if (is.null(class(series2)) || class(series2)[1] != "mts")
		stop("series2 must be a multiple regular time series object")

	Unit <- attr(series, "units")
	if (nrow(series) != nrow(series2))
		stop("series and series2 must have same row number")
	if (ncol(series) != ncol(series2))
		stop("series and series2 must have same column number")	
	UnitTxt <- GetUnitText(series)
	# Test the length of the series, range and step...
	n <- nrow(series)
	if (length(lags) < 2)
	  	stop("lags must be a vector with 2 values: (min, max)")
	if (lags[1] < 1 || lags[1] > n/3)
	   	stop("lags must be larger or equal to 1, and smaller or equal to n/3")
	if (lags[2] < 1 || lags[2] > n/3)
	   	stop("lags must be larger or equal to 1, and smaller or equal to n/3")	
	Lags.vec <- seq(lags[1], lags[2], step)
	if (length(Lags.vec) < 2)
	   	stop("Less than 2 lags. Redefine intervals or step")
	D2.vec <- Lags.vec
	    
	# Calculate CrossD2 for each lag
	x1 <- as.matrix(series)
	x2 <- as.matrix(series2)
	for (i in 1:length(Lags.vec)) {
		k <- Lags.vec[i]
		g1 <- x1[1:(n-k),]
		g2 <- x2[(k+1):n,]
		sd1 <- apply(g1, 2, var)^.5
		sd2 <- apply(g2, 2, var)^.5
		g1 <- t(t(g1)/sd1)
		g2 <- t(t(g2)/sd2)
		m1 <- apply(g1, 2, mean)
		m2 <- apply(g2, 2, mean)
		m <- m1 - m2
		g1 <- scale(g1)
		g2 <- scale(g2)
		S1 <- t(g1) %*% g1
		S2 <- t(g2) %*% g2
		S <- solve((S1 + S2)/(2*(n-k)-2))
		D2.vec[i] <- (t(m) %*% S) %*% m 
	}
	res <- list(lag=Lags.vec, D2=D2.vec)
	as.data.frame(res)
	res$call <- call
	res$data <- data1
	res$data2 <- data2
	res$type <- "CrossD2"
	res$units.text <- UnitTxt
	attr(res, "units") <- Unit
		
	# Do we need to plot the graph?
	if (plotit == TRUE) {
		if (add == TRUE) {
			lines(res$lag, res$D2, ...)
		} else {
			plot(res$lag, res$D2, type="b", xlab=paste("lag (", UnitTxt, ")", sep=""), ylab="D2", main=paste("CrossD2 for:", data1, "versus", data2), ...)
		}
	}
	class(res) <- "D2"
	res 	# Return results
}
