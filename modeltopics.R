# load data
load("badreviews.rds")

# load packages
library(tm)
library(topicmodels)
library(slam)

review_vec <- VectorSource(bad_reviews$text)

review_corpus <- Corpus(review_vec)

review_dtm <- DocumentTermMatrix(review_corpus, 
                                 control = list(stemming=TRUE,
                                                stopwords = TRUE,
                                                minWordLength = 2,
                                                removeNumbers = TRUE,
                                                removePunctuation = TRUE)
)

# get rid of infrequent terms using term frequency-inverse document frequency
term_tfidf <- tapply(review_dtm$v/row_sums(review_dtm)[review_dtm$i], review_dtm$j, mean) * log2(nDocs(review_dtm)/col_sums(review_dtm > 0))

review_dtm_trimmed <- review_dtm[, term_tfidf >=0.1]

# get rowtotals and then use that vector to subset dtm for rows that have at least one term
rowTotals <- apply(review_dtm_trimmed, 1, sum) 

review_dtm_trimmed <- review_dtm_trimmed[rowTotals> 0, ]   

# set number of topics and seed
k <- 12
SEED <- 1999

# diagnostic process that creates all four kinds of topic models to compare for accuracy
review_tm_all <- 
    list(VEM = LDA(review_dtm_trimmed, k=k, control = list(seed=SEED)),
         VEM_fixed = LDA(review_dtm_trimmed, k = k, control = list(estimate.alpha = FALSE, seed = SEED)),
          Gibbs = LDA(review_dtm_trimmed, k = k, method = "Gibbs", control = list(seed = SEED, burnin = 1000, thin = 100, iter = 1000)))

# computes mean entropy of topic distributions across all documents
# lower values indicate "peakier" distributions 
# higher values indicate "smoother" distributions
sapply(review_tm_all, function(x) mean(apply(posterior(x)$topics,1, function(z) - sum(z*log(z)))))
# Gibbs appears smoothest

# use logLik function to compute loglikelihood of all terms in each model
sapply(review_tm_all, logLik)
# Gibbs has best value


# create gibbs sampling model
review_tm_gibbs <- LDA(review_dtm_trimmed, k = k, method = "Gibbs", control = list(seed = SEED, burnin = 1000, thin = 100, iter = 1000))

# look at the top 10 terms in each topic
terms(review_tm_gibbs,10)

save(review_tm_all, review_tm_gibbs, file = "data/topicmodels.rds")

# create wordclouds if you want ...

# library(wordcloud)
# 
# pal <- brewer.pal(10,"Spectral")
# 
# plot_wordcloud <- function(model, myDtm, index, numTerms) {
#     
#     model_terms <- terms(model, numTerms)
#     model_topics <- topics(model)
#     
#     terms_i <- model_terms[,index]
#     topic_i <- model_topics == index
#     dtm_i <- myDtm[topic_i, terms_i]
#     frequencies_i <- colSums(as.matrix(dtm_i))
#     wordcloud(terms_i, frequencies_i, min.freq = 0, colors = pal, rot.per = 0)
#     
# }

# single topic wordcloud
# plot_wordcloud(model = review_tm_gibbs,
#                myDtm = review_dtm_trimmed,
#                index = 5,
#                numTerms = 15)

# png("plots/wordcloud.png", width=1800, height = 1800)
# 
# par(mfrow=c(4,3))
# for (i in 1:12) {
#     plot_wordcloud(model = review_tm_gibbs,
#                    myDtm = review_dtm_trimmed,
#                    index = i,
#                    numTerms = 10)
#     #     plot_title <- paste("Topic", i, sep = " ")
#     title(main = paste("Topic", i, sep = " "))
# }
# 
# dev.off()