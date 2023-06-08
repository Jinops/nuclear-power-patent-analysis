title <- sprintf("< %s > %s\n TOP%d counties", data_about, file_name, max)
country_table <- table(data$country)
print(country_table)
country_table_sorted <- sort(country_table, decreasing=TRUE)
country_table_top <- country_table_sorted[1:max]
barplot(country_table_top, main=title, xlab="country", ylab="count")
