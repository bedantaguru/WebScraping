

library(rvest)
library(dplyr)
library(stringr)
library(purrr)

###############################################
# A Quick Start

target_link <- "https://unemploymentinindia.cmie.com/"

wp <- target_link %>%
  read_html()

unemp <- wp %>% html_node("#ftable") %>% html_table()

###############################################
# Using Selector Gadget on News
# https://selectorgadget.com/ it has become less powerful now

wp <- "https://economictimes.indiatimes.com/" %>%
  read_html()

top_news_nodes <- wp %>% html_nodes("#topNewsTabs .newsList a")

top_news <- tibble(
  headline = top_news_nodes %>% html_text(),
  link = top_news_nodes %>% html_attr("href")
)

top_news <- top_news %>%
  mutate(link_full = paste0(
    "https://economictimes.indiatimes.com",
    link
  ))

# lets do something for a single news
# lets open for us
utils::browseURL(top_news$link_full[1])
wp1 <- top_news$link_full[1] %>%
  read_html()

wp1 %>% html_node(".artTitle") %>% html_text()
wp1 %>% html_node(".ag") %>% html_text()
wp1 %>% html_node(".jsdtTime") %>% html_text()
wp1 %>% html_node(".summary") %>% html_text()

# put all in a DF
ndt <- tibble(
  title = wp1 %>% html_node(".artTitle") %>% html_text(),
  auth = wp1 %>% html_node(".ag") %>% html_text(),
  date_time = wp1 %>% html_node(".jsdtTime") %>% html_text(),
  summary = wp1 %>% html_node(".summary") %>% html_text()
)

# put everything in a function
get_news_summary <- function(news_url){
  wp0 <- news_url %>%
    read_html()
  # put all in a DF
  ndt <- tibble(
    title = wp0 %>% html_node(".artTitle") %>% html_text(),
    auth = wp0 %>% html_node(".ag") %>% html_text(),
    date_time = wp0 %>% html_node(".jsdtTime") %>% html_text(),
    summary = wp0 %>% html_node(".summary") %>% html_text()
  )
  ndt
}

# Lets limit the calls
top_news <- top_news[1:5,]

top_news_details <- top_news$link_full %>% map_dfr(get_news_summary)


###############################################
# A Little More Objective
wp <- "https://www.rbi.org.in/" %>%
  read_html()

# Aim 1
lst <- wp %>% html_nodes(".accordionContent") %>% html_table()

lst <- lst[1:5]

# Aim 2
lnodes <- wp %>% html_nodes("#Recent a")

# Improvise

lnodes <- wp %>% html_nodes("#whats_new #Recent a")

# data.frame may be used in place of tibble
whats_new_table <- tibble(
  txt = lnodes %>% html_text(),
  link = lnodes %>% html_attr("href")
)

###############################################
# Limitation of Static Web Scraping
wp <- "https://www.bseindia.com/" %>%
  read_html()

wp %>% html_node("#indi") %>%  html_table()
