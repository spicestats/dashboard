
# load -------------------------------------------------------------------------

library(tidyverse)
library(highcharter)

source("R/functions/f_make_charts.R")

data <- readRDS("data/tidy_housing_data.rds")
earnings_data <- readRDS("data/tidy_PAYE_data.rds")[["paye"]]
regions <- unique(data$Region)
regions <- regions[!is.na(regions)]

# house prices bar charts ------------------------------------------------------

data_hp1 <- data %>% 
  filter(Area_type == "SP Constituency",
         Measure == "Median house price",
         Year == max(Year))

house_prices <- lapply(seq_along(regions), function(x) {
  
  data_hp1 %>% 
    filter(Region == regions[x]) %>% 
    make_house_prices_chart() %>% 
    hc_title(text = paste0("Median house prices in ", regions[x], ", ", data_hp1$Year[1]))
})

names(house_prices) <- regions

# house prices line charts -----------------------------------------------------
# time series

data_hp2 <- data %>% 
  filter(Area_type == "SP Constituency",
         Measure == "Median house price")

house_prices_ts <- lapply(seq_along(regions), function(x) {
  
  data_hp2 %>% 
    filter(Region == regions[x]) %>% 
    make_house_prices_chart_ts()
})

names(house_prices_ts) <- regions

# housing affordability --------------------------------------------------------

data_hp3 <- data %>% 
  filter(Area_type == "Council",
         Measure == "Median house price",
         Year == max(Year))

earnings_data %>% 
  filter(Area_type == "Council",
         Month == 4) %>% # select April
  filter(TimePeriod == max(TimePeriod)) # needs separate filter step!

# TODO ---------

# map councils (there are 41??) to SP regions, see https://boundaries.scot/boundary-maps



# tenure mix -------------------------------------------------------------------

# council tax mix --------------------------------------------------------------

# save all ---------------------------------------------------------------------

saveRDS(list(house_prices = house_prices,
             house_prices_ts = house_prices_ts), "data/charts_housing.rds")
