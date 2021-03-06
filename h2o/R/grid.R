#'
#' H2O Grid Support
#'
#' Provides a set of functions to launch a grid search and get
#' its results.

#-------------------------------------
# Grid-related functions start here :)
#-------------------------------------

#'
#' Launch grid search with given algorithm and parameters.
#'
#' @param algorithm  Name of algorithm to use in grid search (gbm, randomForest, kmeans, glm, deeplearning, naivebayes, pca).
#' @param grid_id  (Optional) ID for resulting grid search. If it is not specified then it is autogenerated.
#' @param ...  arguments describing parameters to use with algorithm (i.e., x, y, training_frame).
#'        Look at the specific algorithm - h2o.gbm, h2o.glm, h2o.kmeans, h2o.deepLearning - for available parameters.
#' @param hyper_params  List of lists of hyper parameters (i.e., \code{list(ntrees=c(1,2), max_depth=c(5,7))}).
#' @param is_supervised  (Optional) If specified then override the default heuristic which decides if the given algorithm
#'        name and parameters specify a supervised or unsupervised algorithm.
#' @param do_hyper_params_check  Perform client check for specified hyper parameters. It can be time expensive for
#'        large hyper space.
#' @param search_criteria  (Optional)  List of control parameters for smarter hyperparameter search.  The default
#'        strategy 'Cartesian' covers the entire space of hyperparameter combinations.  Specify the
#'        'RandomDiscrete' strategy to get random search of all the combinations of your hyperparameters.  RandomDiscrete
#'        should be usually combined with at least one early stopping criterion,
#'        max_models and/or max_runtime_secs, e.g. \code{list(strategy = "RandomDiscrete", max_models = 42, max_runtime_secs = 28800)}
#'        or  \code{list(strategy = "RandomDiscrete", stopping_metric = "AUTO", stopping_tolerance = 0.001, stopping_rounds = 10)}
#'        or  \code{list(strategy = "RandomDiscrete", stopping_metric = "misclassification", stopping_tolerance = 0.00001, stopping_rounds = 5)}.
#' @importFrom jsonlite toJSON
#' @examples
#' \donttest{
#' library(h2o)
#' library(jsonlite)
#' h2o.init()
#' iris.hex <- as.h2o(iris)
#' grid <- h2o.grid("gbm", x = c(1:4), y = 5, training_frame = iris.hex,
#'                  hyper_params = list(ntrees = c(1,2,3)))
#' # Get grid summary
#' summary(grid)
#' # Fetch grid models
#' model_ids <- grid@@model_ids
#' models <- lapply(model_ids, function(id) { h2o.getModel(id)})
#' }
#' @export
h2o.grid <- function(algorithm,
                     grid_id,
                     ...,
                     hyper_params = list(),
                     is_supervised = NULL,
                     do_hyper_params_check = FALSE,
                     search_criteria = NULL)
{
  # Extract parameters
  dots <- list(...)
  algorithm <- .h2o.unifyAlgoName(algorithm)
  model_param_names <- names(dots)
  hyper_param_names <- names(hyper_params)
  # Reject overlapping definition of parameters
  if (any(model_param_names %in% hyper_param_names)) {
    overlapping_params <- intersect(model_param_names, hyper_param_names)
    stop(paste0("The following parameters are defined as common model parameters and also as hyper parameters: ",
                .collapse(overlapping_params), "! Please choose only one way!"))
  }
  # Get model builder parameters for this model
  all_params <- .h2o.getModelParameters(algo = algorithm)

  # Prepare model parameters
  params <- .h2o.prepareModelParameters(algo = algorithm, params = dots, is_supervised = is_supervised)
  # Validation of input key
  .key.validate(params$key_value)
  # Validate all hyper parameters against REST API end-point
  if (do_hyper_params_check) {
    lparams <- params
    # Generate all combination of hyper parameters
    expanded_grid <- expand.grid(lapply(hyper_params, function(o) { 1:length(o) }))
    # Get algo REST version
    algo_rest_version <- .h2o.getAlgoVersion(algo = algorithm)
    # Verify each defined point in hyper space against REST API
    apply(expanded_grid,
          MARGIN = 1,
          FUN = function(permutation) {
      # Fill hyper parameters for this permutation
      hparams <- lapply(hyper_param_names, function(name) { hyper_params[[name]][[permutation[[name]]]] })
      names(hparams) <- hyper_param_names
      params_for_validation <- lapply(append(lparams, hparams), function(x) { if(is.integer(x)) x <- as.numeric(x); x })
      # We have to repeat part of work used by model builders
      params_for_validation <- .h2o.checkAndUnifyModelParameters(algo = algorithm, allParams = all_params, params = params_for_validation)
      .h2o.validateModelParameters(algorithm, params_for_validation, h2oRestApiVersion = algo_rest_version)
    })
  }

  # Verify and unify the parameters
  params <- .h2o.checkAndUnifyModelParameters(algo = algorithm, allParams = all_params,
                                                  params = params, hyper_params = hyper_params)
  # Validate and unify hyper parameters
  hyper_values <- .h2o.checkAndUnifyHyperParameters(algo = algorithm,
                                                        allParams = all_params, hyper_params = hyper_params,
                                                        do_hyper_params_check = do_hyper_params_check)
  # Append grid parameters in JSON form
  params$hyper_parameters <- toJSON(hyper_values, digits=99)

  if( !is.null(search_criteria)) {
      # Append grid search criteria in JSON form. 
      # jsonlite unfortunately doesn't handle scalar values so we need to serialize ourselves.
      keys = paste0("\"", names(search_criteria), "\"", "=")
      vals <- lapply(search_criteria, function(val) { if(is.numeric(val)) val else paste0("\"", val, "\"") })
      body <- paste0(paste0(keys, vals), collapse=",")
      js <- paste0("{", body, "}", collapse="")
      params$search_criteria <- js
  }

  # Append grid_id if it is specified
  if (!missing(grid_id)) params$grid_id <- grid_id

  # Trigger grid search job
  res <- .h2o.__remoteSend(.h2o.__GRID(algorithm), h2oRestApiVersion = 99, .params = params, method = "POST")
  grid_id <- res$job$dest$name
  job_key <- res$job$key$name
  # Wait for grid job to finish
  .h2o.__waitOnJob(job_key)

  h2o.getGrid(grid_id = grid_id)
}

