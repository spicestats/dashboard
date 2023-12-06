
# load -------------------------------------------------------------------------

library(tidyverse)
library(highcharter)

hcoptslang <- getOption("highcharter.lang")
hcoptslang$thousandsSep <- ","
options(highcharter.lang = hcoptslang)

source("R/functions/make_charts.R")
spcols <- cols <-  c("#B884CB", "#568125", "#007DBA", "#E87722")

data <- readRDS("data/tidy_earnings.rds") %>% 
  filter(region %in% c("England", "Scotland", "Northern Ireland", "Wales"))

charts_earnings <- list()

# weekly -----------------------------------------------------------------------

charts_earnings$weekly_all <- data %>% 
  filter(employee == "All",
         pay == "weekly") %>% 
  make_linechart()

charts_earnings$weekly_FT <- data %>% 
  filter(employee == "Full-Time",
         pay == "weekly") %>% 
  make_linechart()

charts_earnings$weekly_PT <- data %>% 
  filter(employee == "Part-Time",
         pay == "weekly") %>% 
  make_linechart()

# annual -----------------------------------------------------------------------

charts_earnings$annual_all <- data %>% 
  filter(employee == "All",
         pay == "annual") %>% 
  make_linechart()

charts_earnings$annual_FT <- data %>% 
  filter(employee == "Full-Time",
         pay == "annual") %>% 
  make_linechart()

charts_earnings$annual_PT <- data %>% 
  filter(employee == "Part-Time",
         pay == "annual") %>% 
  make_linechart()

# hourly -----------------------------------------------------------------------

charts_earnings$hourly_all <- data %>% 
  filter(employee == "All",
         pay == "hourly") %>% 
  make_linechart() %>% 
  hc_tooltip(valueDecimals = 2)

charts_earnings$hourly_FT <- data %>% 
  filter(employee == "Full-Time",
         pay == "hourly") %>% 
  make_linechart() %>% 
  hc_tooltip(valueDecimals = 2)

charts_earnings$hourly_PT <- data %>% 
  filter(employee == "Part-Time",
         pay == "hourly") %>% 
  make_linechart() %>% 
  hc_tooltip(valueDecimals = 2)
