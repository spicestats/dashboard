
# Labour market data comes from the Annual Population Survey and is available on
# NOMIS

# load -------------------------------------------------------------------------

library(tidyverse)
library(nomisr)

# nomis datasets ---------------------------------------------------------------

## APS query -------------------------------------------------------------------
# APS dataset (residence based)

last_updated_aps <- nomis_overview(id = "NM_17_5") %>% 
  filter(name == "lastupdated") %>% 
  unnest(value) %>% 
  pull(value)

nomis_aps <- nomis_get_data(
  
  id = "NM_17_5", 
  
  # UK, UK countries, Scottish parliamentary regions & constituencies
  geography = c("TYPE499", "TYPE241", "TYPE458"), 
  
  # frequency annual only (for now)
  freq = "A",
  
  # rates and confidence intervals
  # SP regional data only available since 12/2012 -> get numbers as well as rates
  # so can aggregate for older years
  measures = c(20599, 21001, 21002, 21003),
  
  # unemployment 16+ (all, male, female), employment 16-65 (a, m, f), inactivity 16-65 (a, m, f)
  # note that further age breakdowns are also available
  variable = c(83, 92, 101,
               45, 54, 63,
               111, 120, 129)
)

names(nomis_aps) <- tolower(names(nomis_aps))

## claimant count query --------------------------------------------------------

last_updated_cc <- nomis_overview(id = "NM_162_1") %>% 
  filter(name == "lastupdated") %>% 
  unnest(value) %>% 
  pull(value)

# nomis query
nomis_cc <- nomis_get_data(
  
  # APS dataset with rates
  id = "NM_162_1", 
  
  # monthly data for the last few years (add lines as needed)
  time = 
    c(paste0(2024, "-", c(paste0("0", 1:9), 10:12)),
      paste0(2023, "-", c(paste0("0", 1:9), 10:12)),
      paste0(2022, "-", c(paste0("0", 1:9), 10:12)),
      paste0(2022, "-", c(paste0("0", 1:9), 10:12)),
      paste0(2020, "-", c(paste0("0", 1:9), 10:12)),
      paste0(2019, "-", c(paste0("0", 1:9), 10:12)),
      paste0(2018, "-", c(paste0("0", 1:9), 10:12)),
      paste0(2017, "-", c(paste0("0", 1:9), 10:12)),
      paste0(2016, "-", c(paste0("0", 1:9), 10:12)),
      paste0(2015, "-", c(paste0("0", 1:9), 10:12)),
      paste0(2014, "-", c(paste0("0", 1:9), 10:12)),
      paste0(2013, "-", c(paste0("0", 1:9), 10:12))
    ),
  
  # Scotland, SP constituencies (SP regions have no data)
  geography = c("2092957701", "TYPE458"), 
  
  # annual data
  freq = "M", 
  
  # rates only
  measures = 20100, 
  
  # Claimants as a proportion of economically active residents aged 16+
  measure = 3,
  
  # all genders, all ages (16+) (further breakdowns have no data)
  gender = 0,
  age = 0
  
)

names(nomis_cc) <- tolower(names(nomis_cc))


# save data --------------------------------------------------------------------

saveRDS(list(APS = nomis_aps, 
             CC = nomis_cc), "data/labourmarketdata.rds")

# write message
message1 <- paste("APS data downloaded from NOMIS - data last updated on NOMIS on", 
                  day(last_updated_aps), month.name[month(last_updated_aps)], 
                  year(last_updated_aps))
message2 <- paste("Claimant count data downloaded from NOMIS - data last updated on NOMIS on", 
                  day(last_updated_cc), month.name[month(last_updated_cc)], 
                  year(last_updated_cc))
cat(message1, message2, fill = TRUE)
