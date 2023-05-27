data <- read.csv("sample.csv", fileEncoding='euc-kr')
sprintf('count of row: %d', nrow(data))
sprintf('count of column: %d', ncol(data))
print(colnames(data))

country = data$Current.Assignee.Country
year = data$Publication.Year
year_count = table(year)
print(year_count)
barplot(year_count, xlab="year", ylab="patent count")
