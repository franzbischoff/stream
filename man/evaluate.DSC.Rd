% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/evaluate.DSC.R
\name{evaluate.DSC}
\alias{evaluate.DSC}
\alias{evaluate_static.DSC}
\alias{evaluate_stream.DSC}
\title{Evaluate a Stream Clustering Task}
\usage{
\method{evaluate_static}{DSC}(
  object,
  dsd,
  measure,
  n = 100,
  type = c("auto", "micro", "macro"),
  assign = "micro",
  assignmentMethod = c("auto", "model", "nn"),
  excludeNoise = FALSE,
  callbacks = list(),
  ...
)

\method{evaluate_stream}{DSC}(
  object,
  dsd,
  measure,
  n = 1000,
  horizon = 100,
  type = c("auto", "micro", "macro"),
  assign = "micro",
  assignmentMethod = c("auto", "model", "nn"),
  excludeNoise = FALSE,
  callbacks = NULL,
  ...,
  verbose = FALSE
)
}
\arguments{
\item{object}{The \link{DSC} object that the evaluation measure is being requested
from.}

\item{dsd}{The \link{DSD} object that holds the initial training data for the DSC.}

\item{measure}{Evaluation measure(s) to use. If missing then all available
measures are returned.}

\item{n}{The number of data points being requested.}

\item{type}{Use micro- or macro-clusters for evaluation. Auto used the class
of \link{DSC} to decide.}

\item{assign}{Assign points to micro or macro-clusters?}

\item{assignmentMethod}{How are points assigned to clusters for evaluation
(see \code{\link[=predict]{predict()}})?}

\item{excludeNoise}{logical; Should noise points in the data stream be excluded from
the calculation?}

\item{callbacks}{A named list of functions to calculate custom evaluation measures.}

\item{...}{Unused arguments are ignored.}

\item{horizon}{Evaluation is done using horizon many previous points (see
detail section).}

\item{verbose}{logical; Report progress?}
}
\value{
\code{evaluate} returns an object of class \code{stream_eval} which
is a numeric vector of the values of the requested measures and two
attributes, \code{"type"} and \code{"assign"}, to see at what level the
evaluation was done.
}
\description{
Methods for the generic functions \code{\link[=evaluate_static]{evaluate_static()}} and \code{\link[=evaluate_stream]{evaluate_stream()}}  to calculate evaluation measures for micro or macro-clusters created by a \link{DSC} on the
a \link{DSD} object.
}
\details{
For evaluation, each data point is assigned to its nearest cluster using
Euclidean distance to the cluster centers. Then for each cluster the
majority class is determined. Based on the majority class several evaluation
measures can be computed.

We provide two evaluation methods:
\itemize{
\item \code{evaluate_static()} evaluates the current static clustering using new data without updating the model.
\item \code{evaluate_stream()} evaluates the clustering process using
\emph{prequential error estimation} (see Gama, Sebastiao and Rodrigues; 2013).  The current model is
first applied to the data points in the horizon to calculate the evaluation measures. Then, the
cluster model is updated with the points.
}

\strong{Evaluation Measures}

Many evaluation measures are available using
code from other packages including \code{\link[cluster:silhouette]{cluster::silhouette()}},
\code{\link[clue:cl_agreement]{clue:: cl_agreement()}}, and \code{\link[fpc:cluster.stats]{fpc::cluster.stats()}}.

The following information items are available:
\itemize{
\item \code{"numPoints"} number of points used for evaluation.
\item \code{"numMicroClusters"} number of micro-clusters
\item \code{"numMacroClusters"} number of macro-clusters
\item \code{"numClasses"} number of classes
}

The following noise-related/outlier items are available:
\itemize{
\item \code{"noisePredicted"} Number data points predicted as noise
\item \code{"noiseActual"} Number of data points which are actually noise
\item \code{"noisePrecision"} Precision of the predicting noise (i.e., number of
correctly predicted noise points over the total number of points predicted
as noise)
\item \code{"outlierJaccard"} - A variant of the Jaccard index used to assess
outlier detection accuracy (see Krleza et al (2020)).  Outlier Jaccard index
is calculated as \code{TP / (TP + FP + UNDETECTED)}.
}

The following internal evaluation measures are available:
\itemize{
\item \code{"SSQ"} within cluster sum of squares. Assigns each point to
its nearest center from the clustering and calculates the sum of squares.
Noise points in the data stream are always ignored.
\item \code{"silhouette"} average silhouette width. Actual noise points
which stay unassigned by the clustering algorithm are ignored; regular
points that are unassigned by the clustering algorithm form their own
noise cluster) (\pkg{cluster})
\item \code{"average.between"} average distance between clusters (\pkg{fpc})
\item \code{"average.within"} average distance within clusters (\pkg{fpc})
\item \code{"max.diameter"} maximum cluster diameter (\pkg{fpc})
\item \code{"min.separation"} minimum cluster separation (\pkg{fpc})
\item \code{"ave.within.cluster.ss"} a generalization
of the within clusters sum of squares (half the sum of the within cluster
squared dissimilarities divided by the cluster size) (\pkg{fpc})
\item \code{"g2"} Goodman and Kruskal's Gamma coefficient (\pkg{fpc})
\item \code{"pearsongamma"} correlation between distances and a 0-1-vector where 0
means same cluster, 1 means different clusters (\pkg{fpc})
\item \code{"dunn"} Dunn index (minimum separation / maximum diameter) (\pkg{fpc})
\item \code{"dunn2"} minimum average dissimilarity between two cluster /
maximum average within cluster dissimilarity (\pkg{fpc})
\item \code{"entropy"} entropy of the distribution of cluster memberships (\pkg{fpc})
\item \code{"wb.ratio"} average.within/average.between (\pkg{fpc})
}

