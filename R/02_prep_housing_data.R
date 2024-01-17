
# load -------------------------------------------------------------------------

library(tidyverse)
library(naniar)

source("R/functions/f_get_region.R")
source("R/functions/f_get_council.R")

# EPC data ---------------------------------------------------------------------
epc_files <- list.files("data/epc_data/", full.names = TRUE, pattern = "csv")

# import all into list
epc_list <- lapply(epc_files, function(x) {
  read_csv(x, skip = 1)})

# keep selected variables and combine all in single data frame
# note: data zone is 2001 data zones (!) - use postcodes instead
epc_df <- lapply(seq_along(epc_list), function(x) {
  
  filename <- epc_files[x] %>%  
    str_split_i( "epc_data/", 2) %>% 
    str_split_i(".csv", 1)
  
  epc_list[[x]] %>% 
    select(Property_UPRN, Postcode, "Date of Certificate",
           "Current energy efficiency rating", "Current energy efficiency rating band") %>% 
    rename(id = Property_UPRN,
           certified = "Date of Certificate",
           rating = "Current energy efficiency rating",
           band = "Current energy efficiency rating band") %>% 
    mutate(file = filename)
  
}) %>% 
  bind_rows() 

# remove big file to make space 
rm(epc_list)


epc_tidy <- epc_df %>% 
  distinct() %>% 
  
  # format dates properly using fasttime package which is faster than lubridate
  mutate(certified = as.Date(fasttime::fastPOSIXct(certified)),
         Area_name = postcode_to_const(Postcode),
         Area_name = case_when(Area_name == "Perthshire South and Kinross-shire" 
                               ~ "Perthshire South and Kinrossshire",
                               TRUE ~ Area_name),
         Area_type = "SP Constituency",
         Region = const_name_to_region(Area_name))



# Census tenure data ----------------------------------------------------------- 

tenure <- read_csv("data/DC4427SC.csv", skip = 4)

tenure_tidy <- tenure %>% 
  rename(Area_name = 1,
         Group = 2,
         Total = "All households") %>% 
  filter(Group == "All households",
         !is.na(Group)) %>% 
  select(-Group) %>% 
  mutate(across(where(is.numeric), as.character)) %>% 
  pivot_longer(-c(Area_name, Total), names_to = "Tenure", values_to = "Data") %>% 
  filter(Tenure %in% c("Owned: Owned outright", 
                       "Owned: Owned with a mortgage or loan or shared ownership",
                       "Social rented: Total",
                       "Private rented or living rent free: Total")) %>% 
  mutate(Tenure = factor(Tenure, 
                         levels = c("Owned: Owned outright", 
                                    "Owned: Owned with a mortgage or loan or shared ownership",
                                    "Social rented: Total",
                                    "Private rented or living rent free: Total"),
                         labels = c("Owned outright",
                                    "Buying with a mortgage",
                                    "Social rented",
                                    "Private rented"),
                         ordered = TRUE),
         Data = as.integer(Data) / as.integer(Total), 
         Area_type = ifelse(Area_name == "Scotland", "Country", "SP Constituency"),
         Region = const_name_to_region(Area_name),
         Subject = "Housing",
         Measure = paste("Tenure:", Tenure),
         TimePeriod = 2011,
         Year = TimePeriod,
         Month = NA,
         Sex = "All",
         Age = "All",
         CTBand = "All",
         Lower = NA,
         Upper = NA) %>% 
  
  select(Area_name, Area_type, Region, Subject, Measure, TimePeriod, Year, Month, 
         Sex, Age, CTBand, Data, Lower, Upper) %>% 
  arrange(Year, Region, Area_type, Area_name) 

# council tax data -------------------------------------------------------------

ct_files <- list.files("data/counciltax_data")

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
              ct_data,
              tenure_tidy) %>% 
          distinct(),
        "data/tidy_housing_data.rds")

rm(list = ls())

cat("Housing data prepped", fill = TRUE)
