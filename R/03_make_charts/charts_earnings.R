
# load -------------------------------------------------------------------------

library(tidyverse)
library(highcharter)

source("R/functions/f_make_charts.R")

data <- readRDS("data/tidy_earnings_data.rds")
inflators <- readRDS("data/inflators.rds")

data_countries <- data %>% 
  filter(Area_type == "Country",
         Area_name != "United Kingdom")

data_councils <- data %>% 
  filter(Area_type == "Council" | Area_name == "Scotland",
         Year >= 2008)

councils <- unique(data_councils$Area_name)

charts_earnings <- list()

# country-level ----------------------------------------------------------------

## nominal ----------------------------------------------------------------------

### weekly ----------------------------------------------------------------------

charts_earnings$countries$weekly_all <- data_countries %>% 
  filter(Measure == "Median weekly employee earnings") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "All employees")

charts_earnings$countries$weekly_FT <- data_countries %>% 
  filter(Measure == "Median weekly full-time employee earnings") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "Full-time employees")

charts_earnings$countries$weekly_PT <- data_countries %>% 
  filter(Measure == "Median weekly part-time employee earnings") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "Part-time employees")

### annual ----------------------------------------------------------------------

charts_earnings$countries$annual_all <- data_countries %>% 
  filter(Measure == "Median annual employee earnings") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "All employees")

charts_earnings$countries$annual_FT <- data_countries %>% 
  filter(Measure == "Median annual full-time employee earnings") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "Full-time employees")

charts_earnings$countries$annual_PT <- data_countries %>% 
  filter(Measure == "Median annual part-time employee earnings") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "Part-time employees")

### hourly ----------------------------------------------------------------------

charts_earnings$countries$hourly_all <- data_countries %>% 
  filter(Measure == "Median hourly employee earnings") %>% 
  make_earnings_chart() %>% 
  hc_tooltip(valueDecimals = 2) %>% 
  hc_title(text = "All employees")

charts_earnings$countries$hourly_FT <- data_countries %>% 
  filter(Measure == "Median hourly full-time employee earnings") %>% 
  make_earnings_chart() %>% 
  hc_tooltip(valueDecimals = 2) %>% 
  hc_title(text = "Full-time employees")

charts_earnings$countries$hourly_PT <- data_countries %>% 
  filter(Measure == "Median hourly part-time employee earnings") %>% 
  make_earnings_chart() %>% 
  hc_tooltip(valueDecimals = 2) %>% 
  hc_title(text = "Part-time employees")


## real -------------------------------------------------------------------------

### weekly ----------------------------------------------------------------------

data_countries_real <- data_countries %>% 
  left_join(inflators, by = c(Year = "year")) %>% 
  mutate(Data = Data * inflator,
         Lower = Lower * inflator,
         Upper = Upper * inflator)

charts_earnings$countries$weekly_all_real <- data_countries_real %>% 
  filter(Measure == "Median weekly employee earnings") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "All employees")

charts_earnings$countries$weekly_FT_real <- data_countries_real %>% 
  filter(Measure == "Median weekly full-time employee earnings") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "Full-time employees")

charts_earnings$countries$weekly_PT_real <- data_countries_real %>% 
  filter(Measure == "Median weekly part-time employee earnings") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "Part-time employees")

### annual ----------------------------------------------------------------------

charts_earnings$countries$annual_all_real <- data_countries_real %>% 
  filter(Measure == "Median annual employee earnings") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "All employees")

charts_earnings$countries$annual_FT_real <- data_countries_real %>% 
  filter(Measure == "Median annual full-time employee earnings") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "Full-time employees")

charts_earnings$countries$annual_PT_real <- data_countries_real %>% 
  filter(Measure == "Median annual part-time employee earnings") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "Part-time employees")

### hourly ----------------------------------------------------------------------

