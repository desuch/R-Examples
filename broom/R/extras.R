# this contains functions that are useful to use with broom, but are not
# actually involved in tidying objects.

#' Set up bootstrap replicates of a dplyr operation
#'
#' @param df a data frame
#' @param m number of bootstrap replicates to perform
#'
#' @details This code originates from Hadley Wickham (with a few small
#' corrections) here:
#'
#' https://github.com/hadley/dplyr/issues/269
#'
#' Some examples can be found at
#'
#' https://github.com/dgrtwo/broom/blob/master/vignettes/bootstrapping.Rmd
#'
#' @examples
#'
#' library(dplyr)
#' mtcars %>% bootstrap(10) %>% do(tidy(lm(mpg ~ wt, .)))
#' 
#' @export
bootstrap <- function(df, m) {
    n <- nrow(df)
    
    attr(df, "indices") <- replicate(m, sample(n, replace = TRUE) - 1,
                                     simplify = FALSE)
    attr(df, "drop") <- TRUE
    attr(df, "group_sizes") <- rep(n, m)
    attr(df, "biggest_group_size") <- n
    attr(df, "labels") <- data.frame(replicate = 1:m)
    attr(df, "vars") <- list(quote(replicate))
    class(df) <- c("grouped_df", "tbl_df", "tbl", "data.frame")
    
    df
}
