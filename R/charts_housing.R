
# load -------------------------------------------------------------------------

library(tidyverse)
library(highcharter)

source("R/functions/f_make_charts.R")

data <- readRDS("data/tidy_housing_data.rds")
earnings_data <- readRDS("data/tidy_earnings_data.rds")
regions <- unique(data$Region)
regions <- regions[!is.na(regions)]

# house prices bar charts ------------------------------------------------------

data_hp1 <- data %>% 
  filter(Area_type == "SP Constituency" | Area_name == "Scotland",
         Measure == "Median house price",
         Year == max(Year))

house_prices <- lapply(seq_along(regions), function(x) {
  
  data_hp1 %>% 
    filter(Region == regions[x] | Area_name == "Scotland") %>% 
    make_house_prices_chart() %>% 
    hc_title(text = paste0("Median house prices in ", regions[x], ", ", data_hp1$Year[1]))
})

names(house_prices) <- regions

# house prices line charts -----------------------------------------------------
# time series

data_hp2 <- data %>% 
  filter(Area_type == "SP Constituency" | Area_name == "Scotland",
         Measure == "Median house price") %>% 
  arrange(desc(Data))

house_prices_ts <- lapply(seq_along(regions), function(x) {
  
  data_hp2 %>% 
    filter(Region == regions[x] | Area_name == "Scotland") %>% 
    make_house_prices_chart_ts()
})

names(house_prices_ts) <- regions

# housing affordability --------------------------------------------------------

data_hp3 <- data %>% 
  filter(Area_type == "Council" | Area_name == "Scotland",
         Measure == "Median house price",
         Year == max(Year))

afford <- earnings_data %>% 
  filter(Area_type == "Council" | Area_name == "Scotland",
         Measure == "Median weekly employee earnings",
         Year == data_hp3$Year[1]) %>% 
  left_join(data_hp3 %>% select(Area_name, Data) %>% rename(HousePrice = Data),
            by = "Area_name") %>% 
  mutate(Data = HousePrice / (Data * 52)) %>% 
  arrange(desc(Data))

# TODO ---------

# map councils to SP regions, see labour market charts



# tenure mix -------------------------------------------------------------------

# council tax mix --------------------------------------------------------------

# save all ---------------------------------------------------------------------

saveRDS(list(house_prices = house_prices,
             house_prices_ts = house_prices_ts), "data/charts_housing.rds")
