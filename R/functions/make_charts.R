make_linechart <- function(df){ 
  df %>% 
    hchart("line", hcaes(x = year, y = value, group = region),
           colour = spcols) %>% 
    hc_colors(colors = spcols) %>% 
    hc_xAxis(title = NULL) %>% 
    hc_yAxis(title = "", 
             labels = list(format = '£{value: ,f}')) %>% 
    hc_tooltip(valueDecimals = 0,
               valuePrefix = "£") %>% 
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
