% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/GetOutcomes.R
\name{loadOutcomeData}
\alias{loadOutcomeData}
\title{Load the outcome data from a folder}
\usage{
loadOutcomeData(file, readOnly = FALSE)
}
\arguments{
\item{file}{The name of the folder containing the data.}

\item{readOnly}{If true, the data is opened read only.}
}
\value{
An object of class outcomeData
}
\description{
\code{loadOutcomeData} loads an object of type outcomeData from a folder in the file system.
}
\details{
The data will be written to a set of files in the folder specified by the user.
}

