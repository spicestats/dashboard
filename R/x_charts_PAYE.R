# load -------------------------------------------------------------------------

library(tidyverse)
library(highcharter)

data <- readRDS("data/tidy_paye_data.rds")

data$paye %>% 
  filter(Age == "All",
         SIC == "All",
         is.na(LA)) %>% 
  hchart("line", hcaes(x = Date, y = Pay, group = Region))

data$paye %>% 
  filter(SIC == "All",
         is.na(LA),
         Region == "Scotland") %>% 
  hchart("line", hcaes(x = Date, y = Pay, group = Age))

data$paye %>% 
  filter(Age == "All",
         is.na(LA),
         Region == "Scotland") %>% 
  hchart("line", hcaes(x = Date, y = Pay, group = SIC))

data$paye %>% 
  filter(Age == "All",
         is.na(LA),
         SIC == " Health and social work") %>% 
  hchart("line", hcaes(x = Date, y = Pay, group = Region))
