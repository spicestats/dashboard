make_linechart <- function(df){ 
  df %>% 
    hchart("line", hcaes(x = year, y = value, group = region),
           colour = spcols) %>% 
    hc_colors(colors = spcols) %>% 
    hc_xAxis(title = NULL) %>% 
    hc_yAxis(title = "", 
             labels = list(format = '£{value: ,f}')) %>% 
    hc_tooltip(valueDecimals = 0,
               valuePrefix = "£")
}  
