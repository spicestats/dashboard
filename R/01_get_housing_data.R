# NRS Dwellings by Council Tax Band
# RoS Average house prices

# load -------------------------------------------------------------------------

library(tidyverse)
library(opendatascot)
library(polite)
library(rvest)

# NRS Dwellings by Council Tax Band --------------------------------------------

url <- "https://statistics.gov.scot/data/dwellings-by-council-tax-band-detailed-current-geographic-boundaries"

session <- polite::bow(url)
urls_on_site <- polite::scrape(session) %>% 
  html_nodes("a") %>% 
  html_attr("href")

download_url <- urls_on_site[grepl("Detailed", urls_on_site)][1]

## download and unpack zipfile -------------------------------------------------

download.file(download_url, "data/counciltax.zip")
unzip("data/counciltax.zip", exdir = "data/counciltax_data")

data_year <- list.files("data/counciltax_data") %>% 
  str_split_i(".csv", 1) %>% 
  str_split_i("-", -1) %>% 
  as.numeric()

# RoS Average house prices -----------------------------------------------------

# get list of constituencies in dataset
spc <- ods_find_lower_geographies("S92000003") %>% 
  filter(grepl("S16", geography)) %>% 
  distinct() %>% 
  pull(geography)

data_spc <- ods_dataset("residential-properties-sales-and-price",
                    measureType = "median",
                    refArea = spc)

data_la <- ods_dataset("residential-properties-sales-and-price",
                        measureType = "median",
                        geography = "la")

## save dataset ----------------------------------------------------------------

saveRDS(list(la = data_la,
             spc = data_spc), "data/house_prices_data.rds")

# write message
message1 <- paste("Council tax data downloaded from statistics.gov.scot - latest data from",
                  max(data_year))
message2 <- paste("House prices data downloaded from statistics.gov.scot - latest data from",
                 max(data_spc$refPeriod))
cat(message1, message2, fill = TRUE)

rm(list = ls())

  