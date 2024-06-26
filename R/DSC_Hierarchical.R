#######################################################################
# stream -  Infrastructure for Data Stream Mining
# Copyright (C) 2013 Michael Hahsler, Matthew Bolanos, John Forrest
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


#' Hierarchical Micro-Cluster Reclusterer
#'
#' Macro Clusterer.
#' Implementation of hierarchical clustering to recluster a set of
#' micro-clusters.
#'
#' Please refer to [hclust()] for more details on the behavior of the
#' algorithm.
#'
#' [update()] and [`recluster()`] invisibly return the assignment of the data points
#' to clusters.
#'
#' **Note** that this clustering cannot be updated iteratively and every time it is
#' used for (re)clustering, the old clustering is deleted.
#'
#' @family DSC_Macro
#'
#' @param formula `NULL` to use all features in the stream or a model [formula] of the form `~ X1 + X2`
#'   to specify the features used for clustering. Only `.`, `+` and `-` are currently
#'   supported in the formula.
#' @param k The number of desired clusters.
#' @param h Height where to cut the dendrogram.
#' @param method the agglomeration method to be used. This should be (an
#'   unambiguous abbreviation of) one of `"ward"`, `"single"`, `"complete"`, "`average"`,
#'   `"mcquitty"`, `"median"` or `"centroid"`.
#' @param min_weight micro-clusters with a weight less than this will be
#'   ignored for reclustering.
#' @param description optional character string to describe the clustering method.
#' @return A list of class [DSC], [DSC_R], [DSC_Macro], and
#'   `DSC_Hierarchical`. The list contains the following items:
#'
#' \item{description}{The name of the algorithm in the DSC object.}
#' \item{RObj}{The underlying R object.}
#' @author Michael Hahsler
#' @examples
#' stream <- DSD_Gaussians(k = 3, d = 2, noise = 0.05)
#'
#' # Use a moving window for "micro-clusters and recluster with HC (macro-clusters)
#' cl <- DSC_TwoStage(
#'   micro = DSC_Window(horizon = 100),
#'   macro = DSC_Hierarchical(h = .1, method = "single")
#' )
#'
#' update(cl, stream, 500)
#' cl
#'
#' plot(cl, stream)
#' @export
DSC_Hierarchical <- function(formula = NULL,
  k = NULL,
  h = NULL,
  method = "complete",
  min_weight = NULL,
  description = NULL) {
  hierarchical <- hierarchical$new(
    k = k,
    h = h,
    method = method,
    min_weight = min_weight
  )

  if (is.null(description))
    description <- paste("Hierarchical (", method, ")",
      sep = '')

  l <- list(description = description,
    formula = formula,
    RObj = hierarchical)

  class(l) <- c("DSC_Hierarchical", "DSC_Macro", "DSC_R", "DSC")
  l
}


### calculate centroids
.centroids <- function(centers, weights, assignment) {
  macroID <- unique(assignment)
  macroID <- macroID[!is.na(macroID)]
  assignment[is.na(assignment)] <- -1 ### prevent NAs in matching

  cs <- t(sapply(
    macroID,
    FUN =
      function(i) {
        take <- assignment == i
        colSums(centers[take, , drop = FALSE] *
            matrix(
              weights[take],
              nrow = sum(take),
              ncol = ncol(centers)
            )) /
          sum(weights[take])
      }
  ))

  ### handle 1-d case
  if (ncol(centers) == 1)
    cs <- t(cs)
  rownames(cs) <- NULL
  colnames(cs) <- colnames(centers)

  cs <- data.frame(cs)

  ws <- sapply(
    macroID,
    FUN =
      function(i)
        sum(weights[assignment == i], na.rm = TRUE)
  )

  list(centers = cs, weights = ws)
}


hierarchical <- setRefClass(
  "hierarchical",
  fields = list(
    data	= "data.frame",
    dataWeights = "numeric",
    d	= "matrix",
    method  = "character",
    k	= "ANY",
    h = "ANY",
    assignment = "numeric",
    details = "ANY",
    centers	= "data.frame",
    weights = "numeric",
    min_weight = "numeric",
    colnames = "ANY"
  ),

  methods = list(
    initialize = function(k = NULL,
      h = NULL,
      method	= "complete",
      min_weight = NULL) {
      if (is.null(k) &&
          is.null(h))
        stop("Either h or k needs to be specified.")
      if (!is.null(k) &&
          !is.null(h))
        stop("Only h or k  can be specified.")

      if (is.null(min_weight))
        min_weight <<- 0
      else
        min_weight <<- as.numeric(min_weight)

      data	<<- data.frame()
      dataWeights	<<- numeric()
      weights	<<- numeric()
      centers	<<- data.frame()
      method	<<- method
      k	<<- k
      h <<- h

      colnames <<- NULL

      .self
    }

  ),
)

hierarchical$methods(
  cluster = function(x,  weight = rep(1, nrow(x)), ...) {
    #if(nrow(x)==1)
    #  warning("DSC_Hierarchical does not support iterative updating! Old data is overwritten.")


    ### filter weak clusters
    if (min_weight > 0) {
      x <- x[weight > min_weight, ]
      weight <- weight[weight > min_weight]
    }

    data <<- x
    dataWeights <<- weight

    if ((!is.null(k) && nrow(data) <= k) || nrow(data) < 2) {
      centers <<- x
      weights <<- weight
    } else{
      hierarchical <- hclust(d = dist(x), method = method)
      details <<- hierarchical

      if (is.null(k) || k < length(unlist(hierarchical['height'])))
        assignment <<- cutree(hierarchical, k = k, h = h)
      else
        assignment <<- 1

      ### find centroids
      centroids <- .centroids(x, weight, assignment)
      centers <<- centroids$centers
      weights <<- centroids$weights
    }

    invisible(data.frame(.class = assignment))
  },

  get_microclusters = function(...) {
    .nodots(...)
    data
  },
  get_microweights = function(...) {
    .nodots(...)
    dataWeights
  },

  get_macroclusters = function(...) {
    .nodots(...)
    centers
  },
  get_macroweights = function(...) {
    .nodots(...)
    weights
  },

  microToMacro = function(micro = NULL, ...) {
    .nodots(...)

    if (is.null(micro))
      micro <- seq_len(nrow(data))
    structure(assignment[micro], names = micro)
  }
)
