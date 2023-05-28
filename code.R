library(jsonlite)

#load data
file_name <- "G21K"
file_format <- ".json"
file_path <- "./data/"
data <- fromJSON(txt=paste(file_path,file_name,file_format, sep=''))$patents
sprintf('count of row: %d', nrow(data))
sprintf('count of column: %d', ncol(data))
print(colnames(data))

# Preprocessing
data$year <- as.numeric(substr(data$patent_date, 1, 4))
data$country <- sapply(1:nrow(data), function(i) data[i,]$inventors[[1]]$inventor_country[1])

#1 Total Patents  by year
title <- sprintf("Total patents by year\n(%s)", file_name)
year_counts <- table(data$year)
print(year_counts)
barplot(year_counts, 
        main=title, xlab="year", ylab="patent count")

#2 TOP patent inventors' counties
title <- sprintf("TOP%d patent inventors' counties\n(%s)", max, file_name)
max <- 5
country_counts <- table(data$country)
print(country_counts)
country_counts_sorted <- sort(country_counts, decreasing=TRUE)
country_counts_top <- country_counts_sorted[1:max]
print(country_counts_top)
barplot(country_counts_top, 
        main=title, xlab="country", ylab="count")

#3 TOP countries' patents by year
title <- sprintf("TOP%d countries' patents by year\n(%s)", max, file_name)
top_country <- rownames(country_counts_top)
print(country_counts_top)
print(typeof(top_country))
topCountryData <- data[data$country %in% names(country_counts_top), ]
topCountryData_counts <- table(topCountryData$country, topCountryData$year)
print(topCountryData_counts)
barplot(topCountryData_counts, beside = TRUE,
        main=title, xlab = "Year", ylab = "Count",
        legend=rownames(topCountryData_counts))

