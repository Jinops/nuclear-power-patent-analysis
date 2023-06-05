install.packages("stm")
install.packages("stringr")
install.packages("stopwords")
library(stm)
library(stringr)
library(stopwords)

data_edited <- data_top[data_top$app_year == 2016,]
top_country <- unique(data_edited$country)

data_edited$text <- paste(data_edited$patent_title, " ", data_edited$patent_abstract)
data_edited$text <- str_replace_all(data_edited$text, '-', ' a ')

#stopwords from the stopword library
stopwords <- stopwords(language = "en", source = "smart")
custom <- c('invention', 'thereof', 'therefore', 'therefrom')
stopwords <- c(stopwords, custom)

#textProcessor
install.packages("tm")
library(tm)
mypreprocess <- textProcessor(data_edited$text, metadata = data_edited[c("country")]
                              , lowercase = TRUE
                              , removepunctuation = TRUE
                              , customstopwords = stopwords
                              , removestopwords = TRUE
                              , removenumbers = TRUE
                              , stem = TRUE
                              , wordLengths = c(2,Inf))

#prepDocuments
myout <-prepDocuments(mypreprocess$documents,
                      mypreprocess$vocab, mypreprocess$meta,
                      lower.thresh = 22)
myout$vocab

#add stopwords if need
#custom_add = c('10', '100', '11', '12', '14', '16', '20', '40', '50', 'ii')
#stopwords <- c(csw, custom_add)

#make new dummy variable
for(country in unique(myout$meta$country)){
  myout$meta[country] <- ifelse(myout$meta$country == country, 1, 0)
}

#set number of topics for stm
topic_count = 4
# TODO: generate equation
#print(paste(unique(myout$meta$country), sep='+'))
#regression_equation = paste(unique(myout$meta$country), sep='+')
#prevalence = parse(text=paste('~',regression_equation)[[1]])
prevalence =  ~ US + JP + KR + FR + DE
print(prevalence)
print(myout)
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

topic_count <- 15

#STM
mystm <- stm(myout$documents, myout$vocab, data=myout$meta,
             K=topic_count,
             prevalence = prevalence,
             seed = 16)

plot(mystm, type = "summary", text.cex = 1)
labelTopics(mystm, topics=1:topic_count, n=7)

#myresult <- estimateEffect(prevalence, mystm, myout$meta) #difference??
myresult <- estimateEffect(c(1:topic_count) ~ US + JP + KR + FR + DE, mystm, myout$meta) #difference??
result = summary(myresult)
print(result[3]$tables)
write.csv(result[3]$tables,file=paste0("effect_",Sys.time(),".csv"))

#beta
logbeta <- as.data.frame(mystm[["beta"]][["logbeta"]][[1]])
beta <- as.data.frame(exp(logbeta))
colnames(beta) <- myout$vocab
write.csv(beta, file=paste0("beta_",Sys.time(),".csv"), row.names=TRUE)
