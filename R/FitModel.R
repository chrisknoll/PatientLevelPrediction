# @file FitModel.R
#
# Copyright 2015 Observational Health Data Sciences and Informatics
#
# This file is part of PatientLevelPrediction
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#' Fit a predictive model
#'
#' @param cohortData      An object of type \code{cohortData}.
#' @param covariateData   An object of type \code{covariateData}.
#' @param outcomeData     An object of type \code{outcomeData}.
#' @param modelType       The type of predictive model. Options are "logistic", "poisson", and
#'                        "survival".
#' @param cohortId        The ID of the specific cohort for which to fit a model.
#' @param outcomeId       The ID of the specific outcome for which to fit a model.
#' @param prior           The prior used to fit the model. See \code{\link[Cyclops]{createPrior}} for
#'                        details.
#' @param control         The control object used to control the cross-validation used to determine the
#'                        hyperparameters of the prior (if applicable). See
#'                        \code{\link[Cyclops]{createControl}} for details.
#'
#' @export
fitPredictiveModel <- function(cohortData,
                               covariateData,
                               outcomeData,
                               modelType = "logistic",
                               cohortId = NULL,
                               outcomeId = NULL,
                               prior = createPrior("laplace",
                                                   exclude = c(0),
                                                   useCrossValidation = TRUE),
                               control = createControl(noiseLevel = "silent",
                                                       cvType = "auto",
                                                       startingVariance = 0.1)) {
  if (is.null(cohortId) && length(cohortData$metaData$cohortIds) != 1)
    stop("No cohort ID specified, but multiple cohorts found")
  if (is.null(outcomeId) && length(outcomeData$metaData$outcomeIds) != 1)
    stop("No outcome ID specified, but multiple outcomes found")
  
  if (is.null(cohortId)) {
    covariates <- ffbase::subset.ffdf(covariateData$covariates, select = c("personId",
                                                                           "cohortStartDate",
                                                                           "covariateId",
                                                                           "covariateValue"))
    cohorts <- ffbase::subset.ffdf(cohortData$cohorts,
                                   select = c("personId", "cohortStartDate", "time"))
    outcomes <- ffbase::subset.ffdf(outcomeData$outcomes, select = c("personId",
                                                                     "cohortStartDate",
                                                                     "outcomeId",
                                                                     "outcomeCount",
                                                                     "timeToEvent"))
  } else {
    covariates <- ffbase::subset.ffdf(covariateData$covariates,
                                      cohortId == cohortId,
                                      select = c("personId",
                                                 "cohortStartDate",
                                                 "covariateId",
                                                 "covariateValue"))
    cohorts <- ffbase::subset.ffdf(cohortData$cohorts,
                                   cohortId == cohortId,
                                   select = c("personId", "cohortStartDate", "time"))
    outcomes <- ffbase::subset.ffdf(outcomeData$outcomes,
                                    cohortId == cohortId,
                                    select = c("personId",
                                               "cohortStartDate",
                                               "outcomeId",
                                               "outcomeCount",
                                               "timeToEvent"))
  }
  if (!is.null(outcomeId)) {
    outcomes <- ffbase::subset.ffdf(outcomes, outcomeId == outcomeId)
  }
  if (!is.null(outcomeData$exclude) && nrow(outcomeData$exclude) != 0) {
    if (is.null(outcomeId)) {
      exclude <- outcomeData$exclude
    } else {
      exclude <- ffbase::subset.ffdf(outcomeData$exclude,
                                     outcomeId == outcomeId,
                                     select = c("personId", "cohortStartDate", "cohortId"))
    }
    exclude$dummy <- ff::ff(1, length = nrow(exclude), vmode = "double")
    cohorts <- merge(cohorts, exclude, all.x = TRUE)
    cohorts <- ffbase::subset.ffdf(cohorts, dummy != 1)
    cohorts$dummy <- NULL
  }
  cohorts$rowId <- ff::ff(1:nrow(cohorts))
  covariates <- merge(covariates, cohorts, by = c("cohortStartDate", "personId"))
  if (modelType == "logistic" | modelType == "survival") {
    outcomes$y <- ff::ff(1, length = nrow(outcomes), vmode = "double")
  } else {
    # Poisson
    outcomes$y <- outcomes$outcomeCount
  }
  outcomes <- merge(cohorts, outcomes, by = c("cohortStartDate", "personId"), all.x = TRUE)
  idx <- ffbase::is.na.ff(outcomes$y)
  idx <- ffbase::ffwhich(idx, idx == TRUE)
  outcomes$y <- ff::ffindexset(x = outcomes$y,
                               index = idx,
                               value = ff::ff(0, length = length(idx), vmode = "double"))
  if (modelType == "survival") {
    # For survival analysis, we use a Poisson regression censored at the time of first event
    idx <- ffbase::is.na.ff(outcomes$timeToEvent)
    idx <- ffbase::ffwhich(idx, idx == FALSE)
    outcomes$time <- ff::ffindexset(x = outcomes$time,
                                    index = idx,
                                    value = outcomes$timeToEvent[idx])
  }
  if (modelType == "logistic") {
    cyclopsModelType <- "lr"
  } else {
    cyclopsModelType <- "pr"
  }
  cyclopsData <- convertToCyclopsData(outcomes,
                                      covariates,
                                      modelType = cyclopsModelType,
                                      addIntercept = TRUE,
                                      quiet = TRUE)
  cyclopsFit <- fitCyclopsModel(cyclopsData, prior = prior, control = control)
  if (is.null(cohortId))
    cohortId <- cohortData$metaData$cohortIds
  if (is.null(outcomeId))
    outcomeId <- outcomeData$metaData$outcomeIds
  predictiveModel <- list(cohortId = cohortId,
                          outcomeId = outcomeId,
                          modelType = modelType,
                          coefficients = coef(cyclopsFit),
                          priorVariance = cyclopsFit$variance[1])
  class(predictiveModel) <- append(class(predictiveModel), "predictiveModel")
  return(predictiveModel)
}

#' Get the predictive model details
#'
#' @description
#' \code{getModelDetails} shows the full model, so showing the betas of all variables included in the
#' model, along with the variable names
#'
#' @param predictiveModel   An object of type \code{predictiveModel} as generated using he
#'                          \code{\link{fitPredictiveModel}} function.
#' @param covariateData     An object of type \code{covariateData} as generated using
#'                          \code{\link{getDbCovariateData}}.
#'
#' @details
#' Shows the coefficients and names of the covariates with non-zero coefficients.
#'
#' @export
getModelDetails <- function(predictiveModel, covariateData) {
  cfs <- predictiveModel$coefficients
  
  cfs <- cfs[cfs != 0]
  attr(cfs, "names")[attr(cfs, "names") == "(Intercept)"] <- 0
  cfs <- data.frame(coefficient = cfs, id = as.numeric(attr(cfs, "names")))
  
  cfs <- merge(ff::as.ffdf(cfs),
               covariateData$covariateRef,
               by.x = "id",
               by.y = "covariateId",
               all.x = TRUE)
  cfs <- ff::as.ram(cfs[, c("coefficient", "id", "covariateName")])
  cfs$covariateName <- as.character(cfs$covariateName)
  cfs <- cfs[order(-abs(cfs$coefficient)), ]
  cfs$covariateName[cfs$id == 0] <- "Intercept"
  return(cfs)
}
