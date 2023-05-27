data <- read.csv("sample.csv", fileEncoding='euc-kr')

### Total Patents  by year
sprintf('count of row: %d', nrow(data))
sprintf('count of column: %d', ncol(data))
print(colnames(data))

yearData <- data$Publication.Year
year_counts <- table(yearData)
print(year_counts)
barplot(year_counts, 
        main="Total patents by year", xlab="year", ylab="patent count")

### TOP application authority (country)
max <- 3
country_counts <- table(data$Current.Assignee.Country)
print(country_counts)
country_counts_sorted <- sort(country_counts, decreasing=TRUE)
country_counts_top <- country_counts_sorted[1:max]
print(country_counts_top)
barplot(country_counts_top, 
        main=sprintf("TOP%d application authority", max), xlab="country", ylab="count")

### TOP countries' patents by year
top_country <- rownames(country_counts_top)
print(country_counts_top)
print(typeof(top_country))
topCountryData <- data[data$Current.Assignee.Country %in% names(country_counts_top), ]
topCountryData_counts <- table(topCountryData$Current.Assignee.Country, topCountryData$Publication.Year)
print(topCountryData_counts)
barplot(topCountryData_counts, beside = TRUE,
        main=sprintf("TOP%d countries' patents by year", max), xlab = "Year", ylab = "Count",
        legend=rownames(topCountryData_counts), col = c("red", "green", "blue"))

