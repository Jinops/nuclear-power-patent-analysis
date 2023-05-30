library(jsonlite)
library(colorspace)

# Load data
if(is.null(file_name)){
  file_name <- "G21B"
}
data <- fromJSON(txt=paste('datas/',file_name,'.json',sep=''))$patents
sprintf('count of row: %d', nrow(data))
sprintf('count of column: %d', ncol(data))
print(colnames(data))

# For saving plots as pdf
pdf(paste('plots/',file_name,'.pdf',sep=''), width= 5, height= 5)

# Definition
max <- 5 # TOP countries number

# Preprocessing
data$year <- as.numeric(substr(data$patent_date, 1, 4))
# app year: sapply(1:nrow(data), function(i) as.numeric(substr(data[i,]$applications[[1]]$app_date,1, 4)))
data$country <- sapply(1:nrow(data), function(i) data[i,]$inventors[[1]]$inventor_country[1])

#1 Patent registration by year
title <- sprintf("Patent registration by year\n(%s)", file_name)
year_table <- table(data$year)
print(year_table)
barplot(year_table, 
        main=title, xlab="year", ylab="patent count")

#2 TOP patent inventors' counties
title <- sprintf("TOP%d patent inventors' counties\n(%s)", max, file_name)
country_table <- table(data$country)
print(country_table)
country_table_sorted <- sort(country_table, decreasing=TRUE)
country_table_top <- country_table_sorted[1:max]
print(country_table_top)
barplot(country_table_top, 
        main=title, xlab="country", ylab="count")

#3 TOP countries' patents by year
title <- sprintf("TOP%d countries' patents by year\n(%s)", max, file_name)
data_top <- data[data$country %in% names(country_table_top), ]
country_year_table_top <- table(data_top$country, data_top$year)
print(country_year_table_top)
colors <- qualitative_hcl(nrow(country_year_table_top), palette = 'Dynamic')
barplot(country_year_table_top, beside = TRUE,
        main=title, xlab = "Year", ylab = "Count",
        legend=rownames(country_year_table_top),
        col=colors)

dev.off()
