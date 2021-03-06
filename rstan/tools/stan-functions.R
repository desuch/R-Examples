# This file is part of RStan
# Copyright (C) 2012, 2013, 2014, 2015 Jiqiang Guo and Benjamin Goodrich
#
# RStan is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# RStan is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

FILE <- dir(path = "tools", pattern = "txt$", full.names = TRUE)[1]
rosetta <- cbind(RFunction = NA_character_, 
                 read.table(FILE, header = TRUE, sep = ";", 
                 quote = NULL, stringsAsFactors = FALSE, strip.white = TRUE))
rosetta$RFunction <- ifelse(rosetta$StanFunction %in% unlist(sapply(search(), ls)),
                            rosetta$StanFunction, NA_character_)

rosetta$RFunction <- ifelse(grepl("^operator", rosetta$StanFunction), 
                            gsub("operator", "", rosetta$StanFunction), rosetta$RFunction)
  
rosetta$RFunction[rosetta$StanFunction == "append_col"] <- "cbind"
rosetta$RFunction[rosetta$StanFunction == "append_row"] <- "rbind"
rosetta$RFunction[grepl("^bernoulli_c", rosetta$StanFunction)] <- "pbinom"
rosetta$RFunction[rosetta$StanFunction == "bernoulli"] <- "dbinom"
rosetta$RFunction[rosetta$StanFunction == "bernoulli_log"] <- "dbinom"
rosetta$RFunction[rosetta$StanFunction == "bernoulli_rng"] <- "rbinom"
rosetta$RFunction[rosetta$StanFunction == "bessel_first_kind"] <- "besselJ"
rosetta$RFunction[rosetta$StanFunction == "bessel_second_kind"] <- "besselY"
rosetta$RFunction[rosetta$StanFunction == "beta"] <- "dbeta"
rosetta$RFunction[grepl("^beta_c", rosetta$StanFunction)] <- "pbeta"
rosetta$RFunction[rosetta$StanFunction == "beta_log"] <- "dbeta"
rosetta$RFunction[rosetta$StanFunction == "beta_rng"] <- "rbeta"
rosetta$RFunction[rosetta$StanFunction == "binomial"] <- "dbinom"
rosetta$RFunction[grepl("^binomial_c", rosetta$StanFunction)] <- "pbinomial"
rosetta$RFunction[rosetta$StanFunction == "binomial_coefficient_log"] <- "choose"
rosetta$RFunction[rosetta$StanFunction == "binomial_log"] <- "dbinom"
rosetta$RFunction[rosetta$StanFunction == "binomial_rng"] <- "rbinom"
rosetta$RFunction[rosetta$StanFunction == "block"] <- "subset"
rosetta$RFunction[rosetta$StanFunction == "categorical"] <- "dmultinom"
rosetta$RFunction[rosetta$StanFunction == "categorical_log"] <- "dmultinom"
rosetta$RFunction[rosetta$StanFunction == "categorical_rng"] <- "rmultinom"
rosetta$RFunction[rosetta$StanFunction == "cauchy"] <- "dcauchy"
rosetta$RFunction[rosetta$StanFunction == "cauchy_log"] <- "dcauchy"
rosetta$RFunction[rosetta$StanFunction == "cauchy_rng"] <- "rcauchy"
rosetta$RFunction[grepl("^cauchy_c", rosetta$StanFunction)] <- "pcauchy"
rosetta$RFunction[rosetta$StanFunction == "ceil"] <- "ceiling"
rosetta$RFunction[rosetta$StanFunction == "chi_square"] <- "dchisq"
rosetta$RFunction[rosetta$StanFunction == "chi_square_log"] <- "dchisq"
rosetta$RFunction[rosetta$StanFunction == "chi_square_rng"] <- "rchisq"
rosetta$RFunction[grepl("^chi_square_c", rosetta$StanFunction)] <- "pchisq"
rosetta$RFunction[rosetta$StanFunction == "cholesky_decompose"] <- "chol"
rosetta$RFunction[rosetta$StanFunction == "col"] <- "subset"
rosetta$RFunction[rosetta$StanFunction == "cols"] <- "NCOL"
rosetta$RFunction[rosetta$StanFunction == "cumulative_sum"] <- "cumsum"
rosetta$RFunction[rosetta$StanFunction == "diag_matrix"] <- "diag"
rosetta$RFunction[rosetta$StanFunction == "diagonal"] <- "diag"
rosetta$RFunction[rosetta$StanFunction == "dims"] <- "dim"
rosetta$RFunction[rosetta$StanFunction == "distance"] <- "dist"
rosetta$RFunction[rosetta$StanFunction == "dot_self"] <- "crossprod"
rosetta$RFunction[rosetta$StanFunction == "e"] <- "exp"
rosetta$RFunction[grepl("^eigenv", rosetta$StanFunction)] <- "eigen"
rosetta$RFunction[grepl("^erf", rosetta$StanFunction)] <- "pnorm"
rosetta$RFunction[rosetta$StanFunction == "exponential"] <- "dexp"
rosetta$RFunction[rosetta$StanFunction == "exponential_log"] <- "dexp"
rosetta$RFunction[rosetta$StanFunction == "exponential_rng"] <- "rexp"
rosetta$RFunction[grepl("^exponetial_c", rosetta$StanFunction)] <- "pexp"
rosetta$RFunction[rosetta$StanFunction == "fabs"] <- "abs"
rosetta$RFunction[rosetta$StanFunction == "fmax"] <- "max"
rosetta$RFunction[rosetta$StanFunction == "fmin"] <- "min"
rosetta$RFunction[rosetta$StanFunction == "fmod"] <- "%%"
rosetta$RFunction[rosetta$StanFunction == "gamma"] <- "dgamma"
rosetta$RFunction[rosetta$StanFunction == "gamma_log"] <- "dgamma"
rosetta$RFunction[rosetta$StanFunction == "gamma_rng"] <- "rgamma"
rosetta$RFunction[grepl("^gamma_c", rosetta$StanFunction)] <- "pgamma"
rosetta$RFunction[rosetta$StanFunction == "gamma_p"] <- "pgamma"
rosetta$RFunction[rosetta$StanFunction == "gamma_q"] <- "pgamma"
rosetta$RFunction[rosetta$StanFunction == "hypergeometric"] <- "dhyper"
rosetta$RFunction[rosetta$StanFunction == "hypergeometric_log"] <- "dhyper"
rosetta$RFunction[rosetta$StanFunction == "hypergeometric_rng"] <- "rhyper"
rosetta$RFunction[grepl("^hypergeometric_c", rosetta$StanFunction)] <- "phyper"
rosetta$RFunction[rosetta$StanFunction == "if_else"] <- "ifelse"
rosetta$RFunction[rosetta$StanFunction == "inverse"] <- "solve"
rosetta$RFunction[rosetta$StanFunction == "inverse_spd"] <- "solve"
rosetta$RFunction[rosetta$StanFunction == "inv_logit"] <- "plogis"
rosetta$RFunction[rosetta$StanFunction == "inv_Phi"] <- "qnorm"
rosetta$RFunction[rosetta$StanFunction == "is_inf"] <- "is.finite"
rosetta$RFunction[rosetta$StanFunction == "is_nan"] <- "is.nan"
rosetta$RFunction[rosetta$StanFunction == "log_determinant"] <- "determinant"
rosetta$RFunction[rosetta$StanFunction == "logistic"] <- "dlogis"
rosetta$RFunction[rosetta$StanFunction == "logistic_log"] <- "dlogis"
rosetta$RFunction[rosetta$StanFunction == "logistic_rng"] <- "rlogis"
rosetta$RFunction[grepl("^logistic_c", rosetta$StanFunction)] <- "plogis"
rosetta$RFunction[rosetta$StanFunction == "logit"] <- "plogis"
rosetta$RFunction[rosetta$StanFunction == "lognormal"] <- "dlnorm"
rosetta$RFunction[rosetta$StanFunction == "lognormal_log"] <- "dlnorm"
rosetta$RFunction[rosetta$StanFunction == "lognormal_rng"] <- "rlnorm"
rosetta$RFunction[grepl("^lognormal_c", rosetta$StanFunction)] <- "plnorm"
rosetta$RFunction[rosetta$StanFunction == "machine_precision"] <- ".Machine"
rosetta$RFunction[rosetta$StanFunction == "modified_bessel_first_kind"] <- "besselI"
rosetta$RFunction[rosetta$StanFunction == "multinomial"] <- "dmultinom"
rosetta$RFunction[rosetta$StanFunction == "multinomial_log"] <- "dmultinom"
rosetta$RFunction[rosetta$StanFunction == "multinomial_rng"] <- "rmultinom"
rosetta$RFunction[rosetta$StanFunction == "multi_normal"] <- "mvtnorm::dmvnorm"
rosetta$RFunction[rosetta$StanFunction == "multi_normal_log"] <- "mvtnorm::dmvnorm"
rosetta$RFunction[rosetta$StanFunction == "multi_normal_rng"] <- "mvtnorm::rmvnorm"
rosetta$RFunction[rosetta$StanFunction == "multi_student_t"] <- "mvtnorm::dmvt"
rosetta$RFunction[rosetta$StanFunction == "multi_student_t_log"] <- "mvtnorm::dmvt"
rosetta$RFunction[rosetta$StanFunction == "multi_student_t_rng"] <- "mvtnorm::rmvt"
rosetta$RFunction[rosetta$StanFunction == "negative_infinity"] <- "Inf"
rosetta$RFunction[rosetta$StanFunction == "neg_binomial"] <- "dnbinom"
rosetta$RFunction[rosetta$StanFunction == "neg_binomial_log"] <- "dnbinom"
rosetta$RFunction[rosetta$StanFunction == "neg_binomial_rng"] <- "rnbinom"
rosetta$RFunction[grepl("^neg_binomial_c", rosetta$StanFunction)] <- "pnbinom"
rosetta$RFunction[rosetta$StanFunction == "neg_binomial_2"] <- "dnbinom"
rosetta$RFunction[rosetta$StanFunction == "neg_binomial_2_log"] <- "dnbinom"
rosetta$RFunction[rosetta$StanFunction == "neg_binomial_2_log_log"] <- "dnbinom"
rosetta$RFunction[rosetta$StanFunction == "neg_binomial_2_rng"] <- "rnbinom"
rosetta$RFunction[grepl("^neg_binomial_2_c", rosetta$StanFunction)] <- "pnbinom"
rosetta$RFunction[rosetta$StanFunction == "normal"] <- "dnorm"
rosetta$RFunction[rosetta$StanFunction == "normal_log"] <- "dnorm"
rosetta$RFunction[rosetta$StanFunction == "normal_rng"] <- "rnorm"
rosetta$RFunction[grepl("^normal_c", rosetta$StanFunction)] <- "pnorm"
rosetta$RFunction[rosetta$StanFunction == "not_a_number"] <- "NaN"
rosetta$RFunction[rosetta$StanFunction == "num_elements"] <- "length"
rosetta$RFunction[rosetta$StanFunction == "operator./"] <- "/"
rosetta$RFunction[rosetta$StanFunction == "operator.*"] <- "*"
rosetta$RFunction[rosetta$StanFunction == "operator*" &
                  grepl("[matrix|vector]", rosetta$Arguments) &
                  !grepl("[real|int]", rosetta$Arguments)] <- "%*%"
