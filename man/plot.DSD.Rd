% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot.DSD.R
\name{plot.DSD}
\alias{plot.DSD}
\alias{plot}
\title{Plot Data Stream Data}
\usage{
\method{plot}{DSD}(
  x,
  n = 500,
  col = NULL,
  pch = NULL,
  ...,
  method = c("pairs", "scatter", "pca", "ts"),
  dim = NULL,
  alpha = 0.6,
  transform = NULL
)
}
\arguments{
\item{x}{the \link{DSD} object to be plotted.}

\item{n}{number of plots taken from \code{x} to plot.}

\item{col}{colors used for points.}

\item{pch}{symbol type.}

\item{\dots}{further arguments are passed on to \code{\link[graphics:plot.default]{graphics::plot.default()}} or \code{\link[graphics:pairs]{graphics::pairs()}}.}

\item{method}{method used for plotting: \code{"pairs"} (pairs plot), \code{"scatter"}
(scatter plot), \code{"pca"} (plot first 2 principal components), or \code{"ts"} (time series).}

\item{dim}{an integer vector with the dimensions to plot. If \code{NULL}
then for methods \code{pairs} and \code{"pca"} all dimensions are used and
for \code{"scatter"} the first two dimensions are plotted.}

\item{alpha}{alpha shading used to plot the points.}

\item{transform}{a function that maps data stream points onto a 2-D plane for plotting.}
}
\description{
Method to plot data stream data. To plot \link{DSC} see \code{\link[=plot.DSC]{plot.DSC()}}.
}
\examples{
stream <- DSD_Gaussians(k=3, d=3)

## plot data
plot(stream, n = 500)
plot(stream, method = "pca", n = 500)
plot(stream, method = "scatter", dim = c(1, 3), n = 500)

## create and plot micro-clusters
dstream <- DSC_DStream(gridsize = 0.1)
update(dstream, stream, 500)
plot(dstream)

## plot with data, projected on the first two principal components
## and dimensions 2 and 3
plot(dstream, stream)
plot(dstream, stream, method = "pca")
plot(dstream, stream, dim = c(2, 3))

## plot micro and macro-clusters
plot(dstream, stream, type = "both")

## plot a time series using the AirPassenger data with the total monthly
## passengers from 1949 to 1960) a as a stream
AirPassengers
stream <- DSD_Memory(data.frame(
  .time = time(AirPassengers),
  passengers = AirPassengers))

get_points(stream, n = 10)
plot(stream, n = 100, method = "ts")
}
\seealso{
Other DSD: 
\code{\link{DSD}()},
\code{\link{DSD_BarsAndGaussians}()},
\code{\link{DSD_Benchmark}()},
\code{\link{DSD_Cubes}()},
\code{\link{DSD_Gaussians}()},
\code{\link{DSD_MG}()},
\code{\link{DSD_Memory}()},
\code{\link{DSD_Mixture}()},
\code{\link{DSD_NULL}()},
\code{\link{DSD_ReadDB}()},
\code{\link{DSD_ReadStream}()},
\code{\link{DSD_Target}()},
\code{\link{DSD_UniformNoise}()},
\code{\link{DSD_mlbenchData}()},
\code{\link{DSD_mlbenchGenerator}()},
\code{\link{DSF}()},
\code{\link{animate_data}()},
\code{\link{close_stream}()},
\code{\link{get_points}()},
\code{\link{reset_stream}()}

Other plot: 
\code{\link{animate_cluster}()},
\code{\link{animate_data}()},
\code{\link{plot.DSC}()}
}
\author{
Michael Hahsler
}
\concept{DSD}
\concept{plot}
