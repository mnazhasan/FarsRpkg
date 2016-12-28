library(testthat)
library(FarsRpkg)

test_check("FarsRpkg")
# there is only one dataset for the year 2013
data_2013<-fars_read("~/data/accident_2013.csv.bz2")
expect_is(data_2013,"data.frame")
filename<-make_filename(2013)
expect_is(filename,"character")
expect_warning(fars_read_years(2010))


