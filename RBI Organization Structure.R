
# lets Scrape RBI org details
# target : https://www.rbi.org.in/Scripts/AboutUsDisplay.aspx?pg=Depts.htm

# setup
# install.packages(c("collapsibleTree", "rvest","tidyverse"))

library(rvest)
library(dplyr)
library(stringr)
library(purrr)
library(tidyr)
library(collapsibleTree)

# static web scraping is not going to work
# target_url <- "https://www.rbi.org.in/Scripts/AboutUsDisplay.aspx?pg=Depts.htm"
# wp <- target_url %>% read_html()

wp <- read_html("wp/Reserve Bank of India - About Us.html")

depts_nodes <- wp %>% html_nodes("table+ .tablebg .link1")

dept_tables <- wp %>% html_nodes(".tablebg") %>% html_table()


G <- dept_tables[[2]]
dgs <- dept_tables[[3]]
eds <- dept_tables[[4]]
ics <- dept_tables[[5]]

#######################

depts <- tibble(
  Dept= depts_nodes %>% html_text() %>% str_trim() %>% str_replace_all(" +"," "),
  Short = depts_nodes %>% html_attr("href") %>% str_split("#") %>% map(`[[`,2) %>% map_chr(str_trim)
)

# Governor
G <- G$Governor %>% str_split("\n") %>% map(`[[`,1) %>% map_chr(str_trim)

# use this for understanding : dgs %>% pull(Portfolios) %>% str_split("[1-9.]") %>% map(str_trim) %>% map(~.x %>% nchar %>% `>`(0) %>% .x[.])
dgs <- dgs %>%
  mutate(
    Dept = Portfolios %>%
      str_split("[1-9.]") %>%
      map(str_trim) %>%
      map(~.x %>% nchar %>% `>`(0) %>% .x[.])
  ) %>%
  unnest(cols = Dept)

dgs <- dgs %>%
  mutate(
    DG = `Deputy Governors` %>% str_split("\n") %>% map(`[[`,1) %>% map_chr(str_trim)
  ) %>% select(DG, Dept) %>% distinct()


eds <- eds %>%
  mutate(
    Dept = Departments %>%
      str_split("[1-9.]") %>%
      map(str_trim) %>%
      map(~.x %>% nchar %>% `>`(0) %>% .x[.])
  ) %>%
  unnest(cols = Dept)

eds <- eds %>%
  mutate(
    ED = `Executive Directors` %>% str_split("\n") %>% map(`[[`,1) %>% map_chr(str_trim)
  ) %>% select(ED, Dept) %>% distinct()


ics <- ics %>%
  mutate(
    Dept = `Department & Address` %>% str_split("\n") %>% map(`[[`,1) %>% map_chr(str_trim)
  ) %>%
  mutate(
    IC = `Name and Designation` %>% str_split("\n") %>% map(`[[`,1) %>% map_chr(str_trim)
  ) %>% select(IC, Dept) %>% distinct()


# join all
dept_map <- dgs %>%
  full_join(eds, by = "Dept") %>%
  full_join(ics, by = "Dept") %>%
  full_join(depts, by = "Dept") %>%
  mutate(G = G)

dept_map <- dept_map %>%
  select(G, DG, ED, IC, Dept, Short) %>%
  distinct() %>%
  arrange(G, DG, ED, IC, Dept)

# Very Crude Way of Doing it
dept_map <- dept_map %>% select(-Short) %>% na.omit()

# Top to Down
collapsibleTree(
  dept_map,
  hierarchy = c("G","DG", "ED", "IC", "Dept"),
  root = "RBI")

# Down to Top
# collapsibleTree(
#   dept_map,
#   hierarchy = c("Dept","IC","ED","DG","G"),
#   root = "RBI")
