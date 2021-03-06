#ALG: itree copies this direclty from rpart.

# sccs @(#)model.frame.rpart.s	1.3 01/21/97
model.frame.itree <- function(formula, ...)
{
	m <- formula$model
	if(!is.null(m))
		return(m)
	oc <- formula$call
	if(substring(deparse(oc[[1]]), 1L, 7L) == "predict") {
		m <- eval(oc$newdata)
		if(is.null(attr(m, "terms"))) {
			object <- eval(oc$object)
			m <- model.frame(object$terms, m, na.itree)
		}
		return(m)
	}
	while(deparse(oc[[1L]]) != "itree") oc <- eval(oc[[2]])$call
	oc$subset <- names(formula$where)
	oc$method <- formula$method
	eval(oc)
}

