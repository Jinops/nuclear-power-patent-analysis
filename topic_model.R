install.packages("stm")
install.packages("stringr")
install.packages("stopwords")
library(stm)
library(stringr)
library(stopwords)

data$text <- paste(data$patent_title, " ", data$patent_abstract)
data$text <- str_replace_all(data$text, '-', ' a ')

#stopwords from the stopword library
stopwords <- stopwords(language = "en", source = "smart")
custom <- c('invention', 'thereof', 'therefore', 'therefrom')
stopwords <- c(stopwords, custom)

#textProcessor
install.packages("tm")
library(tm)
mypreprocess <- textProcessor(data$text, metadata = data[c("country")]
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
print(table(myout$meta$country))
myout$meta$US <- ifelse(myout$meta$country == 'US', 1, 0)
myout$meta$JP <- ifelse(myout$meta$country == 'JP', 1, 0)
myout$meta$DE <- ifelse(myout$meta$country == 'DE', 1, 0)
myout$meta$FR <- ifelse(myout$meta$country == 'FR', 1, 0)
myout$meta$KR <- ifelse(myout$meta$country == 'KR', 1, 0)

#set number of topics for stm
topic_count = 4
prevalence =  ~ US + JP + DE + FR + KR

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

myresult <- estimateEffect(prevalence, mystm, myout$meta) #difference??
#myresult <- estimateEffect(c(1:topic_count) ~ US + JP + DE + FR + KR, mystm, myout$meta) #difference??
result = summary(myresult)
print(result[3]$tables)
write.csv(result[3]$tables,file=paste0("effect_",Sys.time(),".csv"))

#beta
logbeta <- as.data.frame(mystm[["beta"]][["logbeta"]][[1]])
beta <- as.data.frame(exp(logbeta))
colnames(beta) <- myout$vocab
write.csv(beta, file=paste0("beta_",Sys.time(),".csv"), row.names=TRUE)
