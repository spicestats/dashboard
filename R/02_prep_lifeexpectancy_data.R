# load -------------------------------------------------------------------------

library(tidyverse)
source("R/functions/get_region.R")

expect <- readRDS("data/lifeexpectancy.rds") %>% 
  filter(grepl("S16", refArea),
         age == "0-years") %>% 
  mutate(Constituency = const_code_to_name(refArea),
         Region = const_name_to_region(Constituency),
         Subject = "Health",
         Measure = "Life expectancy at birth",
         TimePeriod = refPeriod,
         Year = as.numeric(str_sub(refPeriod, 6, 9)),
         Month = NA,
         Sex = str_to_title(sex),
         Age = 0,
         CTBand = "All", 
         Data = value,
         Lower = NA,
         Upper = NA) %>% 
  select(Region, Constituency, Subject, Measure, TimePeriod, Year, Month, Sex, Age, 
         CTBand, Data, Lower, Upper) %>% 
  arrange(Year, Region, Constituency)

# save data --------------------------------------------------------------------

saveRDS(expect, "data/tidy_lifeexpectancy_data.rds")
rm(list = ls())
