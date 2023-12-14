
# load -------------------------------------------------------------------------

library(tidyverse)
library(highcharter)

source("R/functions/f_make_charts.R")

data <- readRDS("data/tidy_labourmarket_data.rds") %>% 
  arrange(Year, Month)

latest_quarter <- tail(data$Month, 1)

regions <- unique(data$Region)

charts_labourmarket <- list()

## labour market --------------------------------------------------------------

Region_selected <- regions[1]

constituencies <- data %>% 
  filter(Region == Region_selected,
         !is.na(Constituency)) %>% 
  select(Constituency) %>% 
  distinct() %>% 
  pull()

lapply(seq_along(constituencies), 
       function(x) {
         
         df <- data %>% 
           filter(Month == latest_quarter,
                  Sex == "All",
                  Measure != "Unemployment",
                  Region == Region_selected,
                  Constituency == constituencies[x])
        
         df %>% 
           hchart("line", hcaes(x = Year, y = Data, group = Measure),
                  marker = list(enabled = FALSE),
                  legend = list(enabled = FALSE)) %>% 
           hc_xAxis(title = NULL) %>% 
           hc_title(text = constituencies[x]) %>% 
           hc_add_series(type = "arearange", 
                         data = df, 
                         hcaes(x = Year, low = Lower, high = Upper, group = Measure),
                         color = spcols[2:1],
                         fillOpacity = 0.3,
                         enableMouseTracking = FALSE,
                         legend = list(enabled = FALSE),
                         lineColor = "transparent",
                         marker = list(enabled = FALSE)) %>% 
           hc_add_theme(my_theme) %>%
           hc_yAxis(title = list(text = ""),
                    max = 1,
                    labels = list(
                      formatter = JS('function () {
                              return Math.round(this.value*100, 0) + "%";} ')),
                    accessibility = list(description = "Rate"))
         
       }) %>% 
  hw_grid()
