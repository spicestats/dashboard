
# Employee earnings data comes from the Annual Survey of Hours and Earnings 
# (ASHE) and is available on NOMIS (back series only). The latest data and the
# previous revised dataset are available in spreadsheets.

# load -------------------------------------------------------------------------

library(tidyverse)
library(nomisr)
library(polite)
library(rvest)

# spreadsheets ----------------------------------------------------------------- 
# download newest data and previous revised dataset (in spreadsheets)

## Table 5 ---------------------------------------------------------------------
# Table 5 has Region/SIC breakdowns - currently not required

url <- "https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/earningsandworkinghours/datasets/regionbyindustry2digitsicashetable5"
session <- polite::bow(url)

urls_on_site <- polite::scrape(session) %>% 
  html_nodes(".btn") %>% 
  html_attr("href")

download_urls <- urls_on_site[grepl("ashetable5", urls_on_site)][1:2]

download.file(paste0("https://www.ons.gov.uk/", download_urls[1]), 
              "data/ashetable5_latest.zip")
download.file(paste0("https://www.ons.gov.uk/", download_urls[2]), 
              "data/ashetable5_previous.zip")

unzip("data/ashetable5_latest.zip", exdir = "data/ashetable5_latest")
unzip("data/ashetable5_previous.zip", exdir = "data/ashetable5_previous")

## Table 8 ---------------------------------------------------------------------
# council-level data

url <- "https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/earningsandworkinghours/datasets/placeofresidencebylocalauthorityashetable8"
session <- polite::bow(url)

urls_on_site <- polite::scrape(session) %>% 
  html_nodes(".btn") %>% 
  html_attr("href")

download_urls <- urls_on_site[grepl("ashetable8", urls_on_site)][1:2]

download.file(paste0("https://www.ons.gov.uk/", download_urls[1]), 
              "data/ashetable8_latest.zip")
download.file(paste0("https://www.ons.gov.uk/", download_urls[2]), 
              "data/ashetable8_previous.zip")

unzip("data/ashetable8_latest.zip", exdir = "data/ashetable8_latest")
unzip("data/ashetable8_previous.zip", exdir = "data/ashetable8_previous")

# nomis datasets ---------------------------------------------------------------
# download back series

# find ASHE datasets
# nomis_search(keywords = c("earnings")) %>% view()

# NM_99_1 Workplace analysis
# NM_30_1 Resident analysis

# ASHE datasets
rs_metadata <- nomis_get_metadata(id = "NM_30_1")
wp_metadata <- nomis_get_metadata(id = "NM_99_1")

last_updated <- nomis_overview(id = "NM_30_1") %>% 
  filter(name == "lastupdated") %>% 
  unnest(value) %>% 
  pull(value)

# -> seems like the 'last updated' value wasn't updated correctly ...

# run these to understand what's in the datasets
# nomis_get_metadata(id = "NM_30_1", concept = "GEOGRAPHY")
# nomis_get_metadata(id = "NM_30_1", concept = "GEOGRAPHY", type = "TYPE499") %>% view()
# nomis_get_metadata(id = "NM_99_1", concept = "TIME") %>% view()
# nomis_get_metadata(id = "NM_30_1", concept = "MEASURES")
# nomis_get_metadata(id = "NM_99_1", concept = "FREQ")
# nomis_get_metadata(id = "NM_99_1", concept = "SEX")
# nomis_get_metadata(id = "NM_99_1", concept = "ITEM")
# nomis_get_metadata(id = "NM_99_1", concept = "PAY")


# API queries

nomis_rs <- nomis_get_data(
  
  id = "NM_30_1", 
  
  # UK, countries, and Scottish council areas
  geography = c("TYPE499", "2092957701TYPE423"), 
  
  # frequency annual
  freq = "A",
  
  # full-time, part-time, all
  sex = c(7, 8, 9),
  
  # median
  item = 2,
  
  # weekly gross, annual gross, hourly gross
  pay = c(1, 5, 7),
  
  # values & confidence measure
  measures = c(20100, 20701)
)

names(nomis_rs) <- tolower(names(nomis_rs))


# save data --------------------------------------------------------------------

saveRDS(nomis_rs, "data/nomis_ashe_data.rds")

# write message
cat("ASHE data downloaded from NOMIS - data last updated on NOMIS on", day(last_updated), 
    month.name[month(last_updated)], year(last_updated), fill = TRUE)

rm(list = ls())
