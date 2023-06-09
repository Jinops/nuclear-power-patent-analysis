#install.packages(stm)
#install.packages(stringr)
#install.packages(stopwords)

#library(stm)
#library(stringr)
#library(stopwords)

if(data_about == 'Registration'){
  top_countries = c('US', 'JP', 'DE', 'FR', 'KR')
  prevalence =  ~ US + JP + DE + FR + KR 
  reg = c(1:topic_count) ~ US + JP + DE + FR + KR
  reg_cross = c(1:topic_count) ~ year + US + JP + DE + FR + KR + year:US + year:JP + year:DE + year:FR + year:KR
}
if(data_about == 'Application'){
  top_countries = c('US', 'JP', 'KR', 'FR', 'CN')
  prevalence =  ~ US + JP + KR + FR + CN 
  reg = c(1:topic_count) ~ US + JP + KR + FR + CN
  reg_cross = c(1:topic_count) ~ year + US + JP + KR + FR + CN + year:US + year:JP + year:KR + year:FR + year:CN
}

## KR
#prevalence =  ~ year + KR
#reg = c(1:topic_count) ~ year + KR + nonKR
#reg_cross = c(1:topic_count) ~ year + KR + year:KR


sprintf('< %s >', data_about)
result_path = paste0("results/",tolower(data_about),"s/")

data_topic <- data
data_topic$text = paste(data_topic$patent_tilte, " ", data_topic$patent_abstract)
data_topic$text <- str_replace_all(data_topic$text, '-', ' a ')

stopwords <- stopwords(language = "en", source = "smart")
stopwords_add <- c('invention', 'thereof', 'therefore', 'therefrom')
stopwords <- c(stopwords, stopwords_add)

# Preprocessing - textProcessor
mypreprocess <- textProcessor(data_topic$text, metadata = data_topic[c("year", "country")]
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

mypreprocess <- textProcessor(data_topic$text, metadata = data_topic[c("year", "country")]
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

# Dummy variables for countries
for(country in top_countries){
  myout$meta[country] <- ifelse(myout$meta$country == country, 1, 0)
}
myout$meta$etc <- ifelse(myout$meta$country %in% top_countries, 0, 1)

## Dummy - KOR
#myout$meta$KR <- ifelse(myout$meta$country == 'KR', 1, 0)
#myout$meta$nonKR <- ifelse(myout$meta$country == 'KR', 0, 1)


# # Find best topic count
# topic_counts <- c(8, 16, 20, 25, 30)
# kresult <- searchK(myout$documents, myout$vocab, data=myout$meta,
#                    topic_counts,
#                    prevalence = prevalence,
#                    seed = 16)
# plot(kresult) # Residuals: Lower Better / The others: Higher Better

# STM
topic_count = 20

mystm <- stm(myout$documents, myout$vocab, data=myout$meta,
             K=topic_count,
             prevalence = prevalence,
             seed = 16)

plot(mystm, type = "summary", labeltype = "prob", text.cex = 1)

# topic
topics = labelTopics(mystm, topics=1:topic_count, n=7)
print(topics)
sink(file=paste0(result_path, 'topic_c', topic_count, '.txt'))
topics
sink()

# reg
estimate <- estimateEffect(reg, mystm, myout$meta)
result = summary(estimate)
reg_result = result[3]$tables
write.csv(reg_result, file=paste0(result_path, "reg.csv"))

# reg_cross
estimate_cross <- estimateEffect(reg_cross, mystm, myout$meta)
result_cross = summary(estimate_cross)
reg_cross_result = result_cross[3]$tables
write.csv(reg_cross_result, file=paste0(result_path, "reg_cross.csv"))
sink(file=paste0(result_path, "reg_cross.txt"))
reg_cross_result
sink()

# Beta
logbeta <- as.data.frame(mystm[["beta"]][["logbeta"]][[1]])
beta <- as.data.frame(exp(logbeta))
colnames(beta) <- myout$vocab
colnames(logbeta) <- myout$vocab
write.csv(beta, file=paste0(result_path,"beta.csv"))
write.csv(logbeta, file=paste0(result_path,"log_beta.csv"))

# Theta
theta <- as.data.frame(mystm[["theta"]])
theta <- cbind(theta, data$patent_title, data$year, data$country)
write.csv(theta, file=paste0(result_path,"theta.csv"), row.names = TRUE)

