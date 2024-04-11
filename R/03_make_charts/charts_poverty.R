# TODO -------

# sort out chart titles
# mark 20/21 data grey
# single year bar charts better?

# load -------------------------------------------------------------------------

library(tidyverse)
library(highcharter)

source("R/functions/f_make_charts.R")

cilif <- readRDS("data/tidy_poverty_data.rds")
simd <- readRDS("data/tidy_simd_data.rds")

regions <- unique(cilif$Region)
regions <- regions[!is.na(regions)]

# cilif ------------------------------------------------------------------------
## Numbers ---------------------------------------------------------------------

# time series
charts_povertynumbers_ts <- lapply(regions, function(x) {
  
  cilif %>% 
    filter(Measure == "Children in low income families",
           Age == "All",
           Region == x) %>% 
    make_povertynumber_ts_chart()
})

## Rates -----------------------------------------------------------------------

charts_povertyrates_ts <- lapply(regions, function(x) {
  
  cilif %>% 
    filter(Measure == "Child poverty rate (0-15)",
           Region == x | Area_type == "Country") %>% 
    make_povertyrate_ts_chart()
})

# snapshot
charts_povertyrates <- lapply(regions, function(x) {
  
  cilif %>% 
    filter(Measure == "Child poverty rate (0-15)",
           Region == x | Area_type == "Country",
           TimePeriod == max(TimePeriod)) %>% 
    make_povertyrate_barchart()
})

## Ages ------------------------------------------------------------------------

charts_povertyrates_age_ts <- lapply(regions, function(x) {

  cilif %>% 
  filter(Measure == "Child poverty rate by age",
         Region == x) %>% 
  make_povertyrate_ts_age_chart()
})

