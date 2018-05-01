# Exploratory Data Analysis of the comments made on NYT articles
The dataset here comprises of comments made on articles in New York Times in Jan-April 2018 and Jan-April 2017. Here we explore the features of the dataset for March 2018 and in particular study their relationship with the feature recommendations that counts the number of upvotes a comment has received.

We have explored the numerical and categorical features so far using graphs and descriptive statistics. The most central features in the dataset are textual for example the commentBody. The next kernel that is a work in progress will be a starter kernel for model building using the textual data. 
There are 3 Files in total. 
1. "New York Times Article and Comment Analysis.ipynb":- Contain various visualizations for comment and article analysis. 
      1.1.    Understanding the distribution of upvotes on comments and removing outliers
   
      1.2.    A look at the articles' dataframe and some feature engineering
   
      1.3.    Analyzing different features and their relationship with the number of upvotes in a comment, like, Editor’s Pick, Features related to replies to comments, Depth etc
   
      1.4.    Features related to the articles of the comments like, Page on which the article was printed, Article Desk
   
2. “New York Word Cloud.ipynb”:- Contains various word clouds showing frequency of the word. Word Clouds are of different shapes such as Thumbs Up, Star, People etc.
      2.1.    Most common words in all of the comments
   
      2.2.    Most common words in the top 1% most upvoted comments
   
      2.3.    Most common words in the comments selected as Editor`s pick
   
      2.4.    Usernames with most comments
   
      2.5.    Most common locations of the commenters
   
      2.6.    Most common words in the headlines on the articles
   
3. “NYT Sentiment Analysis.R”:- This file carries out some high-level Exploratory Data Analysis (EDA), and then finish off by trying to understand if keywords in a headline could influence how many comments an article can get. 
      3.1.    EDA of NYT Articles
   
      3.2.    Top News Desk
   
      3.3.    Word Count distribution
   
      3.4.    The relationship between word count number of comments
   
      3.5.    Text Analysis
