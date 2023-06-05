install.packages("stm")
install.packages("stringr")
install.packages("tm")
install.packages("stopwords")
library(stm)
library(stringr)
library(stopwords)
library(tm)

data_topic <- data[data$app_year >= 2019,] # for test
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

#add stopwords if need
#custom_add = c('10', '100', '11', '12', '14', '16', '20', '40', '50', 'ii')
#stopwords <- c(csw, custom_add)

#make new dummy variable
for(country in unique(myout$meta$country)){
  if(country %in% top_countries){
    myout$meta[country] <- ifelse(myout$meta$country == country, 1, 0)
  } 
}
for (i in 1:nrow(myout$meta)){
  print(myout$meta[i,]$country)

}

# TODO: generate equation
#print(paste(unique(myout$meta$country), sep='+'))
#regression_equation = paste(unique(myout$meta$country), sep='+')
#prevalence = parse(text=paste('~',regression_equation)[[1]])
prevalence =  ~ app_year + US + JP + KR + FR + DE 
print(prevalence)
print(myout)


#set number of topics for stm
topic_count = 4
#STM
mystm <- stm(myout$documents, myout$vocab, data=myout$meta,
             K=topic_count,
             prevalence = prevalence,
             seed = 16)
labelTopics(mystm, topics=1:topic_count, n=7)

plot(mystm, type = "summary", labeltype = "prob", text.cex = 1)
plot(mystm, type = "labels", labeltype = "prob", text.cex = 1)


# Find best topic count
topic_counts <- c(10, 15, 20) 
kresult <- searchK(myout$documents, myout$vocab, data=myout$meta,
                   topic_counts, 
                   prevalence = prevalence,
                   seed = 16)
plot(kresult)


#STM
topic_count <- 15
mystm <- stm(myout$documents, myout$vocab, data=myout$meta,
             K=topic_count,
             prevalence = prevalence,
             seed = 16)

plot(mystm, type = "summary", text.cex = 1)
labelTopics(mystm, topics=1:topic_count, n=7)

#myresult <- estimateEffect(prevalence, mystm, myout$meta) #difference??
print(names(myout$meta))
print(myout$meta$app_year)
myresult <- estimateEffect(c(1:topic_count) ~ app_year + US + JP+ KR + FR, mystm, myout$meta)
#myresult <- estimateEffect(c(1:topic_count) ~ app_year + US + JP + KR + FR + DE + app_year:US + app_year:JP + app_year:KR + app_year:FR + app_year:DE , mystm, myout$meta)
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
