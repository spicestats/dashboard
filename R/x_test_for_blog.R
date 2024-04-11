
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

hc <- data_hp1 %>% 
  filter(Region == regions[1] | Area_name == "Scotland") %>% 
  make_house_prices_chart() %>% 
  hc_title(text = paste0("Median house prices in ", regions[1], ", ", data_hp1$Year[1]))

export_hc(hc, filename = "hc_ct.js", as = "container", name = "#selectorid")

htmlwidgets::saveWidget(hc, file = "widget.html")

htmlwidgets::getDependency(htmlwidgets::saveWidget(hc, file = "widget.html"))

# try and add this around the js code and put into html block in workpress

<script type="text/javascript" 

src="http://widgets.example.com/j/2/widget.js">
...
js
</script>


# also needs js libs