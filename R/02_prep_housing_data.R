
# load -------------------------------------------------------------------------

library(tidyverse)

source("R/functions/f_get_region.R")
source("R/functions/f_get_council.R")

ct_files <- list.files("data/counciltax_data")

# council tax data -------------------------------------------------------------

# remove DZ-level files from list, read in data, only keep S16 geographies (SPC)
# and Scotland

ct_data <- paste0("data/counciltax_data/", ct_files[!grepl("DZ", ct_files)]) %>% 
  lapply(read.csv) %>% 
  bind_rows() %>% 
  filter(grepl("S16|S92000003", Geography_Code),
         !grepl("Bands", Council.Tax.Band)) %>% 
  mutate(Area_name = Geography_Name,
         Area_name = case_when(Area_name == "Perthshire South and Kinross-shire" ~ "Perthshire South and Kinrossshire",
                                  TRUE ~ Area_name),
         Region = const_name_to_region(Area_name),
         Area_type = case_when(Geography_Code == "S92000003" ~"Country",
                               TRUE ~ "SP Constituency"),
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
  select(Area_name, Area_type, Region, Subject, Measure, TimePeriod, Year, Month, 
         Sex, Age, CTBand, Data, Lower, Upper) %>% 
  arrange(Year, Region, Area_type, Area_name)

# house prices -----------------------------------------------------------------

hp_data <- readRDS("data/house_prices_data.rds") 

hp_data_spc <- hp_data$spc %>% 
  mutate(refArea = const_code_to_name(refArea)) %>% 
  rbind(hp_data$Scot) %>% 
  mutate(Area_name = case_when(grepl("S92", refArea) ~ "Scotland",
                               TRUE ~ refArea),
         Area_type = ifelse(Area_name == "Scotland", "Country", "SP Constituency"),
         Region = const_name_to_region(Area_name),
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
  select(Area_name, Area_type, Region, Subject, Measure, TimePeriod, Year, Month, 
         Sex, Age, CTBand, Data, Lower, Upper) %>% 
  arrange(Year, Region, Area_type, Area_name) 

hp_data_la <- hp_data$la %>% 
  mutate(refArea = council_code_to_name(refArea)) %>% 
  rbind(hp_data$Scot) %>% 
  mutate(Area_name = case_when(grepl("S92", refArea) ~ "Scotland",
                               TRUE ~ refArea),
         Area_type = ifelse(Area_name == "Scotland", "Country", "Council"),
         Region = NA,
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
  select(Area_name, Area_type, Region, Subject, Measure, TimePeriod, Year, Month, 
         Sex, Age, CTBand, Data, Lower, Upper) %>% 
  arrange(Year, Region, Area_type, Area_name)

# save all ---------------------------------------------------------------------

saveRDS(rbind(hp_data_spc,
              hp_data_la,
              ct_data) %>% 
          distinct(),
        "data/tidy_housing_data.rds")

rm(list = ls())

cat("Housing data prepped", fill = TRUE)
