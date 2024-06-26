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

#' Stream Interface for Data Sets From mlbench
#'
#' Provides a convenient stream interface for data sets from the mlbench
#' package.
#'
#' The `DSD_mlbenchData` class is designed to be a wrapper class for data
#' from the mlbench package.
#'
#' All data is held in memory in either data frame or matrix form. It is served as a stream using the
#' [DSD_Memory] class. The stream can be reset to position 1 using [reset_stream()].
#'
#' Call `DSD_mlbenchData` with a missing value for `data` to get a list of
#' all available data sets.
#'
#' @family DSD
#'
#' @param data The name of the dataset from mlbench. If missing then a list of
#' all available data sets is shown and returned.
#' @param loop logical; loop or not to loop over the
#' data frame.
#' @param random logical; should the data be used a random order?
#' @param scale logical; apply scaling to the data?
#' @return Returns a `DSD_mlbenchData` object which is also of class
#' [DSD_Memory].
#' @author Michael Hahsler and Matthew Bolanos
#' @examples
#' DSD_mlbenchData()
#'
#' stream <- DSD_mlbenchData("Shuttle")
#' stream
#'
#' get_points(stream, n = 5)
#'
#' plot(stream, n = 100)
#' @export
DSD_mlbenchData <-
  function(data = NULL,
    loop = FALSE,
    random = FALSE,
    scale = FALSE) {
    datasets <- c(
      "BostonHousing",
      "BostonHousing2",
      "BreastCancer",
      "DNA",
      "Glass",
      "Ionosphere",
      "LetterRecognition",
      "Ozone",
      "PimaIndiansDiabetes",
      "Satellite",
      "Servo",
      "Shuttle",
      "Sonar",
      "Soybean",
      "Vehicle",
      "Vowel",
      "Zoo",
      "HouseVotes84"
    )

    if (is.null(data)) {
      cat("Available data sets:\n")
      print(datasets)
      return(invisible(datasets))
    }

    #finds index of partial match in array of datasets
    m <- pmatch(tolower(data), tolower(datasets))
    if (is.na(m))
      stop("Invalid data name: ", data)

    data(list = datasets[m],
      package = "mlbench",
      envir = environment())
    x <- get(datasets[m], envir = environment())

    if (m == 1) {
      d <- x
      a <- NULL
    }
    else if (m == 2) {
      d <- x
      a <- NULL
    }
    else if (m == 3) {
      d <- x[, 2:10]
      a <- as.numeric(x[, 11])
    }
    else if (m == 4) {
      d <- x[, 1:180]
      a <- x[, 181]
      levels(a) <- 1:3
      a <- as.numeric(a)
    }
    else if (m == 5) {
      d <- x[, 1:9]
      a <- x[, 10]
    }
    else if (m == 6) {
      d <- x[, 1:34]
      a <- as.numeric(x[, 35])
    }
    else if (m == 7) {
      d <- x[, 2:17]
      a <- as.numeric(x[, 1])
    }
    else if (m == 8) {
      d <- x
      a <- NULL
    }
    else if (m == 9) {
      d <- x[, 1:8]
      a <- as.numeric(x[, 9])
    }
    else if (m == 10) {
      d <- x[, 1:36]
      a <- as.numeric(x[, 37])
    }
    else if (m == 11) {
      d <- x[, 1:4]
      d[, 1] <- as.numeric(d[, 1])
      d[, 2] <- as.numeric(d[, 2])
      a <- x[, 5]
    }
    else if (m == 12) {
      d <- x[, 1:9]
      a <- as.numeric(x[, 10])
    }
    else if (m == 13) {
      d <- x[, 1:60]
      a <- as.numeric(x[, 61])
    }
    else if (m == 14) {
      d <- x[, 2:36]
      a <- as.numeric(x[, 1])
    }
    else if (m == 15) {
      d <- x[, 1:18]
      a <- as.numeric(x[, 19])
    }
    else if (m == 16) {
      d <- x[, 1:10]
      a <- as.numeric(x[, 11])
    }
    else if (m == 17) {
      d <- x[, 1:16]
      a <- as.numeric(x[, 17])
    }
    else if (m == 18) {
      d <- matrix(0, nrow(x), ncol(x))
      d[which(is.na(x[, 2:17]))] <- -1
      d[which(x[, 2:17] == 'n')] <- 0
      d[which(x[, 2:17] == 'y')] <- 1
      a <- rep(0, nrow(x))
      a[which(x[, 1] == 'democrat')] <- 1
    }

    complete <- stats::complete.cases(d)
    a <- a[complete]
    d <- d[complete,]

    if (random) {
      rand <- sample(seq_along(a), length(a), replace = FALSE)
      a <- a[rand]
      d <- d[rand,]
    }

    d <- apply(d, 2L, as.numeric)

    if (scale)
      d <- scale(d)

    d <- as.data.frame(d)

    dims <- ncol(d)

    d[['.class']] <- as.integer(a)
    k <- length(unique(a))

    l <-
      DSD_Memory(
        d,
        k = k,
        description = paste0("mlbench:", data, "(d = ", dims, ", k = ", k ,")")
      )
    class(l) <- c("DSD_mlbenchData", class(l))
    l
  }
