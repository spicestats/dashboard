
# load -------------------------------------------------------------------------

library(tidyverse)
library(highcharter)

source("R/functions/f_make_charts.R")

data <- readRDS("data/tidy_labourmarket_data.rds") %>% 
  arrange(Year, Month)

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
      
      df %>% 
        hchart("line", hcaes(x = Year, y = Data, group = Measure),
               marker = list(enabled = FALSE),
               id = c("a", "b")) %>% 
        hc_add_series(type = "arearange", 
                      data = df, 
                      hcaes(x = Year, low = Lower, high = Upper, group = Measure),
                      name = c(" ", " "),
                      linkedTo = c("a", "b"),
                      color = spcols[2:1],
                      fillOpacity = 0.3,
                      enableMouseTracking = FALSE,
                      lineColor = "transparent",
                      marker = list(enabled = FALSE),
                      showInLegend = FALSE) %>% 
        hc_title(text = constituencies[x]) %>% 
        hc_legend(#verticalAlign = "top",
                  enabled = FALSE) %>% 
        hc_xAxis(title = NULL) %>% 
        hc_yAxis(title = "",
                 max = 1,
                 labels = list(
                   formatter = JS('function () {
                              return Math.round(this.value*100, 0) + "%";} ')),
                 accessibility = list(description = "Rate")) %>% 
        hc_add_theme(my_theme) %>%
        hc_tooltip(headerFormat = '<b> {series.name} </b><br>',
                   pointFormatter = JS('function () {return this.x + ": " + Highcharts.numberFormat(this.y * 100, 1) + "%";}')
        )
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
  
  df %>% 
    hchart("line", hcaes(x = Year, y = Data, group = Measure),
           marker = list(enabled = FALSE),
           id = c("a", "b", "c")) %>% 
    hc_add_series(type = "arearange", 
                  data = df, 
                  hcaes(x = Year, low = Lower, high = Upper, group = Measure),
                  linkedTo = c("a", "b", "c"),
                  color = spcols[3:1],
                  fillOpacity = 0.3,
                  enableMouseTracking = FALSE,
                  lineColor = "transparent",
                  marker = list(enabled = FALSE),
                  showInLegend = FALSE) %>% 
    hc_title(text = x) %>% 
    hc_legend(#verticalAlign = "top",
              enabled = FALSE) %>% 
    hc_xAxis(title = NULL) %>% 
    hc_yAxis(title = "",
             max = 1,
             labels = list(
               formatter = JS('function () {
                              return Math.round(this.value*100, 0) + "%";} ')),
             accessibility = list(description = "Rate")) %>% 
    hc_add_theme(my_theme) %>%
    hc_tooltip(headerFormat = '<b> {series.name} </b><br>',
               pointFormatter = JS('function () {return this.x + ": " + Highcharts.numberFormat(this.y * 100, 1) + "%";}')
    )
})


# save all ---------------------------------------------------------------------

saveRDS(list(regions = charts_labourmarket_regions,
             constituencies = charts_labourmarket_constituencies), 
        "data/charts_labourmarket.rds")
