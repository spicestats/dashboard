
# load -------------------------------------------------------------------------

library(tidyverse)

# load rounding function
source("R/functions/f_round2.R")
source("R/functions/f_get_region.R")

labourmarket <- readRDS("data/labourmarketdata.rds")

# tidy labour market dataset
tidy_lm <- labourmarket %>% 
  select(date, date_name, geography_name, geography_type, variable_name,
         measures_name, obs_value, obs_status, obs_status_name) %>% 
  
  mutate(# only keep reliable estimates; mark unreliable as missing
    obs_value = case_when(obs_status == "A" ~ obs_value)) %>% 
  select(-obs_status_name, -obs_status) %>% 
  pivot_wider(names_from = measures_name, values_from = obs_value) %>% 
  
  # get region for each constituency
  mutate(region = const_name_to_region(geography_name)         ,
         region = case_when(geography_type == "scottish parliamentary regions" ~ geography_name,
                            TRUE ~ region),
         gender = case_when(grepl(" males", variable_name) ~ "Male",
                            grepl(" female", variable_name) ~ "Female",
                            TRUE ~ "All"),
         variable_name = case_when(grepl("Unemployment", variable_name) ~ "Unemployment",
                                   grepl("Employment", variable_name) ~ "Employment",
                                   TRUE ~ "Inactivity"),
         # if confidence is missing then the estimate is not reliable either
         rate = case_when(!is.na(Confidence) ~ Variable / 100),
         Confidence = Confidence / 100,
         Lower = rate - rate * Confidence * 1.96,
         Upper = rate + rate * Confidence * 1.96) %>% 
  select(-geography_type, -Confidence, -Variable)


# for earlier data, aggregate constituency estimates to regions
aggregated_rates <- tidy_lm %>% 
  filter(date < "2012-12",
         geography_name != region) %>% 
  group_by(date, region, variable_name, gender) %>% 
  summarise(rate_aggr = round2(sum(Numerator)/sum(Denominator), 3))

# combine aggregated estimates with all data
tidy_lm_combined <- tidy_lm %>% 
  left_join(aggregated_rates, by = c("date", "region", "variable_name", "gender")) %>% 
  mutate(Data = case_when(date < "2012-12" & region == geography_name ~ rate_aggr,
                          TRUE ~ rate),
         Year = year(ym(date)),
         Month = month(ym(date)),
         Constituency = case_when(geography_name != region ~ geography_name),
         Region = region,
         Subject = "Labour market",
         Measure = variable_name,
         TimePeriod = date_name,
         Sex = gender, 
         Age = "All",
         CTBand = "All") %>% 
  select(Region, Constituency, Subject, Measure, TimePeriod, Year, Month, 
         Sex, Age, CTBand, Data, Lower, Upper) %>% 
  arrange(Year, Month, Region, Constituency)

# save tidy data ---------------------------------------------------------------

saveRDS(tidy_lm_combined, "data/tidy_labourmarket_data.rds")

rm(list = ls())
cat("Labour market data prepped", fill = TRUE)


