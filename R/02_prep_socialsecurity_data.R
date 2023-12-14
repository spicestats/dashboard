
# load -------------------------------------------------------------------------

library(tidyverse)

source("R/functions/f_get_region.R")

data <- readRDS("data/social_security_data.rds")

social_security <- lapply(c("AA", "CA", "DLA"), function(x) {
  
  data[[x]]$dfs[[1]] %>% 
    rename(Constituency = 'Scottish Parliamentary Constituencies',
           TimePeriod = Quarter,
           Data = 4) %>% 
    mutate(Measure = x)
  
}) %>% 
  bind_rows()  %>% 
  filter(Constituency != "Total") %>% 
  mutate(Constituency = case_when(Constituency == "Perthshire South and Kinross-shire" ~ "Perthshire South and Kinrossshire",
                                  TRUE ~ Constituency),
         Region = const_name_to_region(Constituency),
         Subject = "Social Security",
         Year = year(my(TimePeriod)),
         Month = month(my(TimePeriod)),
         Sex = case_when(Gender == "Total" ~ "All",
                         TRUE ~ Gender),
         Age = "All",
         CTBand = "All",
         Lower = NA,
         Upper = NA) %>% 
  select(Region, Constituency, Subject, Measure, TimePeriod, Year, Month, Sex, Age, 
         CTBand, Data, Lower, Upper) %>% 
  mutate(Measure = case_when(Measure == "AA" ~ "Attendance Allowance",
                             Measure == "CA" ~ "Carer's Allowance",
                             Measure == "DLA" ~ "Disability Living Allowance")) %>% 
  arrange(Year, Month, Measure, Region, Constituency)

# save all ---------------------------------------------------------------------

saveRDS(social_security, "data/tidy_socialsecurity_data.rds")

rm(list = ls())

cat("Social security data prepped", fill = TRUE)

