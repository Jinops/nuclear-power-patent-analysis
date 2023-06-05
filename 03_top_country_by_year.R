title <- sprintf("< Registrations >\nTOP%d countries by year\n(%s)", max, file_name)
data_top <- data[data$country %in% names(country_table_top), ]
country_year_table_top <- table(data_top$country, data_top$year)
print(country_year_table_top)
colors <- qualitative_hcl(nrow(country_year_table_top), palette = 'Dynamic')
barplot(country_year_table_top, beside = TRUE,
        main=title, xlab = "Year", ylab = "count",
        legend=rownames(country_year_table_top),
        col=colors)

title <- sprintf("< Applications >\nTOP%d countries by year\n(%s)", max, file_name)
data_top <- data[data$country %in% names(country_table_top), ]
country_year_table_top <- table(data_top$country, data_top$app_year)
print(country_year_table_top)
colors <- qualitative_hcl(nrow(country_year_table_top), palette = 'Dynamic')
barplot(country_year_table_top, beside = TRUE,
        main=title, xlab = "Year", ylab = "count",
        legend=rownames(country_year_table_top),
        col=colors)
