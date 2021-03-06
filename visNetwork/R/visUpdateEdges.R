#' Function to update edges information, with shiny only.
#'
#' Function to update edges information, with shiny only. You can also use this function passing new edges.
#' The link is based on id.
#' 
#'@param graph : a \code{\link{visNetworkProxy}}  object
#' @param edges : data.frame with edges informations. See \link{visEdges}
#' \itemize{
#'  \item{"id"}{ : edge id, for update}
#'  \item{"from"}{ : node id of begin of the edge}
#'  \item{"to"}{ : node id of end of the edge}
#'  \item{"label"}{ : label of the edge}
#'  \item{"value"}{ : size of the node}
#'  \item{"title"}{ : tooltip of the node}
#'  \item{...}{}
#'}
#'
#'@seealso \link{visNodes} for nodes options, \link{visEdges} for edges options, \link{visGroups} for groups options, 
#'\link{visLegend} for adding legend, \link{visOptions} for custom option, \link{visLayout} & \link{visHierarchicalLayout} for layout, 
#'\link{visPhysics} for control physics, \link{visInteraction} for interaction, \link{visNetworkProxy} & \link{visFocus} & \link{visFit} for animation within shiny,
#'\link{visDocumentation}, \link{visEvents}, \link{visConfigure} ...
#' 
#' @examples
#'\dontrun{
#'
#'# have a look to : 
#'shiny::runApp(system.file("shiny", package = "visNetwork"))
#'
#'}
#'
#'@export

visUpdateEdges <- function(graph, edges){

  if(!any(class(graph) %in% "visNetwork_Proxy")){
    stop("Can't use visUpdateEdges with visNetwork object. Only within shiny & using visNetworkProxy")
  }
  
  data <- list(id = graph$id, edges = edges)
  
  graph$session$sendCustomMessage("visShinyUpdateEdges", data)

  graph
}
