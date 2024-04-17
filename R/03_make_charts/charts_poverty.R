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
  
  
  ids <- unique(cilif$Age)[1:3]
  
  scot <- cilif %>% 
    filter(Measure == "Child poverty rate by age",
           Region == x | Area_type == "Country",
           Year == max(Year)) %>% 
    mutate(Data = ifelse(Area_name == "Scotland", max(Data) * 1.2, NA))
  
  cilif %>% 
    filter(Measure == "Child poverty rate by age",
           Region == x | Area_type == "Country",
           Year == max(Year)) %>% 
    arrange(desc(Data)) %>% 
    hchart("scatter", hcaes(x = Area_name, y = Data*100, group = Age),
           id = ids, zIndex = 2, marker = list(symbol = c('circle', 'square','diamond'))) %>% 
    hc_add_series(type = "column", data = scot, hcaes(x = Area_name, y = Data*100), 
                  color = spcols["midblue"], enableMouseTracking = FALSE,
                  zIndex = 1, opacity = 0.2, showInLegend = FALSE) %>% 
    
    hc_chart(inverted = TRUE) %>% 
    hc_colors(colors = unname(spcols[1:length(ids)])) %>% 
    hc_xAxis(title = NULL) %>% 
    hc_yAxis(title = "",
             labels = list(format = '{value}%'),
             accessibility = list(description = "Rate")) %>% 
    hc_add_theme(my_theme) %>%
    hc_tooltip(headerFormat = '<b> {point.key} </b><br>',
               pointFormat = '{series.name} year-olds: <b>{point.y:.1f}%</b>') 
  
})

highchart() %>%
  hc_add_series(data = abs(rnorm(5)), type = "column") %>%
  hc_add_series(data = purrr::map(0:4, function(x) list(x, x)), type = "scatter", color = "orange")