#' Get a grid object from H2O distributed K/V store.
#'
#' @param grid_id  ID of existing grid object to fetch
#' @param sort_by Sort the models in the grid space by a metric. Choices are "logloss", "residual_deviance", "mse", "auc", "r2", "accuracy", "precision", "recall", "f1", etc.
#' @param decreasing Specify whether sort order should be decreasing
#' @examples
#' \donttest{
#' library(h2o)
#' library(jsonlite)
#' h2o.init()
#' iris.hex <- as.h2o(iris)
#' h2o.grid("gbm", grid_id = "gbm_grid_id", x = c(1:4), y = 5,
#'          training_frame = iris.hex, hyper_params = list(ntrees = c(1,2,3)))
#' grid <- h2o.getGrid("gbm_grid_id")
#' # Get grid summary
#' summary(grid)
#' # Fetch grid models
#' model_ids <- grid@@model_ids
#' models <- lapply(model_ids, function(id) { h2o.getModel(id)})
#' }
#' @export
h2o.getGrid <- function(grid_id, sort_by, decreasing) {
  json <- .h2o.__remoteSend(method = "GET", h2oRestApiVersion = 99, .h2o.__GRIDS(grid_id, sort_by, decreasing))
  class <- "H2OGrid"
  grid_id <- json$grid_id$name
  model_ids <- lapply(json$model_ids, function(model_id) { model_id$name })
  hyper_names <- lapply(json$hyper_names, function(name) { name })
  failed_params <- lapply(json$failed_params, function(param) {
                          x <- if (is.null(param) || is.na(param)) NULL else param
                          x
                        })
  failure_details <- lapply(json$failure_details, function(msg) { msg })
  failure_stack_traces <- lapply(json$failure_stack_traces, function(msg) { msg })
  failed_raw_params <- if (is.list(json$failed_raw_params)) matrix(nrow=0, ncol=0) else json$failed_raw_params

  new(class,
      grid_id = grid_id,
      model_ids = model_ids,
      hyper_names = hyper_names,
      failed_params = failed_params,
      failure_details = failure_details,
      failure_stack_traces = failure_stack_traces,
      failed_raw_params = failed_raw_params,
      summary_table     = json$summary_table
      )
}


