scrubber <-
function(text.var, rm.quote = TRUE, fix.comma = TRUE, ...){
    x <- reducer(Trim(clean(text.var)))
    if (rm.quote) {
        x  <- gsub('\"', "", x)
    }
    if (fix.comma) {
        x <- gsub(" ,", ",", x)
    }
    ncx <- nchar(x)
    x <- paste0(Trim(substring(x, 1, ncx - 1)), substring(x, ncx))
    x[is.na(text.var)] <- NA
    x
}

