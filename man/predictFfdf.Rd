% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/Predict.R
\name{predictFfdf}
\alias{predictFfdf}
\title{Generated predictions from a regression model}
\usage{
predictFfdf(coefficients, outcomes, covariates, modelType = "logistic")
}
\arguments{
\item{coefficients}{A names numeric vector where the names are the covariateIds, except for the
first value which is expected to be the intercept.}

\item{outcomes}{A data frame or ffdf object containing the outcomes with predefined columns
(see below).}

\item{covariates}{A data frame or ffdf object containing the covariates with predefined columns
(see below).}

\item{modelType}{Current supported types are "logistic", "poisson", or "survival".}
}
\description{
Generated predictions from a regression model
}
\details{
These columns are expected in the outcome object: \tabular{lll}{ \verb{rowId} \tab(integer) \tab
Row ID is used to link multiple covariates (x) to a single outcome (y) \cr \verb{time} \tab(real)
\tab For models that use time (e.g. Poisson or Cox regression) this contains time \cr \tab
\tab(e.g. number of days) \cr }
These columns are expected in the covariates object: \tabular{lll}{ \verb{rowId} \tab(integer) \tab
Row ID is used to link multiple covariates (x) to a single outcome (y) \cr \verb{covariateId}
\tab(integer) \tab A numeric identifier of a covariate \cr \verb{covariateValue} \tab(real) \tab
The value of the specified covariate \cr }
}