charts_earnings$countries$hourly_all_real <- data_countries_real %>% 
  filter(Measure == "Median hourly employee earnings") %>% 
  make_earnings_chart() %>% 
  hc_tooltip(valueDecimals = 2) %>% 
  hc_title(text = "All employees")

charts_earnings$countries$hourly_FT_real <- data_countries_real %>% 
  filter(Measure == "Median hourly full-time employee earnings") %>% 
  make_earnings_chart() %>% 
  hc_tooltip(valueDecimals = 2) %>% 
  hc_title(text = "Full-time employees")

charts_earnings$countries$hourly_PT_real <- data_countries_real %>% 
  filter(Measure == "Median hourly part-time employee earnings") %>% 
  make_earnings_chart() %>% 
  hc_tooltip(valueDecimals = 2) %>% 
  hc_title(text = "Part-time employees")

# region (council) -level ------------------------------------------------------
# combine those councils that overlap with a region

region_council_lookup <- list(
  "Central Scotland" = c("Falkirk", "North Lanarkshire", "South Lanarkshire"),
  "Glasgow" = c("Glasgow City", "South Lanarkshire"),
  "Highlands and Islands" = c("Argyll and Bute", "Highland", "Moray", 
                              "Na h-Eileanan Siar", "Orkney Islands", 
                              "Shetland Islands"),
  "Lothian" = c("City of Edinburgh", "East Lothian", "Midlothian", 
                "West Lothian"),
  "Mid Scotland and Fife" = c("Clackmannanshire", "Fife",  "Perth and Kinross", 
                              "Stirling"),
  "North East Scotland" = c("Aberdeen City", "Aberdeenshire",  "Angus", 
                            "Dundee City", "Moray"),
  "South Scotland" = c("Dumfries and Galloway", "East Ayrshire", "East Lothian", 
                       "Midlothian", "Scottish Borders", "South Ayrshire", 
                       "South Lanarkshire"),
  "West Scotland" = c("Argyll and Bute", "East Dunbartonshire", 
                      "East Renfrewshire", "Inverclyde", "North Ayrshire", 
                      "Renfrewshire", "West Dunbartonshire"))

## errorbar charts -------------------------------------------------------------

charts_earnings$regions$latest <- lapply(
  seq_along(region_council_lookup), function(x) {
    data_councils %>% 
      filter(TimePeriod == max(TimePeriod),
             Measure == "Median weekly employee earnings") %>% 
      arrange(desc(Data)) %>% 
      filter(Area_name %in% c("Scotland", region_council_lookup[[x]])) %>% 
      make_earnings_errorbar_chart() %>% 
      hc_title(text = paste("Weekly median gross employee pay,", year(max(data_councils$TimePeriod))))
  })

names(charts_earnings$regions$latest) <- names(region_council_lookup)


## time series ----------------------------------------------------------------

### nominal ---------------------------------------------------------------------

charts_earnings$regions$nominal <- lapply(
  seq_along(region_council_lookup), 
  function(x) {
    make_region_earnings_chart(df = data_councils, 
                               council_list = c("Scotland", region_council_lookup[[x]])) %>% 
      hc_title(text = "Weekly median gross employee pay")
  })

names(charts_earnings$regions$nominal) <- names(region_council_lookup)

### real -------------------------------------------------------------------------

data_councils_real <- data_councils %>% 
  left_join(inflators, by = c(Year = "year")) %>% 
  mutate(Data = Data * inflator,
         Lower = Lower * inflator,
         Upper = Upper * inflator)

charts_earnings$regions$real <- lapply(
  seq_along(region_council_lookup), 
  function(x) {
    make_region_earnings_chart(df = data_councils_real, 
                               council_list = c("Scotland", region_council_lookup[[x]])) %>% 
      hc_title(text = "Weekly median gross employee pay in real terms")
  })

names(charts_earnings$regions$real) <- names(region_council_lookup)

# save -------------------------------------------------------------------------

saveRDS(charts_earnings, "data/charts_earnings.rds")

rm(list = ls())
