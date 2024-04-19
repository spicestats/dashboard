
# load -------------------------------------------------------------------------

library(tidyverse)
library(highcharter)
library(sf)
library(geojsonsf)

source("R/functions/f_make_charts.R")

simd <- readRDS("data/tidy_simd_data.rds")

regions <- unique(simd$shares$Region)
regions <- regions[!is.na(regions)]

# local shares -----------------------------------------------------------------

charts_simd <- lapply(unique(simd$shares$simdDomain), function(x) {
  out <- lapply(regions, function(y) {
    simd$shares %>% 
      filter(Region == y | Area_name == "Scotland",
             simdDomain == x) %>% 
      make_tenure_chart() %>% 
      hc_title(text = paste0(x, " deprivation in ", y, " constituencies, ", 
                             simd$ranks$refPeriod[1])) %>% 
      hc_subtitle(text = "Share of data zones in each deprivation band")
  })
  names(out) <- regions
  return(out)
})

names(charts_simd) <- unique(simd$shares$simdDomain)

# maps -------------------------------------------------------------------------

x <- regions[1]
y <- unique(simd$ranks$Constituency[1])

ranks <- simd$ranks %>% 
  filter(simdDomain == "SIMD") %>% 
  select()

# SPC shapefile
shp_SPC <- sf::st_read("C:/Users/s910140/Downloads/bdline_essh_gb/Data/GB/scotland_and_wales_const_region.shp") %>% 
  filter(AREA_CODE == "SPC") %>% 
  mutate(Constituency = const_code_to_name(CODE),
         Region = const_name_to_region(Constituency)) %>% 
  select(Region, Constituency, geometry)

# DZ shapefile
shp_DZ <- sf::st_read("C:/Users/s910140/Downloads/SG_DataZoneBdry_2011/SG_DataZone_Bdry_2011.shp") %>% 
  mutate(Constituency = dz_code_to_const(DataZone),
         Region = const_name_to_region(Constituency)) %>% 
  select(Region, Constituency, DataZone, geometry)

# create Region map with constituency boundaries

# TO DO ----------------

# see https://jkunst.com/highcharter/articles/maps.html

region_map <- highchart(type = "map") %>% 
  hc_add_series(mapData = sf_geojson(shp_SPC %>% filter(Region == x, Constituency == y)), 
                showInLegend = FALSE)
  
region_map  %>% 
  hc_add_series(mapData = sf_geojson(shp_DZ %>% filter(Region == x, Constituency == y)), 
                data = ranks,
                joinBy = c("DataZone", "refArea"),
                value = "rank",
                showInLegend = FALSE,
                dataLabels = list(enabled = TRUE))

# save all ---------------------------------------------------------------------

saveRDS(list(simd_shares = charts_simd), 
        "data/charts_deprivation.rds")

rm(list = ls())
