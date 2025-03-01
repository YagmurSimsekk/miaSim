test_that("simulateStochasticLogistic", {
    # check simulateStochasticLogistic with 5 species and default inputs
    ExampleLogistic <- simulateStochasticLogistic(n_species = 5)
    expect_type(ExampleLogistic$matrix, "double")
    expect_equal(dim(ExampleLogistic$matrix), c(1000, 6))

    # check simulateStochasticLogistic with custom inputs
    ExampleLogistic2 <- simulateStochasticLogistic(
        n_species = 2, growth_rates = c(0.2, 0.1), carrying_capacities = c(1000, 2000),
        death_rates = c(0.001, 0.0015), x0 = c(3, 0.1),
        t_start = 0, t_end = 1500, t_step = 0.01,
        t_store = 1200, stochastic = TRUE
    )
    expect_type(ExampleLogistic2, "list")
    expect_equal(dim(t(ExampleLogistic2$matrix)), c(3, 1200))

    # check simulateStochasticLogistic with errors in inputs
    expect_error(ErrorLogistic1 <- simulateStochasticLogistic(n_species = 4.1))
    expect_error(ErrorLogistic2 <- simulateStochasticLogistic(
        n_species = 3, b = c(0.2, 0.1), k = c(1000, 2000),
        dr = c(0.001, 0.0015), x = c(3, 1)
    ))
    expect_error(ErrorLogistic3 <- simulateStochasticLogistic(
        n_species = 4, partial = FALSE, stochastic = 1
    ))
})
