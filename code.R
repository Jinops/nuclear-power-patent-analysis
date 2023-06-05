library(jsonlite)
library(colorspace)

file_name <- "All"
# Load data
if(is.null(file_name)){
  file_name <- "G21B"
}
data <- fromJSON(txt=paste('datas/',file_name,'.json',sep=''))$patents
sprintf('count of row: %d', nrow(data))
sprintf('count of column: %d', ncol(data))
print(data$text[1])

# For saving plots as pdf
pdf(paste('plots/',file_name,'.pdf',sep=''), width= 5, height= 5)

# Definition
max <- 5 # TOP countries number

# Preprocessing
patent_year <- as.numeric(substr(data$patent_date, 1, 4))
app_year <- sapply(1:nrow(data), function(i) as.numeric(substr(data[i,]$applications[[1]]$app_date,1, 4)))
data$year <- patent_year
for (i in 1:nrow(data)){
  country <- data[i,]$assignees[[1]]$assignee_country[1]
  if (is.na(country))
    country <- data[i,]$inventors[[1]]$inventor_country[1]
  if (is.na(country))
    country <- 'unknown'
  data$country[i] <- country
}
print(data$country)

#1 Patent registrations by year
title <- sprintf("Patent registrations by year\n(%s)", file_name)
year_table <- table(data$year)
print(year_table)
barplot(year_table, 
        main=title, xlab="year", ylab="patent count")

#2 TOP counties
title <- sprintf("TOP%d counties\n(%s)", max, file_name)
country_table <- table(data$country)
print(country_table)
country_table_sorted <- sort(country_table, decreasing=TRUE)
country_table_top <- country_table_sorted[1:max]
print(country_table_top)
barplot(country_table_top, 
        main=title, xlab="country", ylab="count")

#3 TOP countries' by year
title <- sprintf("TOP%d countries by year\n(%s)", max, file_name)
data_top <- data[data$country %in% names(country_table_top), ]
country_year_table_top <- table(data_top$country, data_top$year)
print(country_year_table_top)
colors <- qualitative_hcl(nrow(country_year_table_top), palette = 'Dynamic')
barplot(country_year_table_top, beside = TRUE,
        main=title, xlab = "Year", ylab = "Count",
        legend=rownames(country_year_table_top),
        col=colors)

dev.off()

#4 topic_model
source("topic_model.R")
