# the following script is used to:
# 1. wrangle adjectives into a data frame
# 2. gather that dataframe to get a count by topic
# 3. plot the counts across all topics

load("data/adjectives.rds")


# create a data frame for plotting 
results_df <- data.frame()

for (i in 1:12) {
    
    adj_list_cleaned[[i]] <- tolower(adj_list_cleaned[[i]])
    
    # results_df$topic[i] <- names(adj_list_cleaned)[i]
    results_df[i,1] <- names(adj_list_cleaned)[i]
    
    # results_df$n.rude[i] <- sum(adj_list_cleaned[[i]]=="rude")
    # results_df[i,2] <- sum(adj_list_cleaned[[i]]=="rude")
    
    # results_df$n.expensive[i] <- sum(adj_list_cleaned[[i]]=="expensive")
    results_df[i,2] <- sum(adj_list_cleaned[[i]]=="expensive")
    
    # results_df$n.unprofessional[i] <- sum(adj_list_cleaned[[i]]=="unprofessional")
    # results_df[i,4] <- sum(adj_list_cleaned[[i]]=="unprofessional")
    
    # results_df$n.painful[i] <- sum(adj_list_cleaned[[i]]=="painful")
    results_df[i,3] <- sum(adj_list_cleaned[[i]]=="painful")
    
    
}

names(results_df) <- c("Topic", "Expensive", "Painful")

results_df$Topic <- factor(results_df$Topic)

library(ggplot2)
library(tidyr)
results_df_tidy <- gather(data = results_df, Topic, value=value)
names(results_df_tidy) <- c("Topic", "Term", "Count")
g <- ggplot(results_df_tidy, aes(x=Topic, y=Count, fill=Term)) +
    geom_bar(stat="identity", position="dodge") +
    ggtitle("Distributions of Terms Across Topics") +
    coord_flip()

g

ggsave(filename = "example.png", plot = g)


