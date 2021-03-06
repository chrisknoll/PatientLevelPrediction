% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/FitModel.R
\name{getModelDetails}
\alias{getModelDetails}
\title{Get the predictive model details}
\usage{
getModelDetails(predictiveModel, covariateData)
}
\arguments{
\item{predictiveModel}{An object of type \code{predictiveModel} as generated using he
\code{\link{fitPredictiveModel}} function.}

\item{covariateData}{An object of type \code{covariateData} as generated using
                         \code{\link{getDbCovariateData}}.}
}
\description{
\code{getModelDetails} shows the full model, so showing the betas of all variables included in the
model, along with the variable names
}
\details{
Shows the coefficients and names of the covariates with non-zero coefficients.
}

