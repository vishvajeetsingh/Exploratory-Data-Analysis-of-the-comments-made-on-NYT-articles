# NYT EDA and Click Bait
# The data analysed below comes from NYT bylines and comments for March 2018. I will carry out some high level Exploratory Data Analysis (EDA), and then finish off by trying to understand if keywords in a headline could influence how many comments an article can get.
# Load libraries, data and inspect data sets
  
# load libraries
library(dplyr)
library(tidytext)
library(tidyr)
library(ggplot2)
library(lubridate)

# load in data
articles_march18 <- read.csv("ArticlesMarch2018.csv", stringsAsFactors = F)
comments_march18 <- read.csv("CommentsMarch2018.csv", stringsAsFactors = F)

# inspect data
dim(articles_march18)
dim(comments_march18)

# The NYT articles dataset has 1,385 observations and 15 variabels.

# The NYT comments dataset has 246,946 ovservations and 34 variables. There appears to be some variables in both datasets, so I will deal with these later if I intend to join the two datasets together.


# EDA of NYT Articles

## Top 20 article bylines in March 2018

articles_march18 %>%
  count(byline) %>%
  mutate(byline = reorder(byline, n)) %>%
  top_n(20) %>%
  ggplot(aes(x=byline, y=n)) +
  geom_bar(stat = "identity", fill = "darkblue") +
  labs(x="Byline", y="Number of articles") +
  coord_flip()+
  theme_bw()

# The most frequent bylines are from Deb Amlen, followed by Natalie Proulx and the Editorial Board. Paul Krugman is also prominent for the month.

# Top News Desk

# Which news desk has the most articles in March 2018?
  
articles_march18 %>%
  count(newDesk) %>%
  mutate(newDesk = reorder(newDesk, n)) %>%
  ggplot(aes(x=newDesk, y=n)) +
  geom_bar(stat = "identity", fill = "darkblue") +
  labs(x="News Desk", y="Number of articles") +
  coord_flip()+
  theme_bw()

# The OpEd is clearly the busiest news deask. Washington follows in second.

# The most articles by section in March 2018

articles_march18 %>%
  count(sectionName) %>%
  mutate(sectionName = reorder(sectionName, n)) %>%
  ggplot(aes(x=sectionName, y=n)) +
  geom_bar(stat = "identity", fill = "darkblue") +
  labs(x="Section", y="Number of articles") +
  coord_flip()+
  theme_bw()

# The vast majority of articles aren't given a lable, so are reported as unknown.

# Type of Materials in March 2018

articles_march18 %>%
  count(typeOfMaterial) %>%
  mutate(typeOfMaterial = reorder(typeOfMaterial, n)) %>%
  ggplot(aes(x=typeOfMaterial, y=n)) +
  geom_bar(stat = "identity", fill = "darkblue") +
  labs(x="Type of Material", y="Number of articles") +
  coord_flip()+
  theme_bw()

# As one would expect, the majority of articles are classed as "News". Op-Eds are the second most frequent type of material.

# Word Count distribution

ggplot(data = articles_march18, aes(x= articleWordCount)) +
  geom_histogram(col = "darkblue", fill = "white", bins = 30) +
  labs(x="Word Count", y="")+
  theme_minimal()

summary(articles_march18$articleWordCount)

# The word count distribution for NYT articles is displayed above and displays a positively skewed distribution. The minimum number of words is 55, while the maximum number of comments is 11,491, with a median word count of 1,065 and mean of 1,142.

# EDA of NYT Comment Count

# Count the number of comments by article
comment_count <- comments_march18 %>%
  count(articleID) %>%
  rename(num_comments = n)

# Join comment count back to main articles data frame
articles_march18 <- articles_march18 %>%
  left_join(comment_count, by = "articleID")

# Number of comments distribution

ggplot(data = articles_march18, aes(x= num_comments)) +
  geom_histogram(col = "darkblue", fill = "white", bins = 30) +
  labs(x= "Number of Comments", y="") +
  theme_minimal()

summary(articles_march18$num_comments)

# The NYT articles number of comments distribution is displayed above and displays a strong positively skewed distribution. The minimum number of comments is one, while the maximum number of comments is 2,927, with a median number of comments of 57 and mean of 178.

# Relationship between word count number of comments

# Is there a relationship between the article's word count and how many comments it gets?
  
ggplot(data = articles_march18, aes(x= articleWordCount, y= num_comments)) +
  geom_point(col = "darkblue", alpha = 0.5) +
  geom_smooth(method = "lm", linetype = 2, se = F, col = "red") +
  labs(x= "Word Count", y= "Number of comments") +
  theme_bw()

print(paste("The correlation between the article's wordcount and the number of comments it receives is ", round(cor(articles_march18$articleWordCount, articles_march18$num_comments),4), sep = ""))

# The plot above indicates a weak positive relationship between the article's wordcount and the number of comments it receives, with correlation = 0.1281.

# Type of material vs number of comments

# Does the type of materials in March 2018 lead to different numbers of comments?

ggplot(data = articles_march18, aes(x=typeOfMaterial, y=num_comments)) +
  geom_boxplot(col = "darkblue", fill = "lightgrey", alpha = 0.2) +
  coord_flip() +
  labs(x= "Type of Material", y= "Number of comments")+ 
  theme_bw()

# Of the top two types of material (News and Op-Ed), Op-Eds receive more comments on avearge (median *Op-Ed* = `r median(articles_march18$num_comments[articles_march18$typeOfMaterial == "Op-Ed"])` to median *News* = `r median(articles_march18$num_comments[articles_march18$typeOfMaterial == "News"])`

# Text Analysis

