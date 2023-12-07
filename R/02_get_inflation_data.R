# load -------------------------------------------------------------------------

library(tidyverse)
library(polite)
library(rvest)


url <- "https://www.ons.gov.uk/economy/inflationandpriceindices/datasets/consumerpriceindices"

session <- polite::bow(url)
urls_on_site <- polite::scrape(session) %>% 
  html_nodes(".btn") %>% 
  html_attr("href")

download_url <- urls_on_site[grepl("csv", urls_on_site)]

download.file(paste0("https://www.ons.gov.uk/", download_url), 
              "data/inflation.csv")

inflation_data <- readr::read_delim("data/inflation.csv")

inflators <- inflation_data  %>% 
  rename(year = Title, 
         cpih = "CPIH INDEX 00: ALL ITEMS 2015=100") %>%
  filter(grepl("APR", year),
         !is.na(cpih)) %>% 
  mutate(year = str_sub(year, 1, 4),
         year = as.numeric(year),
         cpih = as.numeric(cpih),
         latest = cpih[length(cpih)],
         inflator = latest/cpih) %>% 
  select(year, inflator)

saveRDS(inflators, "data/inflators.rds")
