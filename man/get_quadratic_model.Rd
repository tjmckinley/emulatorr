% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/modelbuilding.R
\name{get_quadratic_model}
\alias{get_quadratic_model}
\title{Quadratic Model Generation}
\usage{
get_quadratic_model(
  data,
  ranges,
  output_name,
  add = FALSE,
  linear_model = NULL
)
}
\arguments{
\item{data}{A \code{data.frame} containing the input and output values}

\item{ranges}{A named \code{list} consisting of the ranges of the input parameters}

\item{output_name}{A string corresponding to the output to be modelled}

\item{add}{Should we perform stepwise add or stepwise delete? Default: \code{FALSE}}

\item{linear_model}{Optional. A linear model to augment if add = TRUE}
}
\value{
The fitted model
}
\description{
Creates a quadratic model from data and a list of inputs.
There are two ways to generate the model; either start with all possible linear and
quadratic terms, and then stepwise remove them (using \code{step}), or start with a
linear model (maybe from \code{\link{get_linear_model}}) and add quadratic terms one
by one, only retaining them if the AIC is improved. Which is chosen is dependent on
the value of \code{add}; in the event where \code{add = FALSE} and there are not
enough degrees of freedom, a warning will be given.
}
