
# load -------------------------------------------------------------------------

library(tidyverse)
library(highcharter)

source("R/functions/f_make_charts.R")

spcols <- c("#B884CB", "#568125", "#E87722")


data <- readRDS("data/tidy_labourmarket_data.rds") %>% 
  arrange(Year, Month, Measure)

latest_quarter <- tail(data$Month, 1)
regions <- unique(data$Region)

# Constituencies ---------------------------------------------------------------
# Inactivity & Employment only

charts_labourmarket_constituencies <- list()

for (i in regions) {
  
  Region_selected <- i
  
  constituencies <- data %>% 
    filter(Region == Region_selected,
           !is.na(Constituency)) %>% 
    select(Constituency) %>% 
    distinct() %>% 
    pull()
  
  charts_labourmarket_constituencies[[i]] <- lapply(
    seq_along(constituencies), 
    function(x) {
      
      df <- data %>% 
        filter(Month == latest_quarter,
               Sex == "All",
               Measure != "Unemployment",
               Region == Region_selected,
               Constituency == constituencies[x])
      
      chart <- make_labourmarket_chart(df) %>% 
        hc_title(text = constituencies[x])
      
      # remove y axis labels from all charts except 1st and 5th
      if (!(x %in% c(1, 5, 9))) {
        chart <- chart %>% 
          hc_yAxis(labels = list(enabled = FALSE))
      }
      
      chart
      
    })
}


# Regions ----------------------------------------------------------------------
# Inactivity, Unemployment & Employment

charts_labourmarket_regions <- lapply(regions, function(x) {
  
  df <- data %>% 
    filter(Region == x,
           Month == latest_quarter,
           Sex == "All",
           is.na(Constituency))
  
  chart <- make_labourmarket_chart(df) %>% 
    hc_title(text = x)
  
  # remove y axis labels from all charts except 1st and 5th
  if (x != regions[1] & x != regions[5]) {
    chart <- chart %>% 
      hc_yAxis(labels = list(enabled = FALSE))
  }
  
  chart
  
})


# save all ---------------------------------------------------------------------

saveRDS(list(regions = charts_labourmarket_regions,
             constituencies = charts_labourmarket_constituencies), 
        "data/charts_labourmarket.rds")
