# Web-Marketing-Analysis-SQL-
These were the questions that were used to shape this web marketing task, please also see the sql code i wrote to answer each of these questions. I have also made a power BI dashboard to provide a summary of my findings. 

1) Write a sql query that tells us which article had the most page impressions, and what the bot percentage is for each.

2) Write a sql query that gives us the top 10 users for each article, based on time spent on the page.

3) Write a query that returns any user that has viewed the same article more than once, on different days, and the article(s) they viewed multiple times.

4) Write a sql query that returns the list of core users who have viewed the ‘Steer clear of the accountability sink’ article.

5) A ‘bounce’ is classified as when a users spends 2 seconds or less on a page, write a query that tells us the proportion of users who only bounced on each article (if a user has a bounce and a non-bounce for that article they count as a non-bounce)

6) A user can have multiple pageviews for the same article, but if they occur on the same day they only count as 1 ‘read’, as long as it is not a bounce, nor a bot impression. Write a query that joins the three tables together, and produces a new column called “read_key” which is a concatenation of the user_id, date and content code. This column should only be populated on non-bounce / non-bot traffic. This result of this query will be the data source you use for the next stage.
