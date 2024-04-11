
# load -------------------------------------------------------------------------

library(tidyverse)

source("R/functions/f_get_region.R")

data <- readRDS("data/social_security_data.rds")

social_security <- lapply(c("AA", "CA", "DLA"), function(x) {
  
  data[[x]]$dfs[[1]] %>% 
    rename(Area_name = 'Scottish Parliamentary Constituencies',
           TimePeriod = Quarter,
           Data = 4) %>% 
    mutate(Measure = x,
           Area_type = "SP Constituency")
  
}) %>% 
  bind_rows()  %>% 
  filter(Area_name != "Total") %>% 
  mutate(Area_name = case_when(Area_name == "Perthshire South and Kinross-shire" ~ "Perthshire South and Kinrossshire",
                               TRUE ~ Area_name),
         Region = const_name_to_region(Area_name),
         Subject = "Social Security",
         Year = year(my(TimePeriod)),
         Month = month(my(TimePeriod)),
         Sex = case_when(Gender == "Total" ~ "All",
                         TRUE ~ Gender),
         Age = "All",
         CTBand = "All",
         Lower = NA,
         Upper = NA,
         Measure = case_when(Measure == "AA" ~ "Attendance Allowance",
                             Measure == "CA" ~ "Carer's Allowance",
                             Measure == "DLA" ~ "Disability Living Allowance")) %>% 
  select(Area_name, Area_type, Region, Subject, Measure, TimePeriod, Year, Month, 
         Sex, Age, CTBand, Data, Lower, Upper) %>% 
  arrange(Year, Region, Area_type, Area_name)

# save all ---------------------------------------------------------------------

saveRDS(social_security, "data/tidy_socialsecurity_data.rds")

rm(list = ls())

cat("Social security data prepped", fill = TRUE)

