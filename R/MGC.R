#######################################################################
# Moving Generator -  Infrastructure for Moving Streams
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

#' Moving Generator Cluster
#'
#' Creates an evolving cluster for use as a component of a [DSD_MG] data stream.
#'
#' An `MGC` describes a single cluster for use as a component in a [DSD_MG].
#' Different [MGC]s  allow the user to express
#' different cluster behaviors within a single data stream. Static, (i.e., not moving)
#' clusters are defined as:
#'
#'   - `MGC_Static` cluster positions are fixed
#'
#'   - `MGC_Noise` allows to add random noise.
#'
#' Moving (evolving) clusters are defined as:
#'
#'   - `MGC_Linear` creates an evolving cluster for a who's behavior is determined by
#'      keyframes. Several keyframe
#'      functions are provided to create, add and remove keyframes.
#'      See Examples section for details.
#'
#'   - `MGC_Function` allows to specify `density`, `center`, and `parameter`
#'      as a function of time.
#'
#'   - `MGC_Random` allows for a creation of a cluster that follows a random walk.
#'
#' Cluster shapes can be specified using the functions:
#'
#'  - `Shape_Gaussian`
#'  - `Shape_Block`
#'
#'  New
#' shapes can be defined as a function with parameters `center` and `parameter` that return a single new
#' point. Here is an example:
#' ```
#' Shape_Gaussian <- function(center, parameter)
#'    rnorm(length(center), mean = center, sd = parameter)
#' ```
#'
#' @param center A list that defines the center of the cluster. The list should
#' have a length equal to the dimensionality. For `MGC_Function`, this
#' list consists of functions that define the movement of the cluster. For
#' `MGC_Random`, this attribute defines the beginning location for the
#' `MGC` before it begins moving.
#' @param density The density of the cluster. For `MGC_Function, this
#' attribute is a function and defines the density of a cluster (i.e., how many points it creates)
#' at each given timestamp.
#' @param dimension Dimensionality of the data stream.
#' @param keyframelist a list of keyframes to initialize the `MGC_Linear`
#' object with.
#' @param parameter Parameters for the shape. For the default shape
#' `Shape_Gaussian` the parameter is the standard deviation, one per
#' dimension. If a single value is specified then it is recycled for all
#' dimensions.
#' @param randomness The maximum amount the cluster will move during one time
#' step.
#' @param range The area in which the noise should appear.
#' @param reset Should the cluster reset to the first keyframe (time 0) after
#' this keyframe is finished?
#' @param shape A function creating the shape of the cluster. It gets passed on
#' the parameters argument from above. Available functions are
#' `Shape_Gaussian` (the parameters are a vector containing standard
#' deviations) and `Shape_Block` (parameters are the dimensions of the
#' uniform block).
#' @param time The time stamp the keyframe should be located or which keyframe
#' should be removed.
#' @param x An object of class `MGC_Linear`.
#' @param ... Further arguments.
#' @author Matthew Bolanos
#' @seealso [DSD_MG] for details on how to use an `MGC` within
#' a [DSD].
#' @examples
#' MGC()
#'
#' ### Two static clusters (Gaussian with sd of .1 and a Block with width .4)
#' ###   with added noise
#' stream <- DSD_MG(dim = 2,
#'   MGC_Static(den = .45, center = c(1, 0), par = .1, shape = Shape_Gaussian),
#'   MGC_Static(den = .45, center = c(2, 0), par = .4, shape = Shape_Block),
#'   MGC_Noise( den = .1, range = rbind(c(0, 3), c(-1,1)))
#' )
#' stream
#'
#' plot(stream)
#'
#' ### Example of several MGC_Randoms which define clusters that randomly move.
#' stream <- DSD_MG(dim = 2,
#'   MGC_Random(den = 100, center=c(1, 0), par = .1, rand = .2),
#'   MGC_Random(den = 100, center=c(2, 0), par = .4, shape = Shape_Block, rand = .2)
#' )
#'
#' \dontrun{
#'   animate_data(stream, 2500, xlim = c(0,3), ylim = c(-1,1), horizon = 100)
#' }
#'
#'
#' ### Example of several MGC_Functions
#'
#' ### a block-shaped cluster moving from bottom-left to top-right increasing size
#' c1 <- MGC_Function(
#'   density = function(t){ 100 },
#'   parameter = function(t){ 1 * t },
#'   center = function(t) c(t, t),
#'   shape = Shape_Block
#'   )
#'
#' ### a cluster moving in a circle (default shape is Gaussian)
#' c2 <- MGC_Function(
#'   density = function(t){ 25 },
#'   parameter = function(t){ 5 },
#'   center= function(t) c(sin(t / 10) * 50 + 50, cos(t / 10) * 50 + 50)
#' )
#'
#' stream <- DSD_MG(dim = 2, c1, c2)
#'
#' ## adding noise after the stream was created
#' add_cluster(stream, MGC_Noise(den = 10, range = rbind(c(-20, 120), c(-20, 120))))
#'
#' stream
#'
#' \dontrun{
#' animate_data(stream, 10000, xlim = c(-20, 120), ylim = c(-20, 120), horizon = 100)
#' }
#'
#' ### Example of several MGC_Linear: A single cluster splits at time 50 into two.
#' ### Note that c2 starts at time = 50!
#' stream <- DSD_MG(dim = 2)
#' c1 <- MGC_Linear(dim = 2)
#' add_keyframe(c1, time = 1,  dens = 50, par = 5, center = c(0, 0))
#' add_keyframe(c1, time = 50, dens = 50, par = 5, center = c(50, 50))
#' add_keyframe(c1, time = 100,dens = 50, par = 5, center = c(50, 100))
#' add_cluster(stream, c1)
#'
#' c2 <- MGC_Linear(dim = 2, shape = Shape_Block)
#' add_keyframe(c2, time = 50, dens = 25, par = c(10, 10), center = c(50, 50))
#' add_keyframe(c2, time = 100,dens = 25, par = c(30, 30), center = c(100, 50))
#' add_cluster(stream, c2)
#'
#' \dontrun{
#' animate_data(stream, 5000, xlim = c(0, 100), ylim = c(0, 100), horiz = 100)
#' }
#'
#' ### two fixed and a moving cluster
#' stream <- DSD_MG(dim = 2,
#'   MGC_Static(dens = 1, par = .1, center = c(0, 0)),
#'   MGC_Static(dens = 1, par = .1, center = c(1, 1)),
#'   MGC_Linear(dim = 2, list(
#'     keyframe(time = 0,    dens = 1, par = .1, center = c(0, 0)),
#'     keyframe(time = 1000, dens = 1, par = .1, center = c(1, 1)),
#'     keyframe(time = 2000, dens = 1, par = .1, center = c(0, 0), reset = TRUE)
#'   )))
#'
#' noise <- MGC_Noise(dens = .1, range = rbind(c(-.2, 1.2), c(-.2, 1.2)))
#' add_cluster(stream, noise)
#'
#' \dontrun{
#' animate_data(stream, n = 2000 * 3.1, xlim = c(-.2, 1.2), ylim = c(-.2, 1.2), horiz = 200)
#' }
#'
#' @export
MGC <- abstract_class_generator("MGC")

#' @export
print.MGC <- function(x, ...) {
  cat(paste(
    x$description,
    " (",
    toString(class(x)),
    ")",
    '\n',
    sep = ""
  ))
  cat(paste('In', x$RObj$dimension, 'dimensions', '\n'))
}
