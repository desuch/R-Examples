
number_of_selfloops_case <- function(eventlog) {
	stop_eventlog(eventlog)

	number_of_selfloops <- number_of_selfloops_trace(eventlog) %>% select(-relative_trace_frequency)
	cases <- cases_light(eventlog) %>% select(-trace_id)

	r <- merge(cases, number_of_selfloops) %>% select(-trace) %>% tbl_df()
	return(r)
}
