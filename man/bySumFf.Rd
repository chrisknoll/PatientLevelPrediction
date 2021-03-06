% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/Predict.R
\name{bySumFf}
\alias{bySumFf}
\title{Compute sum of values binned by a second variable}
\usage{
bySumFf(values, bins)
}
\arguments{
\item{values}{An ff object containing the numeric values to be summed}

\item{bins}{An ff object containing the numeric values to bin by}
}
\description{
Compute sum of values binned by a second variable
}
\examples{
values <- ff::as.ff(c(1, 1, 2, 2, 1))
bins <- ff::as.ff(c(1, 1, 1, 2, 2))
bySumFf(values, bins)
}

