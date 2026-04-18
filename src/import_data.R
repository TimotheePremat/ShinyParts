# Script to import data

# Function to select files with a persistent GUI
file_selector <- function() {
  shiny::runApp(
    list(
      ui = fluidPage(
        titlePanel("Select Files"),
        fileInput("background", "Background CSV"),
        fileInput("env_files", "Environment CSVs", multiple = TRUE),
        actionButton("ok", "OK")
      ),
      server = function(input, output, session) {
        observeEvent(input$ok, {
          req(input$background)
          stopApp(list(
            background = input$background$datapath,
            env_files  = input$env_files$datapath
          ))
        })
      }
    ),
    launch.browser = TRUE
  )
}

# Apply function
selection <- file_select
#####--------------



## Set default rep and format
default_folder <- "../data/*"
filter_format <- matrix(c("CSV", ".csv"),
						    1, 2, byrow = TRUE)

## Define Functions
select_input_table <- function(caption = "Select input table") {
  tk_choose.files(
    default = file.path(default_folder),
    caption = caption,
    multi = FALSE,
    filter = filter_format
  )
}

#--------------
# Import data
#--------------

# Import background data
background_data <- select_input_table(caption = "Select background data (all words)")
background_data <- read.csv(background_data, sep="\t", quote = "")

# Import length-object
env_data <- lapply(tk_choose.files(caption = "Select data for envs. Hold crtl or shift key for multiple selection."), function(file) {
  df <- read.csv(file, header = TRUE, sep = "\t", quote = "")
  df$type <- sub("\\.csv$", "", basename(file))  # Remove ".csv" and rename column to "type"
  return(df)
}) %>%
  bind_rows()  # Combine all data frames into one

# var_div <- readline(prompt = "\t Do you want to plot text divisions? [Y/n]\t\t")
choices <- c("Yes", "No")
var_div <- tk_select.list(choices, preselect = NULL, multiple = FALSE,
               title = "Do you wish to print text divisions?")

if (var_div %in% c("Y", "y", "yes", "Yes", "O", "o", "Oui", "oui")) {
# Import non-lenght objects
  div_data <- lapply(tk_choose.files(caption = "Select data for text division. Hold Ctrl or Shift key for multiple selection."), function(file) {
    df <- read.csv(file, header = TRUE, sep = "\t", quote = "", colClasses=c("character"))
    df$type <- sub("\\.csv$", "", basename(file))  # Remove ".csv" and rename column to "type"
    return(df)
  }) %>%
    bind_rows()  # Combine all data frames into one
}