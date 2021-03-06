% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/EmulatorDocumentation.R
\name{Emulator}
\alias{Emulator}
\title{Bayes Linear Emulator}
\description{
Creates an univariate emulator object.

    The structure of the emulator is \code{f(x) = g(x) * beta + u(x)}, for
    regression functions \code{g(x)}, regression coefficients \code{beta},
    and correlation structure \code{u(x)}. An emulator can be created with
    or without data; the preferred method is to create an emulator based
    on prior specifications in the absence of data, then use that emulator
    with data to generate a new one (see examples).
}
\section{Constructor}{
 \code{Emulator$new(basis_f, beta, u, ranges, bucov = NULL, data = NULL, delta = 0)}
}

\section{Arguments}{

 \code{basis_f} A list of basis functions to be used. For ease of understanding, it is advisable
 to arrange these in increasing powers of the variables. The constant function
 \code{function(x) 1} should be the first element (this is the format given if
 \code{emulator_from_data} is used to generate emulators).

 \code{beta} A set of regression parameters. These are provided in the form
 \code{list(mu, sigma)}, where \code{mu} are the expectations of the coefficients and
 \code{sigma} the corresponding covariance matrix.

 \code{u} The specifications for the correlation structure. This has three parts: the
 expectation E[u(x)], the variance Var[u(x)], and a correlation function c(x,x'). These
 are passed as \code{list(mu, sigma, corr)}.

 \code{ranges} A named list of ranges for the input parameters. Required: if, for example,
 we have two inputs \code{a} and \code{b} with ranges [-0.5,0.5] and [3,5] respectively,
 then \code{ranges = list(a = c(-0.5,0.5), b = (3,5))}.

 \code{bucov} The covariance between the regression parameters and the correlation
 structure, as a vector of length \code{length(beta$mu)}. Preferably this should be
 defined as a list of functions.

 \code{data} If an adjusted emulator is desired, then the data by which to adjust is
 specified here, as a \code{data.frame} with named columns.

 \code{delta} A nugget to add to the correlation structure, in the range [0,1).
}

\section{Constructor Details}{


     The constructor must take a list of vectorised basis functions, whose length is equal
     to the number of regression coefficients, or an error will be thrown. The correlation
     structure should be stationary, or at least such that we can define \code{sigma} as a
     global variance: if an adjusted emulator is required, we supply an unadjusted u(x) and
     the corresponding data by which to adjust. The Bayes Linear update equations will then
     provide the modified (generally non-stationary) correlation structure. This has the
     advantage that if, after diagnostics, we need to inflate or deflate the overal variance,
     we can simply modify \code{sigma}.

     The use of a nugget is as follows. If we have a generic correlation structure with
     Cov[u(x), u(x')] = sigma^2*c(x,x'), where c(x,x') is some correlation function,
     then the addition of a nugget transforms this to
     Cov[u(x), u(x')] = sigma^2*(1-delta)*c(x,x')+sigma^2*delta*I(x,x'), where I(x,x')
     is an indicator function. The nugget maintains the variance at a point while deflating
     the covariance between points.
}

\section{Accessor Methods}{


     \code{get_exp(x)} Returns the emulator expectation at a collection of points, \code{x}.

     \code{get_cov(x, xp=NULL, full = FALSE)} Returns the covariance between collections of
     points \code{x} and \code{xp}. If no \code{xp} is supplied, then the covariance matrix
     for the points in \code{x} is calculated; if \code{full = TRUE}, the full covariance
     matrix is calculated; otherwise only the variances Var[f(x), f(x')] are calculated for
     each x in \code{x} and x' in \code{xp}.

     \code{print()} Returns a summary of the emulator specifications.

     \code{implausibility(x, z)} Returns the implausibility that input points \code{x} could
     give rise to an output \code{z}. The output \code{z} can be supplied in two ways: either
     as a list \code{z = list(val, sigma)} where \code{val} is the output and \code{sigma} the
     corresponding uncertainty (e.g. observation error, model discrepancy); or as a single
     numeric. In the latter case, the uncertainty is assumed to be identically 0 (tread with
     caution in these circumstances!)
}

\section{Object Methods}{


     \code{adjust(data, out_name)} Performs Bayes Linear adjustment, given the data. The data
     should contain all input parameters (even if they are not necessarily active for this
     emulator) and the single output. This function creates a new emulator object with the
     adjusted expectation and variance of beta as the primitive specifications, and supplies
     the data for the new emulator to compute the adjusted expectation and variance of u(x),
     and the adjusted Cov[beta, u(x)].
}

\examples{
basis_functions <- list(function(x) 1, function(x) x[[1]], function(x) x[[2]])
beta <- list(mu = c(1,2,3),
 sigma = matrix(c(0.5, -0.1, 0.2, -0.1, 1, 0, 0.2, 0, 1.5), nrow = 3))
u <- list(mu = function(x) 0, sigma = 3, corr = function(x, xp) exp_sq(x, xp, 0.1))
ranges <- list(a = c(-0.5, 0.5), b = c(-1, 2))
em <- Emulator$new(basis_functions, beta, u, ranges)
em
# Individual evaluations of points
em$get_exp(c(0.1, 0.1)) #> 0.6
em$get_cov(c(0.1, 0.1)) #> 9.5
# 4x4 grid of points
sample_points <- expand.grid(a = seq(-0.5, 0.5, length.out = 4), b = seq(-1, 2, length.out = 4))
em$get_exp(sample_points) # Returns 16 expectations
em$get_cov(sample_points) # Returns 16 variances
sample_points_2 <- expand.grid(a = seq(-0.5, 0.5, length.out = 3),
 b = seq(-1, 2, length.out = 4))
em$get_cov(sample_points, sample_points_2, full = TRUE) # Returns a 16x12 matrix of covariances

b_u_cov <- function(x) c(1, x[[1]], x[[1]]*x[[2]])
del <- 0.1
all_specs_em <- Emulator$new(basis_functions, beta, u, ranges,
 bucov = b_u_cov, delta = del)
all_specs_em$get_exp(c(0.1, 0.1)) #> 0.6
all_specs_em$get_cov(c(0.1, 0.1)) #> 11.60844

fake_data <- data.frame(a = runif(10, -0.5, 0.5), b = runif(10, -1, 2))
fake_data$c <- fake_data$a + 2*fake_data$b
newem <- em$adjust(fake_data, 'c')
all(round(newem$get_exp(fake_data[,names(ranges)]),5) == round(fake_data$c,5)) #>TRUE

newem_data <- Emulator$new(basis_functions, beta, u, ranges, data = fake_data)
all(round(newem$get_exp(fake_data[,names(ranges)]),5)
 == round(newem_data$get_exp(fake_data[,names(ranges)]), 5)) #>TRUE
}
