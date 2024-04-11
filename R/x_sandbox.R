library(tidyverse)
library(highcharter)
library(sf)
library(geojsonsf)
#library(rmapshaper)

shp_dz <- st_read("C:/Users/s910140/Downloads/SG_DataZoneBdry_2011/SG_DataZone_Bdry_2011.shp")
shp_SPC <- st_read("C:/Users/s910140/Downloads/bdline_essh_gb/Data/GB/scotland_and_wales_const_region.shp") %>% 
  filter(AREA_CODE == "SPC")

highchart(type = "map") %>% 
  hc_add_series(mapData = sf_geojson(shp_SPC))
