% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/DSF_Convolve.R
\name{DSF_Convolve}
\alias{DSF_Convolve}
\alias{filter_MA}
\alias{filter_Hamming}
\alias{filter_diff}
\alias{filter_Sinc}
\alias{pow2}
\title{Apply a Filter to a Data Stream}
\usage{
DSF_Convolve(
  dsd = NULL,
  dim = NULL,
  kernel = NULL,
  pre = NULL,
  post = NULL,
  na.rm = FALSE,
  replace = TRUE,
  name = NULL
)

filter_MA(width)

filter_Hamming(width)

filter_diff(lag)

filter_Sinc(fc, fs, width = NULL, bw = NULL)

pow2(x)
}
\arguments{
\item{dsd}{A object of class \link{DSD}.}

\item{dim}{columns to which the filter should be applied. Default is all columns.}

\item{kernel}{filter kernel as a numeric vector of weights.}

\item{pre, post}{functions to be applied before and after the convolution.}

\item{na.rm}{logical; should NAs be ignored?}

\item{replace}{logical; should the column be replaced or a column with the convolved column added?}

\item{name}{character; the new column will be name with the old column name + \verb{_} + \code{name}.}

\item{width}{filter width.}

\item{lag}{an integer indicating which time lag to use.}

\item{fc}{cutoff frequency.}

\item{fs}{sampling frequency.}

\item{bw}{transition bandwidth.}

\item{x}{values to be squared.}
}
\value{
An object of class \code{DSF_Convolve} (subclass of \link{DSF} and \link{DSD}).
}
\description{
Applies a filter (i.e., a convolution with a filter kernel) to a data stream.
}
\details{
A filter kernel is a vector with kernel weights. A few filter are provided.
\itemize{
\item \code{filter_MA(width)} creates a moving average.
\item \code{filter_diff(lag)} calculates lagged differences. Note that \code{na.rm = TRUE} will lead to artifacts and should not be used.
\item \code{filter_Hamming(width)} creates a Hamming window.
\item \code{filter_Sinc(fc, fs, width, bw)} creates a windowed-sinc filter. One of \code{width} (filter length) or
\code{bw} (transition bandwidth can  be used to control the filter roll-off. The relationship is \eqn{width = 4/bw}.
See Chapter 16 in Smith (1997).
}

\code{pre} and \code{post} are functions that are called before and after the convolution. For example, to calculate
RMS, you can use \code{pre = pow2} and \code{post = sqrt}. \code{pow2()} is a convenience function.
}
\examples{
data(presidents)

## Example 1: Create a data stream with three copies of president approval ratings.
## We will use several convolutions.
stream <- data.frame(
    approval_orig = presidents,
    approval_MA = presidents,
    approval_diff1 = presidents,
    .time = time(presidents)) \%>\%
  DSD_Memory()

plot(stream, dim = 1, n = 120, method = "ts")

## apply a moving average filter to dimension 1 (using the column name) and diff to dimension 3
filteredStream <- stream \%>\%
  DSF_Convolve(kernel = filter_MA(5), dim = "approval_orig", na.rm = TRUE) \%>\%
  DSF_Convolve(kernel = filter_diff(1), dim = 3)
filteredStream

## resetting the filtered stream also resets the original stream
reset_stream(filteredStream)
ps <- get_points(filteredStream, n = 120)
head(ps)

year <- ps[[".time"]]
approval <- remove_info(ps)
matplot(year, approval, type = "l", ylim = c(-20, 100))
legend("topright", colnames(approval), col = 1:3, lty = 1:3, bty = "n")

## Example 2: Create a stream with a constant sine wave and apply
## a moving average, an RMS envelope and a differences
stream <- DSD_Memory(data.frame(y = sin(seq(0, 2 * pi - (2 * pi / 100) ,
  length.out = 100))), loop = TRUE)
plot(stream, n = 200, method = "ts")

filteredStream <- stream \%>\%
  DSF_Convolve(kernel = filter_MA(100), dim = 1,
    replace = FALSE, name = "MA") \%>\%
  DSF_Convolve(kernel = filter_MA(100), pre = pow2, post = sqrt, dim = 1,
    replace = FALSE, name = "RMS") \%>\%
  DSF_Convolve(kernel = filter_diff(1), dim = 1,
    replace = FALSE, name = "diff1")
filteredStream

ps <- get_points(filteredStream, n = 500)
head(ps)

matplot(ps, type = "l")
legend("topright", colnames(ps), col = 1:4, lty = 1:4)

## Note that MA and RMS use a window of length 200 and are missing at the
##   beginning of the stream the window is full.

## Filters: look at different filters
filter_MA(5)
filter_diff(1)
plot(filter_Hamming(20), type = "h")
plot(filter_Sinc(10, 100, width = 20), type = "h")
}
\references{
Steven W. Smith, The Scientist and Engineer's Guide to
Digital Signal Processing, California Technical Pub; 1st edition (January 1, 1997).
ISBN 0966017633, URL: https://www.dspguide.com/
}
\seealso{
\link[stats:filter]{stats::filter} provides non-streaming convolution.

Other DSF: 
\code{\link{DSF}()},
\code{\link{DSF_Downsample}()},
\code{\link{DSF_ExponentialMA}()},
\code{\link{DSF_FeatureSelection}()},
\code{\link{DSF_Func}()},
\code{\link{DSF_Scale}()},
\code{\link{DSF_dplyr}()}
}
\author{
Michael Hahsler
}
\concept{DSF}
