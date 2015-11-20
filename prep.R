library(jsonlite)
library(dplyr)
library(ggplot2)

# read in business data
filename <- "data/yelp_dataset_challenge_academic_dataset/yelp_academic_dataset_business.json"

business_json <- lapply(readLines(filename), fromJSON)

city_state <- factor(paste(sapply(business_json, '[[', 'city'), ", ",sapply(business_json, '[[', 'state'), sep=""))

stars <- sapply(business_json, '[[', 'stars') 

review_count <- sapply(business_json, '[[', 'review_count')

biz_name <- sapply(business_json, '[[', 'name') 

biz_name_length <- nchar(biz_name)

biz_category <- sapply(sapply(business_json, '[[', 'categories'), paste, collapse=";")

business_id <- factor(sapply(business_json, '[[', 'business_id'))

biz_df <- data_frame(business_id, biz_name, biz_name_length,stars, review_count, biz_category, city_state)

# read in review data
filename <- "data/yelp_dataset_challenge_academic_dataset/yelp_academic_dataset_review.json"
review_df <- stream_in(file(filename), pagesize = 10000)

bad_reviews <- 
    right_join(select(biz_df, business_id, biz_category), review_df) %>%
    filter(grepl("Health", review_df$biz_category)) %>%
    select(-votes, -type) %>%
    filter(stars < 3)

save(bad_reviews, file = "data/badreviews.rds")
