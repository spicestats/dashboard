# NRS Dwellings by Council Tax Band
# RoS Average house prices

# load -------------------------------------------------------------------------

library(tidyverse)
library(opendatascot)
library(polite)
library(rvest)

# Note that Census data download isn't automated as it doesn't get updated often

# Rent data --------------------------------------------------------------------

url_rent <- "https://www.ons.gov.uk/peoplepopulationandcommunity/housing/datasets/redevelopmentofprivaterentalpricesstatisticsukimpactanalysisdata"

session <- polite::bow(url_rent)
urls_rent_on_site <- polite::scrape(session) %>% 
  html_nodes("a") %>% 
  html_attr("href")

download_url_rent <- urls_rent_on_site[grepl(".xlsx", urls_rent_on_site)]

download.file(paste0("https://www.ons.gov.uk", download_url_rent), 
              "data/rent.xlsx", mode = "wb")

# EPC data ---------------------------------------------------------------------

url_epc <- "http://statistics.gov.scot/data/domestic-energy-performance-certificates"

session <- polite::bow(url_epc)
urls_epc_on_site <- polite::scrape(session) %>% 
  html_nodes("a") %>% 
  html_attr("href")

download_url_epc <- urls_epc_on_site[grepl(".zip", urls_epc_on_site)][1]

## download and unpack zipfile

# big file - need to increase default timeout period (60s) to ensure download 
# isn't aborted
options(timeout=500)

download.file(download_url_epc, "data/epc.zip")

# reset
options(timeout=60)

unzip("data/epc.zip", exdir = "data/epc_data")

data_latest_quarter_epc <- list.files("data/epc_data") %>% 
  str_split_i(".csv", 1) %>% 
  tail(2) %>% 
  head(1)

# NRS Dwellings by Council Tax Band --------------------------------------------

url <- "https://statistics.gov.scot/data/dwellings-by-council-tax-band-detailed-current-geographic-boundaries"

session <- polite::bow(url)
urls_on_site <- polite::scrape(session) %>% 
  html_nodes("a") %>% 
  html_attr("href")

download_url <- urls_on_site[grepl("Detailed", urls_on_site)][1]

## download and unpack zipfile 

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

data_scot <- ods_dataset("residential-properties-sales-and-price",
                       measureType = "median",
                       refArea = "S92000003")

# save datasets ----------------------------------------------------------------

saveRDS(list(la = data_la,
             spc = data_spc,
             Scot = data_scot), "data/house_prices_data.rds")

# write message
message1 <- paste("Council tax data downloaded from statistics.gov.scot - latest data from",
                  max(data_year))
message2 <- paste("House prices data downloaded from statistics.gov.scot - latest data from",
                 max(data_spc$refPeriod))
message3 <- paste("EPC data downloaded from statistics.gov.scot - latest data from",
                  data_latest_quarter_epc)
message4 <- paste("Rent data downloaded from www.ons.gov.uk/")

cat(message1, message2, message3, message4, fill = TRUE)

rm(list = ls())

  