The following external evaluation measures are available:
\itemize{
\item \code{"precision"}, \code{"recall"}, \code{"F1"} F1.  A true positive (TP)
decision assigns two points in the same true cluster also to the same
cluster, a true negative (TN) decision assigns two points from two different
true clusters to two different clusters.  A false positive (FP) decision
assigns two points from the same true cluster to two different clusters.  A
false negative (FN) decision assigns two points from the same true cluster
to different clusters.

\code{precision = TP / (TP + FP)}

\code{recall = TP / (TP + FN)}

The F1 measure is the harmonic mean of precision and recall.
\item \code{"purity"} Average purity of clusters. The purity of each cluster
is the proportion of the points of the majority true group assigned to it
(see Cao et al. (2006)).
\item \code{"classPurity"} (of real clusters; see Wan et al (2009)).
\item \code{"fpr"} false positive rate.
\item \code{"Euclidean"} Euclidean dissimilarity of the memberships (see
Dimitriadou, Weingessel and Hornik (2002)) (\pkg{clue})
\item \code{"Manhattan"} Manhattan dissimilarity of the memberships (\pkg{clue})
\item \code{"Rand"} Rand index (see Rand (1971)) (\pkg{clue})
\item \code{"cRand"} Adjusted Rand index (see Hubert and Arabie (1985)) (\pkg{clue})
\item \code{"NMI"} Normalized Mutual Information (see Strehl and Ghosh (2002)) (\pkg{clue})
\item \code{"KP"} Katz-Powell index (see Katz and Powell (1953)) (\pkg{clue})
\item \code{"angle"} maximal cosine of the angle between the agreements (\pkg{clue})
-\code{ "diag"} maximal co-classification rate (\pkg{clue})
\item \code{"FM"} Fowlkes and Mallows's index (see Fowlkes and Mallows (1983)) (\pkg{clue})
\item \code{"Jaccard"} Jaccard index (\pkg{clue})
\item \code{"PS"} Prediction Strength (see Tibshirani and Walter (2005)) (\pkg{clue}) \%
\item \code{"corrected.rand"}  corrected Rand index (\pkg{fpc})
\item \code{"vi"} variation of information (VI) index (\pkg{fpc})
}

Many measures are the average over all clusters. For example, purity is the
average purity over all clusters.