# I will now use the package `tidytext`, from the `tidyverse` world and apply tidy principles to to the headlines of the NYT articles to see if there are certain words used more than others, and to see whether these certain words translate to more comments.

# Create a tidy dataset with tokens and add in `"bing"` sentiments

# I will use the `"bing"` lexicon to assign a word to either a "positive" of "negative" sentiment. 

# tokenise text in article headline
tidy_articles <- articles_march18 %>%
  select(articleID, byline, headline, pubDate, typeOfMaterial, articleWordCount, num_comments) %>%
  unnest_tokens(word, headline) %>%
  anti_join(stop_words, by="word")

# get sentiments from the bing lexicon
headline_sentiments <-  tidy_articles %>%
  inner_join(get_sentiments("bing"), by = "word")

# Most frequent words used in the article's headline

tidy_articles %>%
  count(word) %>%
  top_n(25) %>%
  ggplot(aes(x= reorder(word, n), y=n)) +
  geom_col(fill = "darkblue") + 
  coord_flip() +
  labs(x= "Word", y= "Count") +
  theme_bw()

# Interestingly, the most frequently used word is *"unknown"*! *"Trump"* follows in second, while *"Trump's"* is third. I Will combine these two into the same word.

tidy_articles$word[tidy_articles$word == "trump's"] <- "trump"

tidy_articles %>%
  count(word) %>%
  top_n(25) %>%
  ggplot(aes(x= reorder(word, n), y=n)) +
  geom_col(fill = "darkblue") + 
  coord_flip() +
  labs(x= "Word", y= "Count") +
  theme_bw()

# "Trump" is still the second most used word in NYT article headlines - I definitely expected he'd be high!

# Are headlines more positive or negative?

headline_sentiments <-  tidy_articles %>%
  inner_join(get_sentiments("bing"), by = "word")

headline_sentiments %>%
  count(sentiment) %>%
  ggplot(aes(x= sentiment, y= n)) +
  geom_col(fill = c("lightgrey", "darkblue")) +
  labs(x="Headline Sentiment", y= "Count") +
  theme_minimal()

# It appears that NYT headines contain more negative words rather than positve ones. Maybe this reflects the times we live in?

# Does the day of the week impact how we feel?

headline_sentiments$pubDate <- ymd_hms(headline_sentiments$pubDate)
headline_sentiments$day_of_week <- wday(headline_sentiments$pubDate, label = TRUE)

ggplot(data = headline_sentiments, aes(x=day_of_week, fill = sentiment)) +
  geom_bar(position = "fill") +
  scale_fill_manual(values = c("lightgrey", "darkblue")) +
  labs(x= "Weekday", "Frequency") +
  theme_minimal()

# Looks like the NYT are trying to keep things a bit more positive on the weeknds in March, with Saturday and Sunday being the most positive days of the week, while Friday was the most negative.

# What are some of the words being used?

headline_word_counts <- headline_sentiments %>%
  count(word, sentiment)

headline_word_counts %>%
  group_by(sentiment) %>%
  top_n(10) %>%
  ungroup() %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(x= word, y= n, fill = sentiment)) +
  geom_col(show.legend = FALSE, fill = "darkblue") +
  facet_wrap(~sentiment, scales = "free") +  
  labs(x= "Count", y= "Word") +
  coord_flip() +
  theme_bw()

# "Unknown" is the most frequent negative word, while *"Trump"* is the most positive word! The bing lexicon may need an urgent review because I'm not sure that word is all that synonymous with positivity! I'll remove the two words below.

headline_word_counts %>%
  filter(word != "trump", word != "unknown") %>%
  group_by(sentiment) %>%
  top_n(10) %>%
  ungroup() %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(x= word, y= n, fill = sentiment)) +
  geom_col(show.legend = FALSE, fill = "darkblue") +
  facet_wrap(~sentiment, scales = "free") + 
  labs(x= "Count", y= "Word") +
  coord_flip() +
  theme_bw()

# The most frequent negative words used in article headlines are *"stormy"*, *"dead"* and *"crisis"*, while the most positive words used are *"love"*, *"win"*, and *"fast"*.

# Do certain words in headlines elicit more comments

# create a df of the top 25 used words
top_25_headline_words <- tidy_articles %>%
  count(word, sort = TRUE) %>%
  top_n(25) %>%
  select(word)

# join articles metadata to the top 25 words df
top_25_headline_words <- tidy_articles %>%
  inner_join(top_25_headline_words, by = "word")

# boxplot
ggplot(data = top_25_headline_words, aes(x=word, y= num_comments)) +
  geom_boxplot(col = "darkblue", fill = "lightgrey", alpha = 0.2) +
  labs(x= "Word", y= "Number of Comments") +
  coord_flip() +
  theme_bw()

# The mere mention of *"Trump"* tends to lead to more comments in response to articles, closely followed by *"president"*, most mentions of *"president"* would probably preceed "Trump". Next I will run a simple linear regression using base R's `lm` function to see if Trump is a significant predictor of how many comments an article will get.

trump_articles <- tidy_articles %>%
  mutate(trump_yes_no = factor(ifelse(word == "trump", "yes", "no"))) %>%
  filter(trump_yes_no == "yes") %>%
  select(articleID, trump_yes_no) %>%
  right_join(comment_count, by = "articleID")

trump_articles$trump_yes_no[is.na(trump_articles$trump_yes_no)] <- "no"

fit_trump <- lm(num_comments ~ trump_yes_no, data = trump_articles)

summary(fit_trump)

# Having *"Trump"* in the article's title is a significant preditor of the number of comments an article receives, with a positive coefficient of 273. The man certainly elicits a response out of NYT readers!

# That's all, Thank you for reading (if you have gotten this far)! 

