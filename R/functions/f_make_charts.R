# hc options -------------------------------------------------------------------

hcoptslang <- getOption("highcharter.lang")
hcoptslang$thousandsSep <- ","
options(highcharter.lang = hcoptslang)

# colors -----------------------------------------------------------------------

spcols <- c(darkblue = "#003057",
            midblue = "#007DBA",
            brightblue = "#00A9E0",
            jade = "#108765",
            green = "#568125",
            magenta = "#B0008E",
            mauve = "#B884CB",
            red = "#E40046",
            orange = "#E87722",
            gold = "#CC8A00",
            mustard = "#DAAA00")


# theme ------------------------------------------------------------------------

my_theme <- highcharter::hc_theme(
  
  # * colors ----
  colors = unname(spcols),
  
  # * chart ----
  chart = list(backgroundColor = "white",
               style = list(fontFamily = "Roboto",
                            fontSize = 'medium',
                            color = "grey30")),
  
  # * titles ----
  
  title = list(
    useHTML = TRUE,
    align = "left",
    style = list(fontSize = 'medium',
                 color = "grey30",
                 fontWeight = 'bold')),
  
  subtitle = list(
    useHTML = TRUE,
    align = "left",
    style = list(fontSize = 'medium',
                 color = "grey30",
                 # enable wrapped text for subtitles
                 whiteSpace = 'inherit')),
  
  credits = list(
    style = list(fontSize = 'small',
                 color = "grey80")),
  
  # * y axis ----
  
  yAxis = list(
    title = list(
      style = list(fontSize = 'medium',
                   color = "grey70")),
    labels = list(
      style = list(fontSize = 'small',
                   color = "grey70")),
    useHTML = TRUE,
    lineWidth = 1,
    tickAmount = 5,
    tickmarkPlacement = "on",
    tickLength = 5),
  
  # * x axis ----
  
  xAxis = list(
    title = list(
      style = list(fontSize = 'medium',
                   color = "grey70")),
    labels = list(
      useHTML = TRUE,
      style = list(fontSize = 'small',
                   color = "grey70")),
    tickmarkPlacement = "on",
    tickLength = 0),
  
  # * tooltip ----
  tooltip = list(
    useHTML = TRUE,
    backgroundColor = "white",
    outside = TRUE,
    style = list(color = "grey30")),
  
  # * legend ----
  
  legend = list(
    itemStyle = list(
      color = "grey70",
      fontSize = "small",
      fontWeight = "300"
    )),
  
  plotOptions = list(
    series = list(
      
      # * dataLabels ----
      dataLabels = list(
        style = list(fontSize = "medium",
                     color = "grey30")),
      
      marker = list(fillColor = "white",
                    lineWidth = 2,
                    lineColor = NA)))
)

# make charts ------------------------------------------------------------------

hcoptslang <- getOption("highcharter.lang")
hcoptslang$thousandsSep <- ","
options(highcharter.lang = hcoptslang)

make_earnings_chart <- function(df){ 
  
  ids <- unique(df$Area_name)
  
  df %>% 
    hchart("line", hcaes(x = TimePeriod, y = Data, group = Area_name),
           id = ids) %>% 
    hc_add_series(type = "arearange", 
                  data = df, 
                  hcaes(x = TimePeriod, low = Lower, high = Upper, group = Area_name),
                  linkedTo = ids,
                  fillOpacity = 0.3,
                  enableMouseTracking = FALSE,
                  lineColor = "transparent",
                  showInLegend = FALSE) %>% 
    hc_colors(colors = unname(spcols[1:length(ids)])) %>% 
    hc_xAxis(title = NULL) %>% 
    hc_yAxis(title = "", 
             labels = list(format = '\u00A3{value: ,f}')) %>% 
    hc_tooltip(valueDecimals = 0,
               valuePrefix = "\u00A3",
               xDateFormat = '%b %Y') %>% 
    hc_add_theme(my_theme) %>%
    hc_plotOptions(series = list(marker = list(enabled = FALSE))) %>%
    hc_legend(verticalAlign = "top",
              align = "right",
              floating = TRUE,
              backgroundColor = "white",
              y = 20)
} 

