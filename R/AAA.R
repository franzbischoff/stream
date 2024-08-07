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



### noise symbol and color
.noise_pch <- 20L
.noise_col <- gray(.5, alpha = .3)

.outlier_pch <- 4L
.outlier_col <- "#FF0000FF"

.points_col <- gray(.5, alpha = .5)

.micro_pch <- 1L
.macro_pch <- 3L

### helper for doing things in blocks
.make_block <- function(n, block) {
  if (n < block)
    return(n)

  b <- rep(block, times = as.integer(n / block))
  if (n %% block)
    b <- c(b, n %% block)
  b
}

### line break helper
.line_break <-
  function(x,
    width = 0.9 * getOption("width")) {
    paste0(unlist(
      sapply(
        strsplit(x, "\n", fixed = TRUE)[[1]],
        strwrap,
        width = width
      )
    ), collapse = "\n")
  }

### nodots
.nodots <- function(...) {
  l <- list(...)
  if (length(l) > 0L)
    warning("Unknown arguments: ",
      paste(names(l), "=", l, collapse = ", "))
}

abstract_class_generator <- function(prefix) {
  function(...) {
    message(prefix, " is an abstract class and cannot be instantiated!")

    stream_pks <-
      sort(grep('^package:stream', search(), value = TRUE))
    for (p in stream_pks) {
      implementations <- grep(paste0('^', prefix, '_'), ls(p),
        value = TRUE)
      if (length(implementations) == 0)
        implementations <- "*None*"
      message(
        "\nAvailable subclasses in ",
        sQuote(p),
        " are:\n\t",
        paste(implementations, collapse = ",\n\t")
      )
    }

    message("\nTo get more information in R Studio, type ",
      sQuote(paste0(prefix, '_')),
      " and hit the Tab key.")

    invisible(NULL)
  }
}
