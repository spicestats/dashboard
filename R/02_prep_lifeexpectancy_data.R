# load -------------------------------------------------------------------------

library(tidyverse)
source("R/functions/f_get_region.R")

expect <- readRDS("data/lifeexpectancy.rds") %>% 
  filter(grepl("S16", refArea),
         age == "0-years") %>% 
  mutate(Area_name = const_code_to_name(refArea),
         Area_type = "SP Constituency",
         Region = const_name_to_region(Area_name),
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
  select(Area_name, Area_type, Region, Subject, Measure, TimePeriod, Year, Month, 
         Sex, Age, CTBand, Data, Lower, Upper) %>% 
  arrange(Year, Region, Area_type, Area_name)

# save data --------------------------------------------------------------------

saveRDS(expect, "data/tidy_lifeexpectancy_data.rds")
rm(list = ls())

cat("Life expectancy data prepped", fill = TRUE)

