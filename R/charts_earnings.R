
# load -------------------------------------------------------------------------

library(tidyverse)
library(highcharter)

source("R/functions/f_make_charts.R")

spcols <- c("#B884CB", "#568125", "#007DBA", "#E87722")

data <- readRDS("data/tidy_earnings_data.rds") %>% 
  filter(region %in% c("England", "Scotland", "Northern Ireland", "Wales"))

charts_earnings <- list()

# nominal ----------------------------------------------------------------------

## weekly ----------------------------------------------------------------------

charts_earnings$weekly_all <- data %>% 
  filter(employee == "All",
         pay == "weekly") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "All employees")

charts_earnings$weekly_FT <- data %>% 
  filter(employee == "Full-Time",
         pay == "weekly") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "Full-time employees")

charts_earnings$weekly_PT <- data %>% 
  filter(employee == "Part-Time",
         pay == "weekly") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "Part-time employees")

## annual ----------------------------------------------------------------------

charts_earnings$annual_all <- data %>% 
  filter(employee == "All",
         pay == "annual") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "All employees")

charts_earnings$annual_FT <- data %>% 
  filter(employee == "Full-Time",
         pay == "annual") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "Full-time employees")

charts_earnings$annual_PT <- data %>% 
  filter(employee == "Part-Time",
         pay == "annual") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "Part-time employees")

## hourly ----------------------------------------------------------------------

charts_earnings$hourly_all <- data %>% 
  filter(employee == "All",
         pay == "hourly") %>% 
  make_earnings_chart() %>% 
  hc_tooltip(valueDecimals = 2) %>% 
  hc_title(text = "All employees")

charts_earnings$hourly_FT <- data %>% 
  filter(employee == "Full-Time",
         pay == "hourly") %>% 
  make_earnings_chart() %>% 
  hc_tooltip(valueDecimals = 2) %>% 
  hc_title(text = "Full-time employees")

charts_earnings$hourly_PT <- data %>% 
  filter(employee == "Part-Time",
         pay == "hourly") %>% 
  make_earnings_chart() %>% 
  hc_tooltip(valueDecimals = 2) %>% 
  hc_title(text = "Part-time employees")


# real -------------------------------------------------------------------------

## weekly ----------------------------------------------------------------------

data_real <- data %>% mutate(value = value * inflator)

charts_earnings$weekly_all_real <- data_real %>% 
  filter(employee == "All",
         pay == "weekly") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "All employees")

charts_earnings$weekly_FT_real <- data_real %>% 
  filter(employee == "Full-Time",
         pay == "weekly") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "Full-time employees")

charts_earnings$weekly_PT_real <- data_real %>% 
  filter(employee == "Part-Time",
         pay == "weekly") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "Part-time employees")

## annual ----------------------------------------------------------------------

charts_earnings$annual_all_real <- data_real %>% 
  filter(employee == "All",
         pay == "annual") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "All employees")

charts_earnings$annual_FT_real <- data_real %>% 
  filter(employee == "Full-Time",
         pay == "annual") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "Full-time employees")

charts_earnings$annual_PT_real <- data_real %>% 
  filter(employee == "Part-Time",
         pay == "annual") %>% 
  make_earnings_chart() %>% 
  hc_title(text = "Part-time employees")

## hourly ----------------------------------------------------------------------

charts_earnings$hourly_all_real <- data_real %>% 
  filter(employee == "All",
         pay == "hourly") %>% 
  make_earnings_chart() %>% 
  hc_tooltip(valueDecimals = 2) %>% 
  hc_title(text = "All employees")

charts_earnings$hourly_FT_real <- data_real %>% 
  filter(employee == "Full-Time",
         pay == "hourly") %>% 
  make_earnings_chart() %>% 
  hc_tooltip(valueDecimals = 2) %>% 
  hc_title(text = "Full-time employees")

charts_earnings$hourly_PT_real <- data_real %>% 
  filter(employee == "Part-Time",
         pay == "hourly") %>% 
  make_earnings_chart() %>% 
  hc_tooltip(valueDecimals = 2) %>% 
  hc_title(text = "Part-time employees")

# save -------------------------------------------------------------------------

saveRDS(charts_earnings, "data/charts_earnings.rds")