For \link{DSC_Micro} objects, data points are assigned to micro-clusters and
then each micro-cluster is evaluated. For \link{DSC_Macro} objects, data
points by default (\code{assign = "micro"}) also assigned to micro-clusters,
but these assignments are translated to macro-clusters. The evaluation is
here done for macro-clusters. This is important when macro-clustering is
done with algorithms which do not create spherical clusters (e.g,
hierarchical clustering with single-linkage or DBSCAN) and this assignment
to the macro-clusters directly (i.e., their center) does not make sense.

Using \code{type} and \code{assign}, the user can select how to assign data
points and ad what level (micro or macro) to evaluate.

\code{evaluate_cluster()} is used to evaluate an evolving data stream using
the method described by Wan et al. (2009). Of the \code{n} data points
\code{horizon} many points are clustered and then the evaluation measure is
calculated on the same data points. The idea is to find out if the
clustering algorithm was able to adapt to the changing stream.

\strong{Custom Evaluation Measures}

The parameter \code{callbacks} can be supplied with a named list with
functions with the signature \verb{function(actual, predict, points, centers, dsc)}
as elements. See the Examples sections for details.
}
\examples{
# Example 1: Static Evaluation
set.seed(0)
stream <- DSD_Gaussians(k = 3, d = 2)

dstream <- DSC_DStream(gridsize = 0.05, Cm = 1.5)
update(dstream, stream, 500)
plot(dstream, stream)

# Evaluate the micro-clusters in the clustering
# Note: we use here only n = 100 points for evaluation to speed up execution
evaluate_static(dstream, stream, n = 100)

evaluate_static(dstream, stream,
  measure = c("numMicro", "numMacro", "purity", "crand", "SSQ"),
  n = 100)

# DStream also provides macro clusters. Evaluate macro clusters with type = "macro"
# Note that SSQ and cRand increase.
plot(dstream, stream, type = "macro")
evaluate_static(dstream, stream, type = "macro",
  measure = c("numMicro", "numMacro", "purity", "crand", "SSQ"),
  n = 100)

# Points are by default assigned to micro clusters using the method
# specified for the clustering algorithm.
# However, points can also be assigned to the closest macro-cluster using
# assign = "macro".
evaluate_static(dstream, stream, type = "macro", assign = "macro",
  measure = c("numMicro", "numMacro", "purity", "crand", "SSQ"),
  n = 100)

# Example 2: Evaluate with Noise/Outliers
stream <- DSD_Gaussians(k = 3, d = 2, noise = .05)
dstream <- DSC_DStream(gridsize = 0.05, Cm = 1.5)
update(dstream, stream, 500)

# For cRand, noise is its own group, for SSQ, actual noise is always
# excluded.
plot(dstream, stream, 500)
evaluate_static(dstream, stream, n = 100,
  measure = c("numPoints", "noisePredicted", "noiseActual",
    "noisePrecision", "outlierJaccard", "cRand", "SSQ"))

# Note that if noise is excluded, the number of used points is reduced.
evaluate_static(dstream, stream, n = 100,
  measure = c("numPoints", "noisePredicted", "noiseActual",
    "noisePrecision", "outlierJaccard", "cRand", "SSQ"), excludeNoise = TRUE)


# Example 3: Evaluate an evolving data stream
stream <- DSD_Benchmark(1)
dstream <- DSC_DStream(gridsize = 0.05, lambda = 0.1)

evaluate_stream(dstream, stream, type = "macro", assign = "micro",
  measure = c("numMicro", "numMacro", "purity", "cRand"),
  n = 600, horizon = 100)

if (interactive()){
# animate the clustering process
reset_stream(stream)
dstream <- DSC_DStream(gridsize = 0.05, lambda = 0.1)
animate_cluster(dstream, stream, horizon = 100, n = 5000,
  measure = "cRand", type = "macro", assign = "micro",
  plot.args = list(type = "both", xlim = c(0,1), ylim = c(0,1)))
}

# Example 4: Add a custom measure as a callback
callbacks <- list(
   noisePercentage = function(actual, predict, points, centers, dsc) {
     sum(actual == 0L) / length(actual)
   },
   noiseFN = function(actual, predict, points, centers, dsc) {
     sum(actual == 0L & predict != 0L)
   },
   noiseFP = function(actual, predict, points, centers, dsc) {
     sum(actual != 0L & predict == 0L)
   }
 )

stream <- DSD_Gaussians(k = 3, d = 2, noise = .2)
dstream <- DSC_DStream(gridsize = 0.05, Cm = 1.5)
update(dstream, stream, 500)

evaluate_static(dstream, stream,
  measure = c("numPoints", "noiseActual", "noisePredicted",
    "noisePercentage", "noiseFN", "noiseFP"),
  callbacks = callbacks, n = 100)

evaluate_static(dstream, stream, callbacks = callbacks)
}
\references{
Joao Gama, Raquel Sebastiao, Pedro Pereira Rodrigues (2013). On
evaluating stream learning algorithms. \emph{Machine Learning,} March 2013,
Volume 90, Issue 3, pp 317-346.

F. Cao, M. Ester, W. Qian, A. Zhou (2006). Density-Based Clustering over an
Evolving Data Stream with Noise.
\emph{Proceeding of the 2006 SIAM Conference on Data Mining,} 326-337.

E. Dimitriadou, A. Weingessel and K. Hornik (2002).  A combination scheme
for fuzzy clustering.
\emph{International Journal of Pattern Recognition and Artificial Intelligence,}
16, 901-912.

E. B. Fowlkes and C. L. Mallows (1983).  A method for comparing two
hierarchical clusterings.
\emph{Journal of the American Statistical Association,} 78, 553-569.

L. Hubert and P. Arabie (1985).  Comparing partitions.
\emph{Journal of Classification,} 2, 193-218.

W. M. Rand (1971).  Objective criteria for the evaluation of clustering
methods.  \emph{Journal of the American Statistical Association,} 66,
846-850.

L. Katz and J. H. Powell (1953).  A proposed index of the conformity of one
sociometric measurement to another. \emph{Psychometrika,} 18, 249-256.

A. Strehl and J. Ghosh (2002).  Cluster ensembles - A knowledge reuse
framework for combining multiple partitions.
\emph{Journal of Machine Learning Research,} 3, 583-617.

R. Tibshirani and G. Walter (2005).  Cluster validation by Prediction
Strength. \emph{Journal of Computational and Graphical Statistics,} 14/3,
511-528.

L Wan, W.K. Ng, X.H. Dang, P.S. Yu and K. Zhang (2009). Density-Based
Clustering of Data Streams at Multiple Resolutions, \emph{ACM Transactions
on Knowledge Discovery from Data,} 3(3).

D. Krleža, B. Vrdoljak, and M. Brčić (2020). Statistical Hierarchical
Clustering Algorithm for Outlier Detection in Evolving Data Streams,
\emph{Springer Machine Learning}.
}
\seealso{
\code{\link[cluster:silhouette]{cluster::silhouette()}}, \code{\link[clue:cl_agreement]{clue:: cl_agreement()}}, and \code{\link[fpc:cluster.stats]{fpc::cluster.stats()}}.

Other DSC: 
\code{\link{DSC}()},
\code{\link{DSC_Macro}()},
\code{\link{DSC_Micro}()},
\code{\link{DSC_R}()},
\code{\link{DSC_SlidingWindow}()},
\code{\link{DSC_Static}()},
\code{\link{DSC_TwoStage}()},
\code{\link{animate_cluster}()},
\code{\link{get_assignment}()},
\code{\link{plot.DSC}()},
\code{\link{predict}()},
\code{\link{prune_clusters}()},
\code{\link{read_saveDSC}},
\code{\link{recluster}()}

Other evaluation: 
\code{\link{animate_cluster}()},
\code{\link{evaluate}}
}
\author{
Michael Hahsler, Matthew Bolanos, John Forrest, and Dalibor Krleža
}
\concept{DSC}
\concept{evaluation}
