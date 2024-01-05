
# load -------------------------------------------------------------------------

library(tidyverse)
library(highcharter)

source("R/functions/f_make_charts.R")

spcols <- c("#B884CB", "#568125", "#E87722")

all_data <- readRDS("data/tidy_labourmarket_data.rds") %>% 
  arrange(Year, Month, Measure)

latest_quarter <- tail(all_data$Month, 1)
regions <- unique(all_data$Region)
regions <- regions[!is.na(regions)]

data <- all_data %>% 
  mutate(Year = lubridate::my(paste(Month, Year))) %>% 
  filter(Month == latest_quarter,
         Sex == "All")

# Constituencies ---------------------------------------------------------------
# Inactivity & Employment only

charts_labourmarket_constituencies <- list()

for (i in regions) {
  
  Region_selected <- i
  
  constituencies <- data %>% 
    filter(Region == Region_selected,
           Area_type == "SP Constituency") %>% 
    select(Area_name) %>% 
    distinct() %>% 
    pull()
  
  charts_labourmarket_constituencies[[i]] <- lapply(
    seq_along(constituencies), 
    function(x) {
      
      df <- data %>% 
        filter(Measure != "Unemployment",
               Region == Region_selected,
               Area_name == constituencies[x])
      
      make_labourmarket_chart(df) %>% hc_title(text = constituencies[x])
    })
  
  names(charts_labourmarket_constituencies[[i]]) <- constituencies
}

# Regions ----------------------------------------------------------------------
# Inactivity, Unemployment & Employment

## line charts -----------------------------------------------------------------

charts_labourmarket_regions <- lapply(regions, function(x) {
  
  df <- data %>% filter(Region == x, Area_type == "SP Region")
  make_labourmarket_chart(df) %>% hc_title(text = x)
})

names(charts_labourmarket_regions) <- regions

## errorbar charts -------------------------------------------------------------

charts_labourmarket_regions_employment_errorbar <- lapply(regions, function(x) {
  
  df <- data %>% 
    filter(Area_type == "SP Constituency" | Area_name == "Scotland",
           Region == x | Area_name == "Scotland",
           TimePeriod == max(TimePeriod),
           Measure == "Employment") %>% 
    arrange(desc(Data)) %>% 
    make_labourmarket_errorbar_chart() %>% 
    hc_title(text = "Proportion of 16-65 year olds who are employed or self-employed")
})

charts_labourmarket_regions_inactivity_errorbar <- lapply(regions, function(x) {
  
  df <- data %>% 
    filter(Area_type == "SP Constituency" | Area_name == "Scotland",
           Region == x | Area_name == "Scotland",
           TimePeriod == max(TimePeriod),
           Measure == "Inactivity") %>% 
    arrange(desc(Data)) %>% 
    make_labourmarket_errorbar_chart() %>% 
    hc_title(text = "Proportion of 16-65 year olds who are economically inactive")
})

names(charts_labourmarket_regions_employment_errorbar) <- regions
names(charts_labourmarket_regions_inactivity_errorbar) <- regions

# save all ---------------------------------------------------------------------

saveRDS(list(regions = charts_labourmarket_regions,
             constituencies = charts_labourmarket_constituencies,
             regions_emp = charts_labourmarket_regions_employment_errorbar,
             regions_inact = charts_labourmarket_regions_inactivity_errorbar), 
        "data/charts_labourmarket.rds")

