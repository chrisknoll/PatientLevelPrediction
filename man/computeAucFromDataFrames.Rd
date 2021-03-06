% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/Evaluate.R
\name{computeAucFromDataFrames}
\alias{computeAucFromDataFrames}
\title{Compute the area under the ROC curve}
\usage{
computeAucFromDataFrames(prediction, status, time = NULL,
  confidenceInterval = FALSE, timePoint, modelType = "logistic")
}
\arguments{
\item{prediction}{A vector with the predicted hazard rate.}

\item{status}{A vector with the status of 1 (event) or 0 (no event).}

\item{time}{Only for survival models: a vector with the time to event or censor
(which ever comes first).}

\item{confidenceInterval}{Should 95 percebt confidence intervals be computed?}

\item{timePoint}{Only for survival models: time point when the AUC should be evaluated}

\item{modelType}{Type of model. Currently supported are "logistic" and "survival".}
}
\description{
Compute the area under the ROC curve
}
\details{
Computes the area under the ROC curve for the predicted probabilities, given the true observed
outcomes.
}

