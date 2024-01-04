
# load -------------------------------------------------------------------------

library(tidyverse)
library(polite)
library(rvest)

# spreadsheets ----------------------------------------------------------------- 
# download newest data and previous revised dataset (in spreadsheets)

url <- "https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/earningsandworkinghours/datasets/realtimeinformationstatisticsreferencetablenonseasonallyadjusted/current"
session <- polite::bow(url)

urls_on_site <- polite::scrape(session) %>% 
  html_nodes(".btn") %>% 
  html_attr("href")

# get latest 4 spreadsheets
latest_4 <- urls_on_site[grepl("realtimeinformationstatistics", urls_on_site)][1:4]
download_urls <- paste0("https://www.ons.gov.uk/", latest_4)

lapply(seq_along(download_urls), function(x) {
  download.file(url = download_urls[x],
                destfile = paste0("data/paye", x, ".xlsx"), 
                mode = "wb")
})

rm(list = ls())
