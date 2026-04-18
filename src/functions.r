data_for_length <- function(data, position_col) {
  data %>%
    # ensure the position column is numeric for proper sorting
    mutate("{position_col}" := as.numeric(.data[[position_col]])) %>%
    # sort by the selected position column
    arrange(.data[[position_col]]) %>%
    # create group_id for consecutive runs of type
    mutate(group_id = cumsum(type != lag(type, default = first(type))) + 1)
}

compute_length <- function(data, position_col){
	data <- data %>%
		mutate("{position_col}" := as.numeric(.data[[position_col]])) %>%
		group_by(group_id) %>%
		summarise(
			type = first(type),
			last_row = last(group_id),
			first_index = first(.data[[position_col]]),
			last_index = last(.data[[position_col]]),
			std_date = first(std_date),
			.groups = "drop"
		) %>%
		mutate(length = last_index - first_index + 1)
}