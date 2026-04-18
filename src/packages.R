# Install and load packages

# ipak function: install and load multiple R packages.
# Check to see if packages are installed. Install them if they are not,
# then load them into the R session.

ipak <- function(pkg){
	options(repos = c(CRAN = "https://cloud.r-project.org"))
	new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
	if (length(new.pkg))
		install.packages(new.pkg, dependencies = TRUE)
	sapply(pkg, require, character.only = TRUE)
}

# usage
packages <- c('ggplot2',
	'dplyr',
	'forcats',
	'readr',
	'scales',
	'stringr',
	'tidyr',
	'tibble',
	'shiny',
	'lubridate',
	'gridExtra',
	'patchwork',
	'shinyjs',
	'DT',
	'purrr',
	'viridis',
	'bslib',
	'shinyBS',
	'bsicons')
	ipak(packages)
