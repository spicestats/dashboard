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
  df %>% 
    hchart("line", hcaes(x = year, y = value, group = region)) %>% 
    hc_colors(colors = unname(spcols)) %>% 
    hc_xAxis(title = NULL) %>% 
    hc_yAxis(title = "", 
             labels = list(format = '\u00A3{value: ,f}')) %>% 
    hc_tooltip(valueDecimals = 0,
               valuePrefix = "\u00A3",
               xDateFormat = '%b %Y') %>% 
    hc_exporting(enabled = TRUE) %>%
    hc_add_theme(my_theme) %>%
    hc_legend(verticalAlign = "bottom",
              align = "right",
              floating = TRUE,
              backgroundColor = "white",
              y = -25)
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
    hc_exporting(enabled = TRUE) %>%
    hc_legend(verticalAlign = "top",
              align = "right",
              floating = TRUE,
              #layout = "vertical",
              y = 15,
              backgroundColor = "white") %>% 
    hc_xAxis(title = NULL) %>% 
    hc_yAxis(title = "",
             max = 1,
             labels = list(
               formatter = JS('function () {
                              return Math.round(this.value*100, 0) + "%";} ')),
             accessibility = list(description = "Rate")) %>% 
    hc_add_theme(my_theme) %>%
    hc_tooltip(headerFormat = '<b> {series.name} </b><br>',
               pointFormatter = JS('function () {return Highcharts.dateFormat("%b %Y", this.x)  + ": " + Highcharts.numberFormat(this.y * 100, 1) + "%";}'))
}
