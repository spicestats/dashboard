# load -------------------------------------------------------------------------

library(tidyverse)

source("R/functions/f_get_region.R")

data <- readRDS("data/cilif_data.rds")

# tidy CiLIF data --------------------------------------------------------------

cilif <- data$dfs[[1]] %>% 
  rename(TimePeriod = Year,
         Age = 'Age of Child (years and bands)',
         Data = 'Relative Low Income') %>% 
  mutate(Area_name = dz_code_to_const(DZ),
         Area_name = case_when(DZ == "Total"~ "Scotland", 
                               Area_name == "Perthshire South and Kinross-shire" ~ "Perthshire South and Kinrossshire",
                               TRUE ~ Area_name),
         Area_type = ifelse(Area_name == "Scotland", "Country", "SP Constituency")) %>% 
  summarise(Data = sum(Data), .by = c("TimePeriod", "Area_type", "Area_name", "Age")) %>% 
  mutate(Region = const_name_to_region(Area_name),
         Age = ifelse(Age == "Total", "All", Age),
         Measure = 'Children in relative poverty',
         Subject = "Poverty",
         Year = TimePeriod,
         Month = NA,
         Sex = "All",
         CTBand = "All",
         Lower = NA,
         Upper = NA,
         Measure = "Children in low income families") %>% 
  select(Area_name, Area_type, Region, Subject, Measure, TimePeriod, Year, Month, 
         Sex, Age, CTBand, Data, Lower, Upper) %>% 
  arrange(Year, Region, Area_type, Area_name) %>% 
  filter(!(Age == "Unknown or missing" & Data == 0))

# save all ---------------------------------------------------------------------

saveRDS(cilif, "data/tidy_poverty_data.rds")

rm(list = ls())

cat("Poverty data prepped", fill = TRUE)

