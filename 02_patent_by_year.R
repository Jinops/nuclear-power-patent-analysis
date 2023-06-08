title <- sprintf("< %s > %s \nPatents by year", data_about, file_name)
year_table <- table(data$year)
print(year_table)
barplot(year_table, main=title, xlab="year", ylab="count")
