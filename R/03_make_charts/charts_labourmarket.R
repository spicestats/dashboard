
# load -------------------------------------------------------------------------

library(tidyverse)
library(highcharter)

source("R/functions/f_make_charts.R")

all_data <- readRDS("data/tidy_labourmarket_data.rds")
regions <- unique(all_data$Region)
regions <- regions[!is.na(regions)]

# APS data ---------------------------------------------------------------------

aps_data <- all_data %>% 
  filter(Measure %in% c("Unemployment", "Inactivity", "Employment")) %>% 
  arrange(Year, Month, Measure)

latest_quarter <- tail(aps_data$Month, 1)

data <- aps_data %>% 
  mutate(Year = lubridate::my(paste(Month, Year))) %>% 
  filter(Month == latest_quarter,
         Sex == "All")

# Claimant count data ----------------------------------------------------------

cc_data <- all_data %>% 
  filter(Measure == "Unemployment (claimant count)") %>% 
  mutate(Year = lubridate::my(paste(Month, Year))) %>% 
  arrange(Year, Month)

# Constituency charts ----------------------------------------------------------

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
      
      df_aps <- data %>% 
        filter(Measure %in% c("Employment", "Inactivity"),
               Region == Region_selected,
               Area_name == constituencies[x])
      
      df_cc <- cc_data %>% 
        filter(Region == Region_selected,
               Area_name == constituencies[x])
      
      df_aps %>% 
        rbind(df_cc) %>% 
        make_labourmarket_chart() %>% 
        hc_title(text = constituencies[x])
    })
  
  names(charts_labourmarket_constituencies[[i]]) <- constituencies
}

# Errorbar charts ----------------------------------------------------------------------
# Inactivity, Unemployment & Employment

charts_labourmarket_regions_unemployment_errorbar <- lapply(regions, function(x) {
  
  cc_data %>% 
    filter(Region == x | Area_name == "Scotland",
           Year == max(Year)) %>% 
    filter(Month == max(Month)) %>% 
    arrange(desc(Data)) %>% 
    make_labourmarket_errorbar_chart() %>% 
    hc_title(text = paste0("Proportion of 16+ year-olds in ", x, " constituencies who are unemployed"))
})

charts_labourmarket_regions_employment_errorbar <- lapply(regions, function(x) {
  
  data %>% 
    filter(Area_type == "SP Constituency" | Area_name == "Scotland",
           Region == x | Area_name == "Scotland",
           TimePeriod == max(TimePeriod),
           Measure == "Employment") %>% 
    arrange(desc(Data)) %>% 
    make_labourmarket_errorbar_chart() %>% 
    hc_title(text = paste0("Proportion of 16-65 year-olds in ", x, " constituencies who are employed or self-employed"))
})

charts_labourmarket_regions_inactivity_errorbar <- lapply(regions, function(x) {
  
  data %>% 
    filter(Area_type == "SP Constituency" | Area_name == "Scotland",
           Region == x | Area_name == "Scotland",
           TimePeriod == max(TimePeriod),
           Measure == "Inactivity") %>% 
    arrange(desc(Data)) %>% 
    make_labourmarket_errorbar_chart() %>% 
    hc_title(text = paste0("Proportion of 16-65 year-olds in ", x, " constituencies who are economically inactive"))
})

names(charts_labourmarket_regions_unemployment_errorbar) <- regions
names(charts_labourmarket_regions_employment_errorbar) <- regions
names(charts_labourmarket_regions_inactivity_errorbar) <- regions

# save all ---------------------------------------------------------------------

saveRDS(list(constituencies = charts_labourmarket_constituencies,
             regions_unemp = charts_labourmarket_regions_unemployment_errorbar,
             regions_emp = charts_labourmarket_regions_employment_errorbar,
             regions_inact = charts_labourmarket_regions_inactivity_errorbar), 
        "data/charts_labourmarket.rds")

