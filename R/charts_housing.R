
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
         Measure == "Median house price") %>% 
  filter(Year == max(Year))

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
    make_house_prices_chart_ts() %>% 
    hc_title(text = paste0("Median house prices in ", regions[x]))
})

names(house_prices_ts) <- regions

# housing affordability bar charts ---------------------------------------------

data_hp3 <- data %>% 
  filter(Area_type == "Council" | Area_name == "Scotland",
         Measure == "Median house price") %>% 
  filter(Year == max(Year))

afford <- earnings_data %>% 
  filter(Area_type == "Council" | Area_name == "Scotland",
         Measure == "Median weekly employee earnings") %>%
  filter(Year == data_hp3$Year[1]) %>% 
  left_join(data_hp3 %>% select(Area_name, Data) %>% rename(HousePrice = Data),
            by = "Area_name") %>% 
  mutate(Data = HousePrice / (Data * 52)) %>% 
  arrange(desc(Data))

# region (council) -level
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

# bar chart
affordability <- lapply(
  seq_along(region_council_lookup), function(x) {
    afford %>% 
      filter(Area_name %in% c("Scotland", region_council_lookup[[x]])) %>% 
      make_housing_affordability_chart() %>% 
      hc_title(text = "How many years' worth of average pay to buy an average house?") %>% 
      hc_subtitle(text = paste("Median house price relative to median pay per year in council areas within the", regions[x]," region,", year(max(afford$TimePeriod))))
  })

names(affordability) <- names(region_council_lookup)

# tenure mix -------------------------------------------------------------------
# hhld level analysis

tenure_data <- data %>% 
  filter(grepl("Tenure", Measure)) %>% 
  mutate(Measure = str_split_i(Measure, ": ", 2),
         Measure = factor(Measure, 
                          levels = c("Owned outright",
                                     "Buying with a mortgage",
                                     "Private rented",
                                     "Social rented"),
                          ordered = TRUE))

tenure <- lapply(seq_along(regions), function(x) {
  
  tenure_data %>% 
    filter(Region == regions[x] | Area_name == "Scotland") %>% 
    make_tenure_chart() %>% 
    hc_title(text = paste0("Share of households in each housing tenure in ", regions[x], ", ", max(tenure_data$Year)))
})

names(tenure) <- names(region_council_lookup)

# council tax mix --------------------------------------------------------------

ct_data <- data %>% 
  filter(Measure == "Dwellings by council tax band") %>% 
  filter(TimePeriod == max(TimePeriod)) %>% 
  select(Region, Area_name, Area_type, Year, CTBand, Data) %>% 
  filter(CTBand != "Total Dwellings") %>% 
  group_by(Area_name) %>% 
  mutate(Data = Data/sum(Data)) %>% 
  rename(Measure = CTBand)

counciltax <- lapply(seq_along(regions), function(x) {
  
  ct_data %>% 
    filter(Region == regions[x] | Area_name == "Scotland") %>% 
    make_tenure_chart() %>% 
    hc_title(text = paste0("Share of dwellings in each council tax band in ", regions[x], ", ", ct_data$Year[1]))
  
})

names(counciltax) <- names(region_council_lookup)

# EPC mix ----------------------------------------------------------------------

epc_data <- data %>% 
  filter(grepl("EPC", Measure)) %>% 
  select(Region, Area_name, Area_type, Measure, Data, Year) %>% 
  mutate(Data = Data/sum(Data), .by = "Area_name") 

epc <- lapply(seq_along(regions), function(x) {
  
  epc_data %>% 
    filter(Region == regions[x] | Area_name == "Scotland") %>% 
    make_tenure_chart() %>% 
    hc_title(text = paste0("Share of dwellings in each EPC band in ", regions[x], ", ", epc_data$Year[1]))
  
})

names(epc) <- regions

# save all ---------------------------------------------------------------------

saveRDS(list(house_prices = house_prices,
             house_prices_ts = house_prices_ts,
             affordability = affordability,
             tenure_mix = tenure,
             counciltax = counciltax,
             epc = epc), "data/charts_housing.rds")
