library(jsonlite)

#load data
data <- fromJSON(txt="G21K.json")$patents
sprintf('count of row: %d', nrow(data))
sprintf('count of column: %d', ncol(data))
print(colnames(data))

# Preprocessing
data$year <- as.numeric(substr(data$patent_date, 1, 4))
data$country <- data$inventors[[1]]$inventor_country[[1]]
print(data$country) # TODO: wrong country
#1 Total Patents  by year
year_counts <- table(data$year)
print(year_counts)
barplot(year_counts, 
        main="Total patents by year", xlab="year", ylab="patent count")

#2 TOP application authority (country)
max <- 3
country_counts <- table(data$country)
print(country_counts)
country_counts_sorted <- sort(country_counts, decreasing=TRUE)
country_counts_top <- country_counts_sorted[1:max]
print(country_counts_top)
barplot(country_counts_top, 
        main=sprintf("TOP%d application authority", max), xlab="country", ylab="count")

#3 TOP countries' patents by year
top_country <- rownames(country_counts_top)
print(country_counts_top)
print(typeof(top_country))
topCountryData <- data[data$country %in% names(country_counts_top), ]
topCountryData_counts <- table(topCountryData$country, topCountryData$year)
print(topCountryData_counts)
barplot(topCountryData_counts, beside = TRUE,
        main=sprintf("TOP%d countries' patents by year", max), xlab = "Year", ylab = "Count",
        legend=rownames(topCountryData_counts))

