#' WDI: World Development Indicators (World Bank)
#' 
#' Downloads the requested data by using the World Bank's API, parses the
#' resulting JSON file, and formats it in long country-year format. 
#' 
#' @param country Vector of countries (ISO-2 character codes, e.g. "BR", "US",
#'     "CA") for which the data is needed. Using the string "all" instead of
#'     individual iso codes pulls data for every available country.
#' @param indicator Character vector of indicators codes. See the WDIsearch()
#'     function.
#' @param start First year of data
#' @param end Last year of data
#' @param extra TRUE returns extra variables such as region, iso3c code, and
#'     incomeLevel
#' @param cache NULL (optional) a list created by WDIcache() to be used with the
#'     extra=TRUE argument
#' @return Data frame with country-year observations 
#' @author Vincent Arel-Bundock \email{varel@@umich.edu}
#' @export
#' @examples
#' WDI(country="all", indicator=c("AG.AGR.TRAC.NO","TM.TAX.TCOM.BC.ZS"),
#'     start=1990, end=2000)
#' WDI(country=c("US","BR"), indicator="NY.GNS.ICTR.GN.ZS", start=1999, end=2000,
#'     extra=TRUE, cache=NULL)
WDI <- function(country = "all", indicator = "NY.GNS.ICTR.GN.ZS", start = 2005,
                end = 2011, extra = FALSE, cache=NULL){

    # Sanity checks
    indicator = gsub('[^a-zA-Z0-9\\.]', '', indicator)
    country   = gsub('[^a-zA-Z0-9]', '', country)
    if(!('all' %in% country)){
        country_bad = country[!(country %in% WDI_data$country[,'iso2c'])]
        country = country[!(country %in% country_bad)]
        if(length(country_bad) > 0){
            warning(paste('Unable to download data on countries: ', paste(country_bad, collapse=', ')))
        }
        if(length(country) > 0){
            country = paste(country, collapse=';')
        }else{
            stop('No valid country was requested')
        }
    }else{
        country = 'all'
    }
    if(!(start <= end)){
        stop('start/end must be integers with start <= end')
    }
    # Download
    dat = lapply(indicator, function(j) try(wdi.dl(j, country, start, end), silent=TRUE))
    # Raise warning if download fails 
    good = unlist(lapply(dat, function(i) class(i)) == 'data.frame')
    if(any(!good)){
        warning(paste('Unable to download indicators ', paste(indicator[!good], collapse=' ; ')))
    }
    dat = dat[good] 
    dat = Reduce(function(x,y) merge(x,y,all=TRUE), dat)
    # EXTRAS
    if(!is.null(cache)){
        country_data = cache$country
    }else{
        country_data = WDI_data$country
    }
    if(extra==TRUE){
	    dat = merge(dat, country_data, all.x=TRUE)
    }
    countries = country[country != 'all' & !(country %in% dat$iso2c)]
    if(length(countries) > 0){
    }
    return(dat)
}

wdi.dl = function(indicator, country, start, end){
    daturl = paste("http://api.worldbank.org/countries/", country, "/indicators/", indicator,
                    "?date=",start,":",end, "&per_page=25000", "&format=json", sep = "")
    dat = RJSONIO::fromJSON(daturl, nullValue=NA)[[2]]
    dat = lapply(dat, function(j) cbind(j$country[[1]], j$country[[2]], j$value, j$date))
    dat = data.frame(do.call('rbind', dat))
    for(i in 1:4){
        dat[,i] = as.character(dat[,i])
    }
    dat[,3] = as.numeric(dat[,3])
    dat[,4] = as.numeric(dat[,4])
    colnames(dat) = c('iso2c', 'country', as.character(indicator), 'year')
    # Bad data in WDI JSON files require me to impose this constraint
    dat = dat[!is.na(dat$year) & dat$year <= end & dat$year >= start,]
    return(dat)
}

#' Update the list of available WDI indicators
#' 
#' Download an updated list of available WDI indicators from the World Bank
#' website. Returns a data frame for use in the \code{WDIsearch} function. 
#' 
#' @return Series of indicators, sources and descriptions in data frame format  
#' @note Downloading all series information from the World Bank website can take
#'     time.
#' 
#'     The \code{WDI} package ships with a local data object with information on all
#'     the series available on 2012-06-18. You can update this database by retrieving
#'     a new list using \code{WDIcache}, and  then feeding the resulting object to
#'     \code{WDIsearch} via the \code{cache} argument. 
#' @export
WDIcache = function(){
    # Series
    series_url = 'http://api.worldbank.org/indicators?per_page=25000&format=json'
    series_dat    = fromJSON(series_url, nullValue=NA)[[2]]
    series_dat = lapply(series_dat, function(k) cbind(
                        'indicator'=k$id, 'name'=k$name, 'description'=k$sourceNote, 
                        'sourceDatabase'=k$source[2], 'sourceOrganization'=k$sourceOrganization)) 
    series_dat = do.call('rbind', series_dat)          
    # Countries
    country_url = 'http://api.worldbank.org/countries/all?per_page=25000&format=json'
    country_dat = fromJSON(country_url, nullValue=NA)[[2]]
    country_dat = lapply(country_dat, function(k) cbind(
                         'iso3c'=k$id, 'iso2c'=k$iso2Code, 'country'=k$name, 'region'=k$region[2],
                         'capital'=k$capitalCity, 'longitude'=k$longitude, 'latitude'=k$latitude, 
                         'income'=k$incomeLevel[2], 'lending'=k$lendingType[2])) 
    country_dat = do.call('rbind', country_dat)
    row.names(country_dat) = row.names(series_dat) = NULL
    return(list('series'=series_dat, 'country'=country_dat))
}

#' Search names and descriptions of available WDI series
#' 
#' Data frame with series code, name, description, and source for the WDI series
#' which match the given criteria
#' 
#' @param string Character string. Search for this string using \code{grep} with
#'     \code{ignore.case=TRUE}.
#' @param field Character string. Search this field. Admissible fields:
#'     'indicator', 'name', 'description', 'sourceDatabase', 'sourceOrganization'
#' @param short TRUE: Returns only the indicator's code and name. FALSE: Returns
#'     the indicator's code, name, description, and source.
#' @param cache Data list generated by the \code{WDIcache} function. If omitted,
#'     \code{WDIsearch} will search a local list of series.  
#' @return Data frame with code, name, source, and description of all series which
#'     match the criteria.  
#' @export
#' @examples
#' WDIsearch(string='gdp', field='name', cache=NULL)
#' WDIsearch(string='AG.AGR.TRAC.NO', field='indicator', cache=NULL)
WDIsearch <- function(string="gdp", field="name", short=TRUE, cache=NULL){
    if(!is.null(cache)){
        series = cache$series    
    }else{
        series = WDI_data$series
    }
    matches = grep(string, series[,field], ignore.case=TRUE)
    if(short){
        out = series[matches, c('indicator', 'name')]
    }else{
        out = series[matches,]
    }
    return(out)
}