rosetta$RFunction[rosetta$StanFunction == "operator\\"] <- NA_character_
rosetta$RFunction[rosetta$StanFunction == "operator\'"] <- "t"
rosetta$RFunction[rosetta$StanFunction == "phi"] <- "pnorm"
rosetta$RFunction[rosetta$StanFunction == "phi_approx"] <- "pnorm"
rosetta$RFunction[rosetta$StanFunction == "pi"] <- "pi"
rosetta$RFunction[rosetta$StanFunction == "poisson"] <- "dpois"
rosetta$RFunction[rosetta$StanFunction == "poisson_log"] <- "dpois"
rosetta$RFunction[rosetta$StanFunction == "poisson_log_log"] <- "dpois"
rosetta$RFunction[rosetta$StanFunction == "poisson_rng"] <- "rpois"
rosetta$RFunction[rosetta$StanFunction == "poisson_log_rng"] <- "rpois"
rosetta$RFunction[grepl("^poisson_c", rosetta$StanFunction)] <- "ppois"
rosetta$RFunction[rosetta$StanFunction == "positive_infinity"] <- "Inf"
rosetta$RFunction[rosetta$StanFunction == "pow"] <- "^"
rosetta$RFunction[rosetta$StanFunction == "qr_Q"] <- "qr.Q"
rosetta$RFunction[rosetta$StanFunction == "qr_Q"] <- "qr.R"
rosetta$RFunction[grepl("^rep_c", rosetta$StanFunction)] <- "rep"
rosetta$RFunction[rosetta$StanFunction == "row"] <- "subset"
rosetta$RFunction[rosetta$StanFunction == "rows"] <- "NROW"
rosetta$RFunction[rosetta$StanFunction == "segment"] <- "subset"
rosetta$RFunction[rosetta$StanFunction == "singular_values"] <- "svd"
rosetta$RFunction[rosetta$StanFunction == "size"] <- "dim"
rosetta$RFunction[grepl("^sort_c", rosetta$StanFunction)] <- "sort"
rosetta$RFunction[rosetta$StanFunction == "square"] <- "pow"
rosetta$RFunction[rosetta$StanFunction == "squared_distance"] <- "dist"
rosetta$RFunction[rosetta$StanFunction == "step"] <- NA_character_
rosetta$RFunction[rosetta$StanFunction == "student_t"] <- "dt"
rosetta$RFunction[rosetta$StanFunction == "student_t_log"] <- "dt"
rosetta$RFunction[rosetta$StanFunction == "student_t_rng"] <- "rt"
rosetta$RFunction[grepl("^student_t_c", rosetta$StanFunction)] <- "pt"
rosetta$RFunction[grepl("^sub_c", rosetta$StanFunction)] <- "subset"
rosetta$RFunction[rosetta$StanFunction == "tgamma"] <- "gamma"
rosetta$RFunction[rosetta$StanFunction == "to_array_1d"] <- "as.vector"
rosetta$RFunction[rosetta$StanFunction == "to_matrix"] <- "as.matrix"
rosetta$RFunction[rosetta$StanFunction == "to_row_vector"] <- "as.vector"
rosetta$RFunction[rosetta$StanFunction == "to_vector"] <- "as.vector"
rosetta$RFunction[rosetta$StanFunction == "trace"] <- NA_character_
rosetta$RFunction[rosetta$StanFunction == "uniform"] <- "dunif"
rosetta$RFunction[rosetta$StanFunction == "uniform_log"] <- "dunif"
rosetta$RFunction[rosetta$StanFunction == "uniform_rng"] <- "runif"
rosetta$RFunction[grepl("^uniform_c", rosetta$StanFunction)] <- "punif"
rosetta$RFunction[rosetta$StanFunction == "variance"] <- "var"
rosetta$RFunction[rosetta$StanFunction == "weibull"] <- "dweibull"
rosetta$RFunction[rosetta$StanFunction == "weibull_log"] <- "dweibull"
rosetta$RFunction[rosetta$StanFunction == "weibull_rng"] <- "rweibull"
rosetta$RFunction[grepl("^weibull_c", rosetta$StanFunction)] <- "pweibull"
rosetta$RFunction[rosetta$StanFunction == "wishart_rng"] <- "rWishart"

SS <- rosetta$Arguments == "~"
SSnames <- rosetta$StanFunction[SS]
matches <- rosetta[!SS & rosetta$StanFunction %in% paste(SSnames, "log", sep = "_"),]
matches$Arguments <- sapply(strsplit(matches$Arguments, split = ", ", fixed = TRUE), 
                            FUN = function(x) {
                              paste0("(", paste(tail(x, -1), collapse = ", "))
                              })
matches$StanFunction <- gsub("_log$", "", matches$StanFunction)
rosetta <- rbind(cbind(rosetta[!SS,], SamplingStatement = FALSE),
                 cbind(matches, SamplingStatement = TRUE))
rosetta <- rosetta[order(rosetta$StanFunction, !rosetta$SamplingStatement),]
rownames(rosetta) <- NULL

save(rosetta, file = "R/sysdata.rda")
tools::resaveRdaFiles("R/sysdata.rda")
