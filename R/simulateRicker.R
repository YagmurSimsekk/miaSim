#' Generate time series with the Ricker model
#'
#' The Ricker model is a discrete version of the generalized
#' Lotka-Volterra model and is implemented here as proposed by Fisher and Mehta
#' in PLoS ONE 2014.
#'
#' @template man_spe
#' @param A interaction matrix
#' @param x0 Numeric: initial abundances of simulated species. If NULL,
#' `runif(n = n_species, min = 0, max = 1)` is used.
#' @param carrying_capacities numeric carrying capacities. If NULL,
#' `runif(n = n_species, min = 0, max = 1)` is used.
#' @template man_mod
#' @param error_variance Numeric: the variance of measurement error.
#' By default it equals to 0, indicating that the result won't contain any
#' measurement error. This value should be non-negative.
#' (default: \code{error_variance = 0.05})
#' @param explosion_bound numeric value of boundary for explosion
#' (default: \code{explosion_bound = 10^8})

#' @param t_end integer number of simulations to be simulated
#' @param norm logical scalar returning normalised abundances (proportions
#' in each generation) (default: \code{norm = FALSE})
#'
#' @seealso
#' \code{\link[miaSim:convertToSE]{convertToSE}}
#'
#' @return
#' \code{simulateRicker} returns an abundance matrix with species abundance
#' as rows and time points as columns
#'
#' @references Fisher & Mehta (2014). Identifying Keystone Species in the Human
#' Gut Microbiome from Metagenomic Timeseries using Sparse Linear Regression.
#' PLoS One 9:e102451
#'
#' @examples
#' A <- powerlawA(10, alpha = 1.01)
#' x0 <- simulateRicker(n_species = 10, A, t_end = 100)
#'
#' @importFrom stats rlnorm rgamma
#' @importFrom MatrixGenerics colSums2
#' @export
simulateRicker <- function(n_species,
    A,
    names_species = NULL,
    x0 = runif(n_species),
    carrying_capacities = runif(n_species),
    error_variance = 0.05,
    explosion_bound = 10^8,
    t_end = 1000,
    norm = FALSE,
    ...) {
    if (is.null(names_species)) {
        names_species <- paste0("sp", seq_len(n_species))
    }
    t_dyn <- simulationTimes(t_end = t_end, ...)

    if (length(x0) != n_species) {
        stop("x0 needs to have n_species entries.")
    }
    if (nrow(A) != n_species || ncol(A) != n_species) {
        stop("A needs to have n_species rows and n_species columns.")
    }
    if (length(carrying_capacities) != n_species) {
        stop("carrying_capacities needs to have n_species entries.")
    }

    out_matrix <- matrix(nrow = length(t_dyn$t_sys), ncol = n_species)
    # out_matrix[1,] <- x0

    # simulate difference equation
    for (nth_row in seq_len(length(t_dyn$t_sys))) {
        if (error_variance > 0) {
            # b <- rgamma(n_species, 1/error_variance, 1/error_variance)
            b <- rlnorm(n_species, meanlog = 0, sdlog = error_variance)
        } else {
            b <- rep(1, n_species)
        }
        x0 <- b * x0 * exp(A %*% (x0 - carrying_capacities))
        if (max(x0) > explosion_bound) {
            # report which species explodes
            stop("Explosion for species ", which(x0 == max(x0)))
        }
        if (length(x0[x0 < 0]) > 0) {
            stop("Species below 0!")
        }
        out_matrix[nth_row, ] <- as.vector(x0)
    }
    if (norm) {
        out_matrix <- out_matrix / rowSums(out_matrix)
    }
    colnames(out_matrix) <- names_species
    out_matrix <- cbind(out_matrix, time = t_dyn$t_sys)
    out_matrix <- out_matrix[t_dyn$t_index, ]
    out_list <- list(
        matrix = out_matrix,
        x0 = x0,
        A = A,
        carrying_capacities = carrying_capacities,
        error_variance = error_variance,
        norm = norm
    )
    return(out_list)
}
