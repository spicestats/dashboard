library(tidyverse)
library(highcharter)
library(sf)
library(geojsonsf)
#library(rmapshaper)

source("R/functions/f_get_region.R")
simd <- readRDS("data/tidy_simd_data.rds")

#shp_dz <- sf::st_read("C:/Users/s910140/Downloads/SG_DataZoneBdry_2011/SG_DataZone_Bdry_2011.shp")

shp_SPC <- sf::st_read("C:/Users/s910140/Downloads/bdline_essh_gb/Data/GB/scotland_and_wales_const_region.shp") %>% 
  filter(AREA_CODE == "SPC") %>% 
  mutate(Constituency = const_code_to_name(CODE)) %>% 
  left_join(simd %>% filter(simdDomain == "simd"), by = "Constituency") %>% 
  select(Region, Constituency, q1, q2, q3, q4, q5, geometry)

regions <- unique(shp_SPC$Region)

highchart(type = "map") %>% 
  hc_add_series(mapData = sf_geojson(shp_SPC %>% filter(Region == regions[1])), 
                showInLegend = FALSE,
                data = simd, 
                joinBy = "Constituency",
                value = "q1",
                dataLabels = list(enabled = TRUE))

str(shp_SPC)
