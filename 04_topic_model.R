library(stm)
library(stringr)
library(stopwords)

prevalence =  ~ app_year + US + JP + KR + FR + DE 
reg = c(1:topic_count) ~ app_year + US + JP + KR + FR + DE
reg_cross = c(1:topic_count) ~ app_year + US + JP + KR + FR + DE + app_year:US + app_year:JP + app_year:KR + app_year:FR + app_year:DE
#reg_cross = lm(c(1:topic_count) ~ app_year + US + JP + KR + FR + DE  + app_year:US + app_year:JP + app_year:KR + app_year:FR + app_year:DE, data=myout$meta)

data_topic <- data
top_countries = names(country_table_top)

data_topic$text <- paste(data_topic$patent_title, " ", data_topic$patent_abstract)
data_topic$text <- str_replace_all(data_topic$text, '-', ' a ')

stopwords <- stopwords(language = "en", source = "smart")
stopwords_add <- c('invention', 'thereof', 'therefore', 'therefrom')
stopwords <- c(stopwords, stopwords_add)

# Preprocessing - textProcessor
library(tm)
mypreprocess <- textProcessor(data_topic$text, metadata = data_topic[c("app_year", "country")]
                              , lowercase = TRUE
                              , removepunctuation = TRUE
                              , customstopwords = stopwords
                              , removestopwords = TRUE
                              , removenumbers = TRUE
                              , stem = TRUE
                              , wordLengths = c(2,Inf))

# Get vocab
myout <-prepDocuments(mypreprocess$documents,
                      mypreprocess$vocab, mypreprocess$meta,
                      lower.thresh = nrow(data_topic)/100)
myout$vocab

# Add stopwords
stopwords_add <- c(stopwords_add, 'ad','analyz','annular','appli','applic','caus','characterist','equal','equip','euv','event','frequenc','height','high','higher','introduc','involv','length','level','make','oppos','opposit','paramet','prefer','requir')
stopwords_add <- c(stopwords_add, 'includ', 'total', 'tool', 'valu', 'width', 'set', 'result', 'plus', 'measur', 'later', 'includ', 'high', 'enabl')
stopwords_add <- c(stopwords_add, 'method', 'contain', 'target', 'control', 'unit', 'end', 'imag', 'object')
stopwords_add <- c(stopwords_add, 'system','product','process','contain','case','measur','determin','base')
stopwords_add <- c(stopwords_add, 'achiev', 'allow', 'ad', 'accommod', 'achiev', 'anim', 'acquir', 'actuat', 'adjac', 'agent', 'altern', 'allow', 'analysi', 'andor', 'angl', 'appli', 'applic', 'aspect', 'averag', 'capabl', 'bundl', 'caus', 'caviti', 'circumferenti')
stopwords_add <- c(stopwords_add, "oper",  "oppos","paramet","posit",  "primari","receiv", "propag","pre" , "reduc")
stopwords_add <- c(stopwords_add, "end", "ensur", "extrem", "exemplari", "fast", "hous", "general", "group")
stopwords_add <- c(stopwords_add, "comput", "conduct", "contrast", "cost", "data", "differ", "display", "continu", "critic", "due") 
stopwords_add <- c(stopwords_add, "inside", "intense", "interior", "introduc", "later", "lock", "longitudin", "main", "mean")
stopwords <- c(stopwords, stopwords_add) 

mypreprocess <- textProcessor(data_topic$text, metadata = data_topic[c("app_year", "country")]
                              , lowercase = TRUE
                              , removepunctuation = TRUE
                              , customstopwords = stopwords #TODO: it may not work
                              , removestopwords = TRUE
                              , removenumbers = TRUE
                              , stem = TRUE
                              , wordLengths = c(2,Inf))

# Get vocab
myout <-prepDocuments(mypreprocess$documents,
                      mypreprocess$vocab, mypreprocess$meta,
                      lower.thresh = nrow(data_topic)/100)
myout$vocab
capture.output(myout$vocab, file=paste0("results/vocab",Sys.time(),".txt"))

# Dummy variables for countries
for(country in top_countries){
  myout$meta[country] <- ifelse(myout$meta$country == country, 1, 0)
}
myout$meta$etc <- ifelse(myout$meta$country %in% top_countries, 0, 1)

# Find best topic count
topic_counts <- c(10, 30, 50) 
kresult <- searchK(myout$documents, myout$vocab, data=myout$meta,
                   topic_counts, 
                   prevalence = prevalence,
                   seed = 16)
plot(kresult)

# STM
topic_count <- 30
mystm <- stm(myout$documents, myout$vocab, data=myout$meta,
             K=topic_count,
             prevalence = prevalence,
             seed = 16)

plot(mystm, type = "summary", labeltype = "prob", text.cex = 1)
plot(mystm, type = "labels", labeltype = "prob", text.cex = 1)
labelTopics(mystm, topics=1:topic_count, n=7)

estimate <- estimateEffect(reg, mystm, myout$meta)
result = summary(estimate)
print(result[3]$tables)
write.csv(result[3]$tables,file=paste0("results/effect_",Sys.time(),".csv"))

estimate_cross <- estimateEffect(reg_cross, mystm, myout$meta)
result_cross = summary(estimate_cross)
print(result_cross[3]$tables)
write.csv(result_cross[3]$tables,file=paste0("results/effect_cross_",Sys.time(),".csv"))

# Beta
logbeta <- as.data.frame(mystm[["beta"]][["logbeta"]][[1]])
beta <- as.data.frame(exp(logbeta))
colnames(beta) <- myout$vocab
colnames(logbeta) <- myout$vocab
write.csv(beta, file=paste0("results/beta_",Sys.time(),".csv"), row.names=TRUE)
write.csv(logbeta, file=paste0("results/logbeta_",Sys.time(),".csv"), row.names=TRUE)
