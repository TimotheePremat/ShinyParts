# Function to clean datasets
# prepare_data <- function(df, type){
# 	df <- df %>% select(-ContexteGauche, -ContexteDroit) %>%
# 	mutate(type = paste(type)) %>%
# 	rename(text_id = Référence) %>%
# 	separate(text_id, into = c("text_id", "date", "term"), sep = ",") %>%
#     mutate(form_id = as.numeric(str_extract(text_id, "(?<=_)[0-9]+$"))) %>%
# 	rename(form = Pivot)
# }

# Apply functions

## Background
# background_data <- prepare_data(background_data, "background")

# background_lenght <- tail(background_data$form_id, 1) - head(background_data$form_id, 1) + 1

# ## Env_data
# env_data <- prepare_data(env_data, paste(name_lenght_object))

# ## Div data
# if (var_div %in% c("Y", "y", "yes", "Yes", "O", "o", "Oui", "oui")) {
# 	div_data <- prepare_data(div_data, paste(name_lenght_object))
# }
# #----------------------------------
# # Merge and process merged datasets
# #----------------------------------

# # Merge
# background_data_filtered <- anti_join(background_data, env_data, by="text_id")
# data <- bind_rows(background_data_filtered, env_data) %>%
#     arrange(form_id)
# data$date <- as.Date(as.character(data$date))

#Process merged dataset

## Define functions
data_for_length <- function(data){
        # Create a unique group identifier for each run of the same value in type
        data %>% mutate(group_id = cumsum(type != lag(type, default = first(type))) + 1)
}

compute_length <- function(data){
	data <- data %>%
		group_by(group_id) %>%
		summarise(
			type = first(type),
			last_row = last(group_id),
			first_index = first(form_id),
			last_index = last(form_id),
			.groups = "drop"
		) %>%
		mutate(length = last_index - first_index + 1)
}

## Apply functions
data_for_length <- data_for_length(data)
data_length <- compute_length(data_for_length)

## Branch out a df for time series
data_time <- data %>%
  group_by(date, type) %>%
  summarise(n = n()) %>% 						   # To count number of rows
  group_by(date) %>%                               # Re-group by time to calculate within-time percentages
  mutate(percentage = n / sum(n)) %>%                 # Percentage of total per time
  mutate(type = factor(type, levels = c("background",
  	"unknown",
  	"other",
  	"consulting_members",
  	"college_etudiant",
  	"college_biatss",
  	"college_chercheur",
  	"college_c",
  	"college_b",
  	"college_a",
  	"conseil",
  	"presidential_office")))

# do the same excluding pseudo NAs
data_time_noNA <- data %>%
  filter(!type %in% c("background", "unknown", "other")) %>%
    group_by(date, type) %>%
    summarise(n = n()) %>% 						   # To count number of rows
    group_by(date) %>%                               # Re-group by time to calculate within-time percentages
    mutate(percentage = n / sum(n)) %>%                 # Percentage of total per time
    mutate(type = factor(type, levels = c("consulting_members",
    	"college_etudiant",
    	"college_biatss",
    	"college_chercheur",
    	"college_c",
    	"college_b",
    	"college_a",
    	"conseil",
    	"presidential_office")))
