
# load -------------------------------------------------------------------------

library(tidyverse)
library(data.table)

source("R/functions/f_get_region.R")
source("R/functions/f_get_council.R")

# EPC data ---------------------------------------------------------------------
epc_files <- list.files("data/epc_data/", full.names = TRUE, pattern = "csv")

# import all into list
epc_list <- lapply(epc_files, function(x) {data.table::fread(x, skip = 1)})

# keep selected variables and combine all in single data frame
# note: data zone is 2001 data zones (!) - use postcodes instead
# note: some postcodes cannot be matched (<2%)

epc_df <- lapply(seq_along(epc_list), function(x) {
  
  filename <- epc_files[x] %>%  
    str_split_i( "epc_data/", 2) %>% 
    str_split_i(".csv", 1)
  
  epc_list[[x]] %>% 
    select(Property_UPRN, Postcode, POST_TOWN, "Date of Certificate", "Date of Assessment",
           "Current energy efficiency rating", "Current energy efficiency rating band") %>% 
    rename(id = Property_UPRN,
           assessed = "Date of Assessment",
           certified = "Date of Certificate",
           rating = "Current energy efficiency rating",
           band = "Current energy efficiency rating band",
           town = POST_TOWN) %>% 
    mutate(file = filename,
           id = as.character(id),
           certified = as.Date(certified),
           assessed = as.Date(assessed))
  
}) %>% 
  bind_rows() 

# remove big file to make space 
rm(epc_list)

epc_tidy <- epc_df %>% 
  distinct() %>% 
  mutate(Area_name = postcode_to_const(Postcode),
         Area_name = case_when(Area_name == "Perthshire South and Kinross-shire" 
                               ~ "Perthshire South and Kinrossshire",
                               TRUE ~ Area_name),
         # set clearly wrong (future) dates to assessment date and if still wrong
         # to 1970
         certified = data.table::fifelse(certified > Sys.Date(), assessed, certified),
         certified = data.table::fifelse(certified > Sys.Date(), .Date(0), certified),
         TimePeriod = max(certified, na.rm = TRUE)) %>% 
  # exclude records that cannot be allocated to a constituency (for now) 
  filter(!is.na(Area_name)) %>%
  summarise(Data = n(),
            .by = c(Area_name, band, TimePeriod)) %>% 
  mutate(Region = const_name_to_region(Area_name),
         Area_type = "SP Constituency",
         Subject = "Housing",
         Measure = paste("EPC", band),
         Year = year(TimePeriod),
         Month = month(TimePeriod),
         Sex = "All",
         Age = "All",
         CTBand = "All",
         Lower = NA,
         Upper = NA) %>% 
  select(Area_name, Area_type, Region, Subject, Measure, TimePeriod, Year, Month, 
         Sex, Age, CTBand, Data, Lower, Upper) %>% 
  arrange(Year, Region, Area_type, Area_name, Measure) 

## check data quality ----------------------------------------------------------
# check number of dwellings to assess coverage by comparing to dwellings by council
# tax data

epc_check <- epc_tidy %>% 
  mutate(dwellings_epc_Scot = sum(Data)) %>% 
  mutate(dwellings_epc_region = sum(Data), .by = c(Region)) %>% 
  mutate(dwellings_epc_const = sum(Data), .by = c(Area_name)) %>% 
  select(Region, Area_name, dwellings_epc_Scot, dwellings_epc_region, dwellings_epc_const) %>% 
  distinct()

ct_files <- list.files("data/counciltax_data")

dwellings_check <- paste0("data/counciltax_data/", ct_files[!grepl("DZ", ct_files)]) %>% 
  lapply(read.csv) %>% 
  bind_rows() %>% 
  filter(grepl("S16|S92000003", Geography_Code),
         !grepl("Bands", Council.Tax.Band)) %>% 
  mutate(Area_name = Geography_Name,
         Area_name = case_when(Area_name == "Perthshire South and Kinross-shire" ~ "Perthshire South and Kinrossshire",
                               TRUE ~ Area_name),
         Region = const_name_to_region(Area_name),
         Year = DateCode,
         Data = Value) %>% 
  filter(Year == max(Year),
         Council.Tax.Band == "Total Dwellings") %>% 
  select(Region, Area_name, Data) %>% 
  mutate(Data_region = sum(Data), .by = "Region") %>% 
  left_join(epc_check, by = c("Region", "Area_name")) %>% 
  mutate(coverage_const = case_when(Area_name != "Scotland" ~ dwellings_epc_const/Data),
         coverage_region = case_when(Area_name != "Scotland" ~ dwellings_epc_region/Data_region),
         coverage_Scotland = case_when(Area_name == "Scotland" ~ dwellings_epc_Scot[1]/Data_region)) %>% 
  arrange(Region, Area_name) %>% 
  arrange(coverage_const)

# -> overall coverage is 58% with small differences across regions (55%-61%)
# and constituencies (47%-68%)

epc_tidy_shares <- epc_tidy %>% 
  mutate(Data = Data/sum(Data), .by = c(Area_name))

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
              tenure_tidy,
              epc = epc_tidy_shares) %>% 
          distinct(),
        "data/tidy_housing_data.rds")

rm(list = ls())

cat("Housing data prepped", fill = TRUE)