make_region_earnings_chart <- function(df, council_list) {
  
  df %>% 
    filter(Area_name %in% council_list,
           Measure == "Median weekly employee earnings") %>% 
    make_earnings_chart() %>% 
    hc_legend(layout = "proximate",
              align = "right")
}

make_labourmarket_chart <- function(df){
  
  ids <- unique(df$Measure)
  
  df %>% 
    hchart("line", hcaes(x = Year, y = Data, group = Measure),
           marker = list(enabled = FALSE),
           id = ids) %>% 
    hc_add_series(type = "arearange", 
                  data = df, 
                  hcaes(x = Year, low = Lower, high = Upper, group = Measure),
                  linkedTo = ids,
                  fillOpacity = 0.3,
                  enableMouseTracking = FALSE,
                  lineColor = "transparent",
                  marker = list(enabled = FALSE),
                  showInLegend = FALSE) %>% 
    hc_colors(colors = unname(spcols[1:length(ids)])) %>% 
    hc_legend(verticalAlign = "top",
              align = "right",
              floating = TRUE,
              y = 15,
              backgroundColor = "white") %>% 
    hc_xAxis(title = NULL) %>% 
    hc_yAxis(title = "",
             softMin = 0,
             softMax = 1,
             maxPadding = 0, 
             labels = list(
               formatter = JS('function () {
                              return Math.round(this.value*100, 0) + "%";} ')),
             accessibility = list(description = "Rate")) %>% 
    hc_add_theme(my_theme) %>%
    hc_tooltip(headerFormat = '<b> {series.name} </b><br>',
               pointFormatter = JS('function () {return Highcharts.dateFormat("%b %Y", this.x)  + ": " + Highcharts.numberFormat(this.y * 100, 1) + "%";}'))
}

make_labourmarket_errorbar_chart <- function(df) {
  df %>% 
    hchart("scatter", hcaes(x = Area_name, y = Data), 
           name = paste(month.abb[df$Month[1]], year(df$Year[1]))) %>% 
    hc_add_series(type = "errorbar", 
                  data = df, 
                  hcaes(x = Area_name, low = Lower, high = Upper),
                  enableMouseTracking = FALSE) %>% 
    hc_chart(inverted = TRUE) %>% 
    hc_colors(colors = unname(spcols)) %>% 
    hc_xAxis(title = NULL) %>% 
    hc_yAxis(title = "",
             labels = list(
               formatter = JS('function () {
                              return Math.round(this.value*100, 0) + "%";} ')),
             accessibility = list(description = "Rate")) %>% 
    hc_add_theme(my_theme) %>%
    hc_tooltip(pointFormatter = JS(
      'function () {return Highcharts.numberFormat(this.y * 100, 1) + "%";}'
    ))
}

make_house_prices_chart <- function(df){
  
  df %>% 
    arrange(desc(Data)) %>% 
    hchart("bar", hcaes(x = Area_name, y = Data),
           name = df$Year[1]) %>% 
    hc_colors(colors = unname(spcols)) %>% 
    hc_xAxis(title = NULL) %>% 
    hc_yAxis(title = "", 
             labels = list(format = '\u00A3{value: ,f}')) %>% 
    hc_tooltip(valueDecimals = 0,
               valuePrefix = "\u00A3",
               xDateFormat = '%b %Y') %>% 
    hc_add_theme(my_theme)
}

make_house_prices_chart_ts <- function(df){
  
  spcols <- spcols[1:length(unique(df$Area_name))]
  
  df %>% 
    arrange(TimePeriod, desc(Data)) %>% 
    hchart("line", hcaes(x = TimePeriod, y = Data, group = Area_name)) %>% 
    hc_colors(colors = unname(spcols)) %>% 
    hc_xAxis(title = NULL) %>% 
    hc_yAxis(title = "", 
             labels = list(format = '\u00A3{value: ,f}')) %>% 
    hc_tooltip(valueDecimals = 0,
               valuePrefix = "\u00A3",
               xDateFormat = '%b %Y') %>% 
    hc_add_theme(my_theme) %>% 
    hc_plotOptions(line = list(marker = list(enabled = FALSE))) %>%
    hc_legend(layout = "proximate",
              align = "right",
              backgroundColor = "white") 
}

make_housing_affordability_chart <- function(df){
  
  df %>% 
    arrange(desc(Data)) %>% 
    hchart("bar", hcaes(x = Area_name, y = Data),
           name = df$Year[1]) %>% 
    hc_colors(colors = unname(spcols)) %>% 
    hc_xAxis(title = NULL) %>% 
    hc_yAxis(title = "") %>% 
    hc_tooltip(valueDecimals = 1,
               xDateFormat = '%b %Y') %>% 
    hc_add_theme(my_theme)
}

make_tenure_chart <- function(df) {
  df %>%    
    arrange(Measure, desc(Data)) %>% 
    hchart("bar", hcaes(x = Area_name, y = Data, group = Measure)) %>% 
    hc_colors(colors = unname(spcols)) %>% 
    hc_plotOptions(bar = list(stacking = "normal")) %>% 
    hc_xAxis(title = NULL) %>% 
    hc_yAxis(title = "",
             reversedStacks = FALSE,
             max = 1,
             labels = list(
               formatter = JS('function () {
                              return Math.round(this.value*100, 0) + "%";} '))
    ) %>% 
    hc_tooltip(pointFormatter = JS('function () {return this.series.name  + ": " + Highcharts.numberFormat(this.y * 100, 0) + "%";}')) %>% 
    hc_add_theme(my_theme)
}

make_earnings_errorbar_chart <- function(df) {
  
  df %>% 
    hchart("scatter", hcaes(x = Area_name, y = Data),
           name = paste(month.abb[df$Month[1]], df$Year[1])) %>% 
    hc_chart(inverted = TRUE) %>% 
    hc_add_series("errorbar", data = df, hcaes(low = Lower, high = Upper),
                  enableMouseTracking = FALSE) %>% 
    hc_colors(colors = unname(spcols)) %>% 
    hc_xAxis(title = NULL) %>% 
    hc_yAxis(title = "", 
             labels = list(format = '\u00A3{value: ,f}')) %>% 
    hc_tooltip(valueDecimals = 0,
               valuePrefix = "\u00A3",
               pointFormat = "<b>{point.y}</b><br/>") %>% 
    hc_add_theme(my_theme)
}

make_povertyrate_chart <- function(df) {
  
  ids <- unique(df$Area_name)
  
  df %>% 
    hchart("line", hcaes(x = Year, y = Data, group = Area_name),
           id = ids) %>% 
    hc_colors(colors = unname(spcols[1:length(ids)])) %>% 
    hc_xAxis(title = NULL) %>% 
    hc_yAxis(title = "",
             labels = list(
               formatter = JS('function () {
                              return Math.round(this.value*100, 0) + "%";} ')),
             accessibility = list(description = "Rate")) %>% 
    hc_add_theme(my_theme) %>%
    hc_tooltip(headerFormat = '<b> {point.key} </b><br>',
               pointFormatter = JS('function () {return this.series.name  + ": " + Highcharts.numberFormat(this.y * 100, 0) + "%";}')) 
}

make_povertynumber_chart <- function(df) {
  
  ids <- unique(df$Area_name)
  
  df %>% 
    hchart("line", hcaes(x = Year, y = Data, group = Area_name),
           id = ids) %>% 
    hc_colors(colors = unname(spcols[1:length(ids)])) %>% 
    hc_xAxis(title = NULL) %>% 
    hc_yAxis(title = "", 
             labels = list(format = '{value: ,f}')) %>% 
    hc_add_theme(my_theme)
}

make_povertyrate_age_chart <- function(df) {
  
  ids <- unique(df$Age)
  
  df %>% 
    hchart("line", hcaes(x = Year, y = Data, group = Age),
           id = ids) %>% 
    hc_colors(colors = unname(spcols[1:length(ids)])) %>% 
    hc_xAxis(title = NULL) %>% 
    hc_yAxis(title = "",
             labels = list(
               formatter = JS('function () {
                              return Math.round(this.value*100, 0) + "%";} ')),
             accessibility = list(description = "Rate")) %>% 
    hc_add_theme(my_theme) %>%
    hc_tooltip(headerFormat = '<b> {point.key} </b><br>',
               pointFormatter = JS('function () {return this.series.name  + ": " + Highcharts.numberFormat(this.y * 100, 0) + "%";}')) 
  
}


