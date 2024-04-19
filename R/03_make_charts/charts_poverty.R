
# load -------------------------------------------------------------------------

library(tidyverse)
library(highcharter)

source("R/functions/f_make_charts.R")

cilif <- readRDS("data/tidy_cilif_data.rds")
regions <- unique(cilif$Region)
regions <- regions[!is.na(regions)]

# cilif ------------------------------------------------------------------------
## Numbers ---------------------------------------------------------------------

# snapshot
charts_povertynumbers <- lapply(regions, function(x) {
  
  cilif %>% 
    filter(Measure == "Children in low income families",
           Age == "All",
           Region == x,
           TimePeriod == max(TimePeriod)) %>% 
    make_povertynumber_barchart() %>% 
    hc_title(text = paste0("Number of children (aged 0-19) in ", x, " constituencies who are in relative poverty before housing costs, ",
                           max(cilif$TimePeriod)))
})

## Rates -----------------------------------------------------------------------

# snapshot
charts_povertyrates <- lapply(regions, function(x) {
  
  cilif %>% 
    filter(Measure == "Child poverty rate (0-15)",
           Region == x | Area_type == "Country",
           TimePeriod == max(TimePeriod)) %>% 
    make_povertyrate_barchart() %>% 
    hc_title(text = paste0("Proportion of children (aged 0-15) in ", x, " constituencies who are in relative poverty before housing costs, ",
                           max(cilif$TimePeriod)))
})

# time series
charts_povertyrates_ts <- lapply(regions, function(x) {
  
  cilif %>% 
    filter(Measure == "Child poverty rate (0-15)",
           Region == x | Area_type == "Country") %>% 
    make_povertyrate_ts_chart() %>% 
    add_recessionbar() %>% 
    hc_title(text = paste0("Proportion of children (aged 0-15) in ", x, " constituencies who are in relative poverty before housing costs"))
})

## Ages ------------------------------------------------------------------------

charts_povertyrates_age <- lapply(regions, function(x) {
  
  ids <- unique(cilif$Age)[1:3]
  
  cilif %>% 
    filter(Measure == "Child poverty rate by age",
           Region == x | Area_type == "Country",
           Year == max(Year)) %>% 
    arrange(desc(Data)) %>% 
    make_povertyrate_age_chart() %>% 
    hc_title(text = paste0("Proportion of children (aged 0-15) in ", x, " constituencies who are in relative poverty before housing costs, ",
                           max(cilif$TimePeriod)))
})

names(charts_povertynumbers) <- regions
names(charts_povertyrates) <- regions
names(charts_povertyrates_ts) <- regions
names(charts_povertyrates_age) <- regions

# save all ---------------------------------------------------------------------

saveRDS(list(povertynumbers = charts_povertynumbers,
             povertyrates = charts_povertyrates,
             povertyrates_ts = charts_povertyrates_ts,
             povertyrates_age = charts_povertyrates_age), 
        "data/charts_poverty.rds")

rm(list = ls())
