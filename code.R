data <- read.csv("sample.csv", fileEncoding='euc-kr')


### Total Patent count by year
sprintf('count of row: %d', nrow(data))
sprintf('count of column: %d', ncol(data))
print(colnames(data))

year <- data$Publication.Year
year_counts <- table(year)
print(year_counts)
barplot(year_counts, main="total patent count by year", xlab="year", ylab="patent count")

###
max <- 3
country <- data$Current.Assignee.Country
country_counts <- table(country)
print(country_count)
country_counts <- sort(country_count, decreasing=TRUE)
country_count <- country_count[1:max]
print(country_counts)
barplot(country_counts, main=sprintf("TOP%d application authority", max), xlab="year", ylab="country")
