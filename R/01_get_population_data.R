
# load -------------------------------------------------------------------------

library(tidyverse)
library(polite)
library(rvest)

url <- "https://www.nrscotland.gov.uk/statistics-and-data/statistics/statistics-by-theme/population/population-estimates/2011-based-special-area-population-estimates/spc-population-estimates"

session <- polite::bow(url)
urls_on_site <- polite::scrape(session) %>% 
  html_nodes("table") %>% 
  html_nodes("a") %>% 
  html_attr("href")

download_url <- urls_on_site[grepl("xls", urls_on_site)]

download.file(paste0("https://www.nrscotland.gov.uk", download_url), 
              "data/spc_population.xlsx",
              mode = "wb")

cat("Population estimates downloaded from NRS", fill = TRUE)
rm(list = ls())
