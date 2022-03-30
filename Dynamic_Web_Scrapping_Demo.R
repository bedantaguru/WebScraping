
# it is a package written by me
# have a look at https://github.com/bedantaguru/fisher
# yet not fully usable
# you may contact me directly if you want to use this
library(fisher)

web_automation_platform()

rd <- web_control_client()

rd$navigate("https://www.rbi.org.in/Scripts/AboutUsDisplay.aspx?pg=Depts.htm")


source("RBI_Organization_Structure.R")
rm(wp)

rd$getPageSource()[[1]] %>% read_html() %>% get_diagram()

###################################################
# Another Example of BSE

# Static
wp <- "https://www.bseindia.com/" %>%
  read_html()

wp %>% html_node("#indi") %>%  html_table()


# Dynamic (well just very basic)
"https://www.bseindia.com/" %>%
  rd$navigate()

wp <- rd$getPageSource()[[1]] %>%
  read_html()

wp %>% html_node("#indi") %>%  html_table()


