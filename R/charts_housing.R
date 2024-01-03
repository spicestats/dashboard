
# load -------------------------------------------------------------------------

library(tidyverse)
library(highcharter)

source("R/functions/f_make_charts.R")

data <- readRDS("data/tidy_housing_data.rds")
regions <- unique(data$Region)

# time series ----

lapply(1:11, function(x){

data %>% 
  filter(Region == regions[1],
         Constituency == unique(data$Constituency)[x],
         Measure == "Median house price") %>% 
  hchart("line", hcaes(x = Year, y = Data, group = Constituency)) %>% 
  hc_colors(colors = unname(spcols)) %>% 
  hc_xAxis(title = NULL) %>% 
  hc_yAxis(title = "", 
           labels = list(format = '\u00A3{value: ,f}'),
           min = 0,
           max = 250000) %>% 
  hc_tooltip(valueDecimals = 0,
             valuePrefix = "\u00A3",
             xDateFormat = '%b %Y') %>% 
  hc_exporting(enabled = TRUE) %>%
  hc_add_theme(my_theme) %>%
  hc_legend(verticalAlign = "bottom",
            align = "right",
            floating = TRUE,
            backgroundColor = "white",
            y = -25)}) %>% 
  hw_grid(ncol = 3)

# bar chart latest ----
