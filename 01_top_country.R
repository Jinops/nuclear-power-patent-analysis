title <- sprintf("TOP%d counties\n(%s)", max, file_name)
country_table <- table(data$country)
print(country_table)
country_table_sorted <- sort(country_table, decreasing=TRUE)
country_table_top <- country_table_sorted[1:max]
print(country_table_top)
barplot(country_table_top, main=title, xlab="country", ylab="count")

title <- sprintf("TOP%d counties\n(%s)", max, file_name)
country_table <- table(data$country)
print(country_table)
country_table_sorted <- sort(country_table, decreasing=TRUE)
country_table_top <- country_table_sorted[1:max]
print(country_table_top)
barplot(country_table_top, main=title, xlab="country", ylab="count")
