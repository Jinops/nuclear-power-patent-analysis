library(jsonlite)
library(colorspace)

# Parameters
file_name <- "All"
is_pdf <- TRUE
max <- 5 # TOP countries number
data_about = 'Application'

# For script
if(exists('file_name_loop')){
  file_name <- file_name_loop
}
if(is_pdf){
  pdf(paste0('plots/applications/', file_name,'.pdf'), width= 5, height= 5)
}

# Load Data
data <- read.csv(paste0('datas/applications/',file_name,'.csv'))
sprintf('count of row: %d', nrow(data))
sprintf('count of column: %d', ncol(data))
print(names(data))

# Preprocessing
data$year <- data$published_date
data$country <- data$disambig_country
data$patent_title <- data$application_title
data$patent_abstract <- data$application_abstract

source("01_top_country.R")

source("02_patent_by_year.R")

source("03_top_country_by_year.R")

if(is_pdf){
  dev.off()
}

#source("04_topic_model.R")
