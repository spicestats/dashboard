
# load -------------------------------------------------------------------------

library(tidyverse)

source("R/functions/f_get_region.R")

ct_files <- list.files("data/counciltax_data")

# council tax data -------------------------------------------------------------

# remove DZ-level files from list, read in data, only keep S16 geographies (SPC)

ct_data <- paste0("data/counciltax_data/", ct_files[!grepl("DZ", ct_files)]) %>% 
  lapply(read.csv) %>% 
  bind_rows() %>% 
  filter(grepl("S16", Geography_Code),
         !grepl("Bands", Council.Tax.Band)) %>% 
  mutate(Constituency = Geography_Name,
         Constituency = case_when(Constituency == "Perthshire South and Kinross-shire" ~ "Perthshire South and Kinrossshire",
                                  TRUE ~ Constituency),
         Region = const_name_to_region(Constituency),
         Subject = "Housing",
         Measure = "Dwellings by council tax band",
         TimePeriod = DateCode,
         Year = DateCode,
         Month = NA,
         Sex = "All",
         Age = "All",
         CTBand = Council.Tax.Band,
         Data = Value,
         Lower = NA,
         Upper = NA) %>% 
  select(Region, Constituency, Subject, Measure, TimePeriod, Year, Month, Sex, Age,
         CTBand, Data, Lower, Upper) %>% 
  arrange(Year, Region, Constituency)

# house prices -----------------------------------------------------------------

hp_data <- readRDS("data/house_prices_data.rds") %>% 
  mutate(Constituency = const_code_to_name(refArea),
         Region = const_name_to_region(Constituency),
         Subject = "Housing",
         Measure = "Median house price",
         TimePeriod = refPeriod,
         Year = refPeriod,
         Month = NA,
         Sex = "All",
         Age = "All",
         CTBand = "All",
         Data = value,
         Lower = NA,
         Upper = NA) %>% 
  select(Region, Constituency, Subject, Measure, TimePeriod, Year, Month, 
         Sex, Age, CTBand, Data, Lower, Upper) %>% 
  arrange(Year, Region, Constituency)

# save all ---------------------------------------------------------------------

saveRDS(rbind(house_prices = hp_data,
             council_tax = ct_data),
        "data/tidy_housing_data.rds")

rm(list = ls())

cat("Housing data prepped", fill = TRUE)
