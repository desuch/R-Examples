# tests for tax_name fxn in taxize
context("tax_rank")

A <- tax_rank(query = c("Helianthus annuus", "Baetis"), db = "ncbi", verbose=FALSE)
B <- tax_rank(query = "Helianthus", db = "itis", verbose=FALSE)
C <- tax_rank(query = c("Helianthus annuus", "xxxxxx"), db = "ncbi", verbose=FALSE)

test_that("tax_rank returns the correct class", {
  expect_that(A, is_a("data.frame"))
  expect_that(B, is_a("data.frame"))
  expect_that(C, is_a("data.frame"))
  expect_equal(names(C), 'rank')
})

test_that("tax_name returns the correct value", {
  expect_equal(A$rank[1], "species")
  expect_true(is.na(C$rank[2]))
})

test_that("tax_name works with vectors", {
  expect_that(nrow(A), equals(2))
  expect_that(nrow(C), equals(2))
})
