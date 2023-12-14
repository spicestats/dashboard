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
  colors = spcols,
  
  # * chart ----
  chart = list(backgroundColor = "white",
               style = list(fontFamily = "Roboto",
                            fontSize = 'medium',
                            color = "grey20")),
  
  # * titles ----
  
  title = list(
    useHTML = TRUE,
    align = "left",
    style = list(fontSize = 'large',
                 color = "grey20",
                 fontWeight = 'bold')),
  
  subtitle = list(
    useHTML = TRUE,
    align = "left",
    style = list(fontSize = 'medium',
                 color = "grey20",
                 # enable wrapped text for subtitles
                 whiteSpace = 'inherit')),
  
  credits = list(
    style = list(fontSize = 'small',
                 color = "grey40")),
  
  # * y axis ----
  
  yAxis = list(
    title = list(
      style = list(fontSize = 'medium',
                   color = "grey40")),
    labels = list(
      style = list(fontSize = 'medium',
                   color = "grey40")),
    useHTML = TRUE,
    lineWidth = 1,
    tickAmount = 5,
    tickmarkPlacement = "on",
    tickLength = 5),
  
  # * x axis ----
  
  xAxis = list(
    title = list(
      style = list(fontSize = 'medium',
                   color = "grey40")),
    labels = list(
      useHTML = TRUE,
      style = list(fontSize = 'medium',
                   color = "grey40")),
    tickmarkPlacement = "on",
    tickLength = 0),
  
  # * tooltip ----
  tooltip = list(
    useHTML = TRUE,
    backgroundColor = "white",
    style = list(color = "grey20")),
  
  # * legend ----
  
  legend = list(
    itemStyle = list(
      color = "grey40",
      fontSize = "medium"
    )),
  
  plotOptions = list(
    series = list(
      
      # * dataLabels ----
      dataLabels = list(
        style = list(fontSize = "medium",
                     color = "grey20")),
      
      marker = list(fillColor = "white",
                    lineWidth = 2,
                    lineColor = NA)))
)

# make charts ------------------------------------------------------------------

make_linechart <- function(df){ 
  df %>% 
    hchart("line", hcaes(x = year, y = value, group = region),
           colour = spcols) %>% 
    hc_colors(colors = spcols) %>% 
    hc_xAxis(title = NULL) %>% 
    hc_yAxis(title = "", 
             labels = list(format = '\u00A3{value: ,f}')) %>% 
    hc_tooltip(valueDecimals = 0,
               valuePrefix = "\u00A3") %>% 
    hc_credits(enabled = TRUE,
               text = "Office for National Statistics ASHE data",
               href = "https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/earningsandworkinghours/bulletins/annualsurveyofhoursandearnings/previousReleases") %>% 
    hc_exporting(enabled = TRUE,
                 filename = NULL,
                 buttons = list(
                   contextButton = list(
                     menuItems = c("printChart", "downloadPNG", "downloadSVG")
                   ))
    ) %>% 
    hc_legend(align = "right",
              layout = "proximate")
} 