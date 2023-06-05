install.packages("stm")
install.packages("stringr")
install.packages("tm")
install.packages("stopwords")
library(stm)
library(stringr)
library(stopwords)
library(tm)

data_topic <- data
top_countries = names(country_table_top)

data_topic$text <- paste(data_topic$patent_title, " ", data_topic$patent_abstract)
data_topic$text <- str_replace_all(data_topic$text, '-', ' a ')

stopwords <- stopwords(language = "en", source = "smart")
custom <- c('invention', 'thereof', 'therefore', 'therefrom')
stopwords <- c(stopwords, custom)

# Preprocessing - textProcessor
mypreprocess <- textProcessor(data_topic$text, metadata = data_topic[c("app_year", "country")]
                              , lowercase = TRUE
                              , removepunctuation = TRUE
                              , customstopwords = stopwords
                              , removestopwords = TRUE
                              , removenumbers = TRUE
                              , stem = TRUE
                              , wordLengths = c(2,Inf))

# Get output
myout <-prepDocuments(mypreprocess$documents,
                      mypreprocess$vocab, mypreprocess$meta,
                      lower.thresh = nrow(data_topic)/100)
myout$vocab

#add stopwords
custom_add <- c('ad','analyz','annular','appli','applic','caus','characterist','equal','equip','euv','event','frequenc','height','high','higher','introduc','involv','length','level','make','oppos','opposit','paramet','prefer','requir')
custom_add <- c(custom_add, 'includ', 'total', 'tool', 'valu', 'width', 'set', 'result', 'plus', 'measur', 'later', 'includ', 'high', 'enabl')
stopwords <- c(stopwords, custom_add)
print(custom_add)

mypreprocess <- textProcessor(data_topic$text, metadata = data_topic[c("app_year", "country")]
                              , lowercase = TRUE
                              , removepunctuation = TRUE
                              , customstopwords = stopwords
                              , removestopwords = TRUE
                              , removenumbers = TRUE
                              , stem = TRUE
                              , wordLengths = c(2,Inf))

myout <-prepDocuments(mypreprocess$documents,
                      mypreprocess$vocab, mypreprocess$meta,
                      lower.thresh = nrow(data_topic)/100)
myout$vocab

#make new dummy variable
for(country in top_countries){
  myout$meta[country] <- ifelse(myout$meta$country == country, 1, 0)
}
myout$meta$etc <- ifelse(myout$meta$country %in% top_countries, 0, 1)

# TODO: generate equation
#print(paste(unique(myout$meta$country), sep='+'))
#regression_equation = paste(unique(myout$meta$country), sep='+')
#prevalence = parse(text=paste('~',regression_equation)[[1]])
prevalence =  ~ app_year + US + JP + KR + FR + DE 

# Find best topic count
topic_counts <- c(10, 30, 50) 
kresult <- searchK(myout$documents, myout$vocab, data=myout$meta,
                   topic_counts, 
                   prevalence = prevalence,
                   seed = 16)
plot(kresult)


#STM
topic_count <- 30
mystm <- stm(myout$documents, myout$vocab, data=myout$meta,
             K=topic_count,
             prevalence = prevalence,
             seed = 16)

plot(mystm, type = "summary", labeltype = "prob", text.cex = 1)
plot(mystm, type = "labels", labeltype = "prob", text.cex = 1)
labelTopics(mystm, topics=1:topic_count, n=7)


print(names(myout$meta))
reg = c(1:topic_count) ~ app_year + US + JP + KR + FR + DE + app_year:US + app_year:JP + app_year:KR + app_year:FR +  + app_year:DE
myresult <- estimateEffect(reg, mystm, myout$meta)
result = summary(myresult)
print(result[3]$tables)
write.csv(result[3]$tables,file=paste0("effect_",Sys.time(),".csv"))

#beta
logbeta <- as.data.frame(mystm[["beta"]][["logbeta"]][[1]])
beta <- as.data.frame(exp(logbeta))
colnames(beta) <- myout$vocab
colnames(logbeta) <- myout$vocab
write.csv(beta, file=paste0("beta_",Sys.time(),".csv"), row.names=TRUE)
write.csv(logbeta, file=paste0("logbeta_",Sys.time(),".csv"), row.names=TRUE)
