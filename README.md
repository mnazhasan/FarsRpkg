# FarsRpkg

https://travis-ci.org/mnazhasan/FarsRpkg.svg?branch=master

https://travis-ci.org/travis-ci/travis-web

## An Overview of the Package

To provide an overall measure and assessment of highway safety in the Unites States, the National Highway Traffic Safety Administration (NHTSA) created the Fatality Analysis Reporting System (FARS). FARS contains census data on fatal motor vehicle crashes occurred in all 50 states of America, Puerto Rico, and the District of Columbia. For a quick review see [wikipedia](https://en.wikipedia.org/wiki/Fatality_Analysis_Reporting_System)

The objective of this package is to read the data into your local machine and analyze the data. The functions allows to summarize the fatlities occurrance for all states in a given month by year and produces Plots indicating the position of fatal accidents within a given state for a given year. This package has five functions written in R. The general descriptions of these packages are given separately in the subdirectory `man/` of this package.These functions are called:

1. fars_read 
2. make_filename
3. fars_read_years
4. fars_summarize_years
5. fars_map_state

## Accessing the Package

The latest development version of this package can be downloaded from GitHub using the `devtools` package:
```R
library(devtools)  
install_github("mnazhasan/FarsRpkg")  
library("FarsRpkg")
```


## Short Descriptions of the Functions

`1. fars_read:`   

This is a simple function that reads csv data file using `read_csv` function from `readr` package. The function begins with checking whether the filename provided to the function as input exists before reading it as a dataframe in `R`.This function returns a dataframe in R session after reading the
filename provided as parameter of the function

`2. make_file_name:`

This function creates a datafile name by year. It takes `year` as a parameter and returns a `character vector` containing a formatted combination of texts and parameter values `year.`

`3. fars_read_years:`   

This function creates multiple years of `FARS` data as specified by the
parameter `years`. The output of the function is a list of as many dataframes
as the number of years provided in the parameter. Each dataframe contains only
two varibales, `year` and `MONTH`. Additionally, the function
also provides additional mechanism for handling errors and warnings if the
input parameter `year` is not a valid year to be found in the read files.No messages will be posted if there is no error or wanrings.

`4. fars_summarize_years:`  

This is a function to summarize multiple dataframes, each representing a year. The summary output is returned as a dataframe, containing number of monthly
observations for each year. Given a vector of years parameter, the function
begins with reading multiple years of data using another function
`fars_read_years` included in this package. Next, the function also
uses 'dplyr' package to stack dataframes using `bind_rows` function, 
and group the observations of combined dataframe by year and month using
`group_by` function, whose output is then piped for summary
dataframe using `summarize` function of 'dplyr' package. Finally,
the output is piped to organize the monthly number of observatons by year using
`spread` function imported from 'tidyr' package.

`5. fars_map_state:`  

This function maps locations of accidents occured in each state of a specific
year. It provides messages if the state number is invalid or when there are no
accidents to plot in a state of a given year. Before creating a map for a state
all the missing observations involving Latitude and Longitude are removed from
the dataset.This function uses `filter` function from 'dplyr'package, and two other functions, one is `map` from `maps` package, and the other being `points` from `graphics` package.

## Usage of the Functions

Below we show how to use each of these functions. To begin we assume that in yourlocal directory `~/data` there are three years of `csv` datafiles, each representing a year namely 2013, 2014, and 2015.  

First, we use `fars_read` function to read 2013 datafile, `accident_2013.csv.bz2`. This returns a dataframe in R session. We could do the same thing for other two years of data. 

```R
fars_read("~data/accident_2013.csv.bz2")
```  

`fars_read` reads csv datafiles into `R session` and convert it into dataframe, but it needs a filename as parameter. The following function `make_filename` creates datafile name that uses `year` as a parameter, which can be supplied as just a number (such as 2013) or a string (such as "2013"). However, inside the function it will be converted as integer.

```R
make_filename(2013)
```  

The output of the above execution results in  
`> make_filename(2013)`  
`[1] "accident_2013.csv.bz2"`  

Given these two functions as described above, the following function creates three years of `R dataframes` and keeps only two variables `month` and `year`  

```R
fars_read_years(c(2013,2014,2015))
```  

The following function takes a vector of years and returns a data frame containing the fatality counts across all states for each month of the given years. This funtion makes use of the R packages `dplyr` and `readr`, which need to be installed as well.

```R
library(readr)  
library(dplyr)  
library(tidyr) 
fars_summarize_years(c(2013,2014,2015))
```

Finally, the following function produces an image of a given state's border and adds points on the map, representing locations of fatal motor vehicle accidents. The function also use other R packages `dplyr`, `readr`, `graphics`, and `maps`, which need to be installed before runing the function.

```R
library(readr)  
library(dplyr)  
library(maps)  
library(graphics)  
fars_map_state(state.num=1,year=2015)
```


