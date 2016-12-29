library(testthat)
library(FarsRpkg)

# there is only one dataset for the year 2013

context("check correct filename")
test_that("correct filename", {
  expect_match(make_filename(2013), "accident_2013.csv.bz2")
})

test_that("correct class", {
  expect_is(fars_read("~/data/accident_2013.csv.bz2"), "data.frame")
})

test_that("warning message", {
  expect_warning(fars_read_years(2010))
})

