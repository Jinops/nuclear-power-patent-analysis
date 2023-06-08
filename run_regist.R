library(jsonlite)
library(colorspace)

# Parameters
file_name <- "All"
is_pdf <- TRUE
max <- 5 # TOP countries number
data_about = 'Registration'

# For script
if(exists('file_name_loop')){
  file_name <- file_name_loop
}
if(is_pdf){
  pdf(paste0('plots/registrations/', file_name,'.pdf'), width= 5, height= 5)
}

# Load Data
data <- fromJSON(txt=paste0('datas/registrations/',file_name,'.json'))$patents
sprintf('count of row: %d', nrow(data))
sprintf('count of column: %d', ncol(data))
print(names(data))

# Preprocessing
patent_year <- as.numeric(substr(data$patent_date, 1, 4))
data$year <- patent_year

for (i in 1:nrow(data)){
  country <- data[i,]$assignees[[1]]$assignee_country[1]
  if (is.na(country))
    country <- data[i,]$inventors[[1]]$inventor_country[1]
  if (is.na(country))
    country <- 'unknown'
  data$country[i] <- country
}

source("01_top_country.R")

source("02_patent_by_year.R")

source("03_top_country_by_year.R")

if(is_pdf){
  dev.off()
}

#source("04_topic_model.R")
