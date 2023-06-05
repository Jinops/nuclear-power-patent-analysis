title <- sprintf("< Registrations >\nPatents by year\n(%s)", file_name)
year_table <- table(data$year)
print(year_table)
barplot(year_table, main=title, xlab="year", ylab="count")

title <- sprintf("< Applications >\nPatents by year\n(%s)", file_name)
year_table <- table(data$app_year)
print(year_table)
barplot(year_table, main=title, xlab="year", ylab="count")
