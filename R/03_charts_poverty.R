# TODO -------

# sort out population for 2021/22 - see Cilif report for what they used
# (no pop estimates available)
# sort out chart titles


# load -------------------------------------------------------------------------

library(tidyverse)
library(highcharter)

source("R/functions/f_make_charts.R")

cilif <- readRDS("data/tidy_poverty_data.rds")

regions <- unique(cilif$Region)
regions <- regions[!is.na(regions)]

# Numbers ----------------------------------------------------------------------

charts_povertynumbers <- lapply(regions, function(x) {
  
  cilif %>% 
    filter(Measure == "Children in low income families",
           Age == "All",
           Region == x) %>% 
    make_povertynumber_chart()
})

# Rates ------------------------------------------------------------------------

charts_povertyrates <- lapply(regions, function(x) {
  
  cilif %>% 
    filter(Measure == "Child poverty rate (0-15)",
           Region == x | Area_type == "Country") %>% 
    make_povertyrate_chart()
})

# Ages -------------------------------------------------------------------------

charts_povertyrates_age <- lapply(regions, function(x) {

  cilif %>% 
  filter(Measure == "Child poverty rate by age",
         Region == x) %>% 
  make_povertyrate_age_chart()
})

charts_povertyrates_age[[2]]
