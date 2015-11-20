# the following script is used to:
# 1. assign topics to reviews
# 2. tag parts of speech
# 3. isolate adjectives

load("data/topicmodels.rds")

# add topic assignment as a variable to review data frame

# create topic_df for joining
topic_df <- data.frame(topic = topics(review_tm_gibbs,1), 
                       id = names(topics(review_tm_gibbs,1)), 
                       stringsAsFactors = FALSE)

# create id variable for joining
bad_reviews$id <- as.character(1:nrow(bad_reviews))

# join the topics to the bad review data frame
library(dplyr)
bad_reviews_2 <- inner_join(bad_reviews, topic_df)

bad_reviews_2$topic <- factor(bad_reviews_2$topic)

summary(bad_reviews_2$topic)

topic_text <- with(bad_reviews_2, 
                   split(text, topic))

# load NLP and openNLP packages
library(openNLP)
library(NLP)

# create a a tagPOS (tag part of speech) function
tagPOS <-  function(x, ...) {
    s <- as.String(x)
    word_token_annotator <- Maxent_Word_Token_Annotator()
    a2 <- Annotation(1L, "sentence", 1L, nchar(s))
    a2 <- annotate(s, word_token_annotator, a2)
    a3 <- annotate(s, Maxent_POS_Tag_Annotator(), a2)
    a3w <- a3[a3$type == "word"]
    POStags <- unlist(lapply(a3w$features, `[[`, "POS"))
    POStagged <- paste(sprintf("%s/%s", s[a3w], POStags), collapse = " ")
    list(POStagged = POStagged, POStags = POStags)
}

acqTag <- lapply(topic_text, tagPOS)


adj_list <- list()

for (i in 1:12) {
    
    adj_list[[i]] <- sapply(strsplit(acqTag[[i]][[1]],"[[:punct:]]*/JJ.?"),function(x) sub("(^.*\\s)(\\w+$)", "\\2", x))
    names(adj_list)[i] <- paste("Topic", i, sep = " ")
    
}

# clean up list of adjectives
adj_list_cleaned <- lapply(adj_list, function(x) ifelse(grepl("/", x), NA, x))
adj_list_cleaned <- lapply(adj_list_cleaned, na.exclude)

save(adj_list_cleaned, file = "data/adjectives.rds")
