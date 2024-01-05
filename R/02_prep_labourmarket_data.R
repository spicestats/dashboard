
# load -------------------------------------------------------------------------

library(tidyverse)

# load rounding function
source("R/functions/f_round2.R")
source("R/functions/f_get_region.R")

labourmarket <- readRDS("data/labourmarketdata.rds")

# tidy labour market dataset
tidy_lm <- labourmarket %>% 
  filter(geography_name != "Great Britain",
         geography_name != "England and Wales") %>% 
  select(date, date_name, geography_name, geography_type, variable_name,
         measures_name, obs_value, obs_status, obs_status_name) %>% 
  
  mutate(# only keep reliable estimates; mark unreliable as missing
    obs_value = case_when(obs_status == "A" ~ obs_value)) %>% 
  select(-obs_status_name, -obs_status) %>% 
  pivot_wider(names_from = measures_name, values_from = obs_value) %>% 
  
  # get region for each constituency
  mutate(Region = const_name_to_region(geography_name)         ,
         Region = case_when(geography_type == "scottish parliamentary regions" ~ geography_name,
                            TRUE ~ Region),
         Sex = case_when(grepl(" males", variable_name) ~ "Male",
                            grepl(" female", variable_name) ~ "Female",
                            TRUE ~ "All"),
         variable_name = case_when(grepl("Unemployment", variable_name) ~ "Unemployment",
                                   grepl("Employment", variable_name) ~ "Employment",
                                   TRUE ~ "Inactivity"),
         # if confidence is missing then the estimate is not reliable either
         Data = case_when(!is.na(Confidence) ~ Variable / 100),
         Confidence = Confidence / 100,
         Lower = Data - Data * Confidence * 1.96,
         Upper = Data + Data * Confidence * 1.96) %>% 
  select(-Confidence, -Variable)


# for earlier data, aggregate constituency estimates to regions
aggregated_rates <- tidy_lm %>% 
  filter(date < "2012-12",
         grepl("scottish parliamentary constituencies", geography_type)) %>% 
  select(-geography_type) %>% 
  group_by(date, Region, variable_name, Sex) %>% 
  summarise(rate_aggr = round2(sum(Numerator)/sum(Denominator), 3))
  

# combine aggregated estimates with all data
tidy_lm_combined <- tidy_lm %>% 
  left_join(aggregated_rates, by = c("date", "Region", "variable_name", "Sex")) %>% 
  mutate(Data = case_when(date < "2012-12" & geography_type == "scottish parliamentary regions" ~ rate_aggr,
                          TRUE ~ Data),
         Year = year(ym(date)),
         Month = month(ym(date)),
         Area_name = case_when(geography_type == "scottish parliamentary regions" ~ Region,
                               TRUE ~ geography_name),
         Area_type = case_when(geography_type == "scottish parliamentary regions" ~ "SP Region",
                               geography_type == "countries" ~ "Country",
                               grepl("scottish parliamentary constituencies", geography_type) ~ "SP Constituency"),
         Subject = "Labour market",
         Measure = variable_name,
         TimePeriod = date_name,
         Age = "All",
         CTBand = "All") %>% 
  select(Area_name, Area_type, Region, Subject, Measure, TimePeriod, Year, Month, 
         Sex, Age, CTBand, Data, Lower, Upper) %>% 
  arrange(Year, Month, Region, Area_type, Area_name)

# save tidy data ---------------------------------------------------------------

saveRDS(tidy_lm_combined, "data/tidy_labourmarket_data.rds")

rm(list = ls())
cat("Labour market data prepped", fill = TRUE)


