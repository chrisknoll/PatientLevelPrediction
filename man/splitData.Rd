% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/DataSplitting.R
\name{splitData}
\alias{splitData}
\title{Split data into random subsets}
\usage{
splitData(cohortData, covariateData, outcomeData, splits = 2)
}
\arguments{
\item{cohortData}{An object of type \code{cohortData}.}

\item{covariateData}{An object of type \code{covariateData}.}

\item{outcomeData}{An object of type \code{outcomeData}.}

\item{splits}{This can be either a single integer, in which case the data will be split up
                       into equally sized parts. If a vector is provided instead, these are
                       interpreted as the relative sizes of each part.}
}
\value{
A list with entries for each part. An entry itself is a list containing a cohortData,
covariateData, and outcomeData object.
}
\description{
Split data into random subsets
}
\details{
Splits cohort, covariate, and outcome data into random subsets, to be used for validation.
}

