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


#' Animates Plots of the Clustering Process
#'
#' Generates an animation of a data stream clustering process.
#'
#' Animations are recorded using the library animation and can be replayed
#' (which gives a smoother experience since the is no more computation done)
#' and saved in various formats (see Examples section below).
#'
#' **Note:** You need to install package \pkg{animation} and its system requirements.
#'
#' @family DSC
#' @family plot
#' @family evaluation
#'
#' @param dsd a [DSD]
#' @param dsc a [DSC]
#' @param measure the evaluation measure that should be graphed below the
#'  animation (see [evaluate_cluster()].)
#' @param horizon the number of points displayed at once/used for evaluation.
#' @param n the number of points to be plotted
#' @param wait the time interval between each frame
#' @param plot.args a list with plotting parameters for the clusters.
#' @param type,assign,assignmentMethod,noise are passed on to [evaluate_cluster()] to calculate the
#'   evaluation measure.
#' @param ... extra arguments are added to `plot.args`.
#' @author Michael Hahsler
#' @seealso [animation::ani.replay()] for replaying and saving animations.
#' @examples
#' if (interactive()) {
#' stream <- DSD_Benchmark(1)
#'
#' ### animate the clustering process with evaluation
#' ### Note: we choose to exclude noise points from the evaluation
#' ###       measure calculation, even if the algorithm would assign
#' ###       them to a cluster.
#' dbstream <- DSC_DBSTREAM(r = .04, lambda = .1, gaptime = 100, Cm = 3,
#'   shared_density = TRUE, alpha = .2)
#'
#' animate_cluster(dbstream, stream, horizon = 100, n = 5000,
#'   measure = "crand", type = "macro", assign = "micro", noise = "exclude",
#'   plot.args = list(xlim = c(0, 1), ylim = c(0, 1), shared = TRUE))
#' }
#' @export
animate_cluster <-
  function(dsc,
    dsd,
    measure = NULL,
    horizon = 100,
    n = 1000,
    type = c("auto", "micro", "macro"),
    assign = "micro",
    assignmentMethod = c("auto", "model", "nn"),
    noise = c("class", "exclude"),
    wait = .1,
    plot.args = NULL,
    ...) {
    ### NOTE: ignore is deprecated!!!
    assignmentMethod <- match.arg(assignmentMethod)
    noise <- match.arg(noise[1L], c("class", "exclude", "ignore"))

    if (noise == "ignore") {
      noise <-
        "exclude"
      warning("noise = 'ignore' is deprecated used noise = 'exclude'")
    }

    type <- get_type(dsc, type)

    cluster.ani(
      dsc,
      dsd,
      measure,
      horizon,
      n,
      type,
      assign,
      assignmentMethod,
      noise,
      wait,
      plot.args,
      ...
    )
  }


## work horse
cluster.ani <- function(dsc,
  dsd,
  measure,
  horizon,
  n,
  type,
  assign,
  assignmentMethod,
  noise,
  wait,
  plot.args,
  ...) {
  if (!.installed("animation"))
    stop (
      "Install package animation (and, if necessary, the needed libraries for package magick)."
    )
  requireNamespace("animation")

  if (is.null(plot.args))
    plot.args <- list()
  plot.args <- c(plot.args, list(...))

  if (!is.null(measure) && length(measure) > 1)
    stop("animate_cluster can only use a single measure!")

  rounds <- n %/% horizon

  op <- par(no.readonly = TRUE)
  on.exit(par(op))
  animation::ani.record(reset = TRUE)

  ## setup layout for dsc + eval measure plotting (animate_cluster)
  if (!is.null(dsc) && !is.null(measure)) {
    layout(matrix(c(1, 2), 2, 1, byrow = TRUE), heights = c(3, 1.5))
    evaluation <-
      data.frame(points = seq(
        from = 1,
        by = horizon,
        length.out = rounds
      ))
    evaluation[[measure]] <- NA_real_
  }

  for (i in 1:rounds) {
    d <- DSD_Memory(dsd, n = horizon, loop = FALSE)

    if (!is.null(dsc)) {
      ## for animate_cluster

      ## evaluate first
      if (!is.null(measure)) {
        reset_stream(d)
        evaluation[i, 2] <- evaluate(dsc,
          d,
          measure,
          NULL,
          horizon,
          type,
          assign,
          assignmentMethod,
          noise,
          ...)
      }

      ## then cluster
      reset_stream(d)
      update(dsc, d, horizon)

      ## then do plotting
      if (!is.null(measure))
        par(mar = c(4.1, 4.1, 2.1, 2.1))
      reset_stream(d)
      ## no warnings for 0 clusters
      suppressWarnings(do.call(plot, c(list(dsc, d, n = horizon), plot.args)))

      if (!is.null(measure)) {
        par(mar = c(2.1, 4.1, 1.1, 2.1))

        if (all(is.na(evaluation[, 2])))
          plot(
            evaluation,
            type = "l",
            col = "blue",
            ylim = c(0, 1)
          )
        else {
          plot(evaluation,
            type = "l",
            col = "blue",
            #ylim=c(0,1),
            ann = FALSE)
          title(ylab = measure)
        }
      }

    } else{
      ## plot just data for animate_data
      suppressWarnings(do.call(plot, c(list(d, n = horizon), plot.args)))
    }

    animation::ani.record()
    if (wait > 0)
      Sys.sleep(wait)

  }

  if (!is.null(measure))
    evaluation
  else
    invisible(NULL)
}