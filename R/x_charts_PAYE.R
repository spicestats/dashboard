# load -------------------------------------------------------------------------

library(tidyverse)
library(highcharter)

data <- readRDS("data/tidy_paye_data.rds")

data$paye %>% 
  filter(Age == "All",
         Area_name != "Scotland") %>% 
  hchart("line", hcaes(x = TimePeriod, y = Data, group = Area_name))

data$paye %>% 
  filter(Age == "All",
         Area_name == "Scotland") %>% 
  distinct() %>% 
  hchart("line", hcaes(x = TimePeriod, y = Data))

data$paye %>% 
  filter(Age == "All",
         is.na(LA),
         SIC == " Health and social work") %>% 
  hchart("line", hcaes(x = Date, y = Pay, group = Region))
