#' Read "FARS" data file
#'
#' This is a simple function that reads csv data file using read_csv from readr
#' package. The function begins with checking whether the filename provided to
#' the function as input exists before reading it as a dataframe in r.This function
#' has been customized NOT to display the progress report on reading time in an
#' interactive session.Additionally, while creating the data in R session, this
#' function ignores all simple messages in the context
#'
#' @param filename A character sting specifying the pathname of the file located
#' in the local computer.
#'
#' @importFrom readr read_csv
#'
#' @importFrom dplyr tbl_df
#'
#' @return This function returns a dataframe in R session after reading the
#' filename provided as parameter of the function
#'
#' @examples
#' \dontrun{
#' fars_read("~/data/accident_2013.csv.bz2")
#' }
#'
#' @export
#'
fars_read <- function(filename) {
        if(!file.exists(filename))
                stop("file '", filename, "' does not exist")
        data <- suppressMessages({
                readr::read_csv(filename, progress = FALSE)
        })
        dplyr::tbl_df(data)
}
#' Make data file name by the year
#'
#' This simple function creates filename depending on the year variable that is
#' being provided as an input of the function. The function takes the year as
#' a parameter of the function. The \code{year} parameter can be supplied as just a
#' number or a string. Inside the function it will be converted as integer.
#'
#' @param year a character string or number indicating year to create the filename
#'
#' @note This function uses a wrapper for the C function sprintf that takes R
#' objects. Inside sprintf the fmt specification must include the full pathname
#' so that the filename returned is available in the local computer.
#'
#' @return The function returns a character vector containing a formatted
#' combination of texts and parameter values \code{year}.
#'
#' @examples
#' \dontrun{
#' make_filename(2013)
#' }
#'
#' @export
make_filename <- function(year) {
        year <- as.integer(year)
        sprintf("accident_%d.csv.bz2", year)
}
#' Check and create valid years of FARS data
#'
#' This function creates multiple years of FARS data as specified by the
#' parameter \code{years}. The output of the function is a list of as many dataframes
#' as the number of years provided in the parameter. Each dataframe contains only
#' two varibales, year and MONTH. Additionally, the function
#' also provides additional mechanism for handling errors and warnings if the
#' input parameter \code{year} is not a valid year to be found in the read files.
#' No messages will be posted if there is no error or wanrings.
#'
#' @param years a list or vector containing year specification such as
#' (\code{years=c(2013,2014,2015)}) or using (\code{years=list(2013,2014,2015)})
#'
#' @importFrom dplyr %>%
#'
#' @importFrom dplyr mutate select
#'
#' @return This function returs a list of dataframes for each year as specified in
#' parameter (years) of the function. For example if one uses
#' (\code{years=c(2013,2014,2015)}) then there will be three dataframes in list
#' mode. Each dataframe will have two columns: Month and year.
#'
#' @examples
#' \dontrun{
#' fars_read_years(c(2013,2014,2015))
#' }
#'
#' @export
fars_read_years <- function(years) {
        lapply(years, function(year) {
                file <- make_filename(year)
                tryCatch({
                        dat <- fars_read(file)
                        dplyr::mutate(dat, year = year) %>%
                                dplyr::select(MONTH, year)
                }, error = function(e) {
                        warning("invalid year: ", year)
                        return(NULL)
                })
        })
}
#' Summarize monthly observations of fars data by year
#'
#' This is a function to summarize multiple dataframes, each representing a year.
#' The summary output is returned as a dataframe, containing number of monthly
#' observations for each year. Given a vector of years parameter, the function
#' begins with reading multiple years of data using another function
#' (\code{fars_read_years(years)}) included in this package.Next, the function also
#' uses 'dplyr' package to stack dataframes (dat_list) using (\code{bind_rows(dat_list)})
#' and group the observations of combined dataframe by year and month using
#' (\code{group_by(year,MONTH)}) function, whose output is then piped for summary
#' dataframe using (\code{summarize(n=n())}) function of \code{dplyr} package. Finally,
#' the output is piped to organize the monthly number of observatons by year using
#' (\code{spread(year,n)}) function imported from \code{tidyr} package.
#'
#' @param years a list or vector containing year specification such as
#' (\code{years=c(2013,2014,2015)}) or using (\code{years=list(2013,2014,2015)})
#'
#' @importFrom dplyr %>%
#'
#' @importFrom dplyr bind_rows group_by summarize
#'
#' @importFrom tidyr spread
#'
#' @return This function returns a dataframe, containing number of monthly observations
#' for each year. The monhly observations numbers are organized under columns of years,
#' each column representing a year.
#'
#' @examples
#' \dontrun{
#' fars_summarize_years(c(2013,2014,2015))
#' }
#'
#' @export
fars_summarize_years <- function(years) {
        dat_list <- fars_read_years(years)
        dplyr::bind_rows(dat_list) %>%
                dplyr::group_by(year, MONTH) %>%
                dplyr::summarize(n = n()) %>%
                tidyr::spread(year, n)
}
#' Map yearly traffic accidents occured in a state
#'
#' This function maps locations of accidents occured in each state of a specific
#' year. It provides messages if the state number is invalid or when there are no
#' accidents to plot in a state of a given year. Before creating a map for a state
#' all the missing observations involving Latitude and Longitude are removed from
#' the dataset.This function uses (\code{filter(data, state.num)}) from \code{dplyr}
#' package, and two other functions, one is (\code{map(state, ylim, xlim)}) from
#' \code{maps} package, and the other (\code{points(LONGITUD,LATITUD,pch)}) from
#' \code{graphics} package.
#'
#' @param state.num A number representing a state that is converted as integer.
#'
#' @param year A four-digit number representing a specific year
#'
#' @importFrom dplyr filter
#'
#' @importFrom maps map
#'
#' @importFrom graphics points
#'
#' @return The function returns a state-specific map of a year, pointing
#' fatal accident locations identified by dimensions of longitude and latitude.
#'
#' @examples
#' \dontrun{
#' fars_map_state(1,2013)
#' }
#'
#' @export
fars_map_state <- function(state.num, year) {
        filename <- make_filename(year)
        data <- fars_read(filename)
        state.num <- as.integer(state.num)

        if(!(state.num %in% unique(data$STATE)))
                stop("invalid STATE number: ", state.num)
        data.sub <- dplyr::filter(data, STATE == state.num)
        if(nrow(data.sub) == 0L) {
                message("no accidents to plot")
                return(invisible(NULL))
        }
        is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
        is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
        with(data.sub, {
                maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
                          xlim = range(LONGITUD, na.rm = TRUE))
                graphics::points(LONGITUD, LATITUDE, pch = 46)
        })
}
