
# load -------------------------------------------------------------------------

library(tidyverse)
library(highcharter)
library(sf)
library(geojsonsf)
library(rmapshaper)

source("R/functions/f_make_charts.R")
source("R/functions/f_get_region.R")

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
      hc_title(text = ifelse(x == "SIMD", 
                             paste0(x, " deprivation in ", y, " constituencies, ", 
                                    simd$ranks$refPeriod[1]),
                             paste0(x, " domain deprivation in ", y, " constituencies, ", 
                                    simd$ranks$refPeriod[1]))) %>% 
      hc_subtitle(text = "Share of Data Zones in each deprivation band")
  })
  names(out) <- regions
  return(out)
})

names(charts_simd) <- unique(simd$shares$simdDomain)

# maps -------------------------------------------------------------------------

## Region maps -----------------------------------------------------------------

# prepare SPC boundary map from shapefile
shp_SPC <- sf::st_read("C:/Users/s910140/Downloads/bdline_essh_gb/Data/GB/scotland_and_wales_const_region.shp") %>% 
  filter(AREA_CODE == "SPC") %>% 
  mutate(Constituency = const_code_to_name(CODE),
         Region = const_name_to_region(Constituency)) %>% 
  select(Region, Constituency, geometry) %>% 
  # reduce size of map by losing some detail
  rmapshaper::ms_simplify()

charts_localshare <- lapply(unique(simd$shares$simdDomain), function(x) {
  
  # prepare SIMD data
  localshares <- simd$shares %>% 
    filter(simdDomain == x,
           Measure == "In most deprived fifth") %>% 
    rename(Constituency = Area_name) %>% 
    mutate(Data = Data * 100)
  
  out <- lapply(regions, function(y) {
    
    make_localshare_map(sf = shp_SPC %>% filter(Region == y),
                        df = localshares %>% filter(Region == y)) %>% 
      hc_title(text = ifelse(x == "SIMD", paste0("Where ", x, " deprivation is concentrated in ", y),
                             paste0("Where ", x, " domain deprivation is concentrated in ", y))) %>% 
      hc_subtitle(text = "Constituencies' share of Scotland's 20% most deprived areas (Data Zones)")
  })
  names(out) <- regions
  return(out)
})

names(charts_localshare) <- unique(simd$shares$simdDomain)

## DZ map ----------------------------------------------------------------------

# DZ shapefile
shp_DZ <- sf::st_read("C:/Users/s910140/Downloads/SG_DataZoneBdry_2011/SG_DataZone_Bdry_2011.shp") %>% 
  mutate(Constituency = dz_code_to_const(DataZone),
         Region = const_name_to_region(Constituency),
         DataZoneName = dz_code_to_name(DataZone)) %>% 
  select(Region, Constituency, DataZone, DataZoneName, geometry) %>% 
  # reduce size of map by losing some detail
  rmapshaper::ms_simplify()

# loop over domains
charts_deciles <- lapply(unique(simd$shares$simdDomain), function(d) {
  
  ranks <- simd$ranks %>% 
    filter(simdDomain == d) %>% 
    rename(DataZoneName = DataZone,
           DataZone = refArea)
  
  # loop over regions
  out <- lapply(regions, function(r) {
    
    constituencies <- unique(ranks %>% filter(Region == r) %>% select(Constituency) %>% pull)
    
    # loop over constituencies
    const <- lapply(constituencies, function(c) {
      
      make_decile_map(sf = shp_DZ %>% filter(Region == r, Constituency == c), 
                      df = ranks %>%  filter(Region == r, Constituency == c)) %>% 
        hc_title(text = ifelse(d == "SIMD", paste0("Where ", d, " deprivation is concentrated in ", c),
                               paste0("Where ", d, " domain deprivation is concentrated in ", c))) %>% 
        hc_subtitle(text = "Deprivation decile in each Data Zone")
    })
    
    names(const) <- constituencies
    return(const)
  })
  
  names(out) <- regions
  return(out)
  
})

names(charts_deciles) <- unique(simd$shares$simdDomain)

# save all ---------------------------------------------------------------------

saveRDS(list(barchart = charts_simd,
             region_maps = charts_localshare,
             const_maps = charts_deciles), 
        "data/charts_deprivation.rds")
rm(list = ls())
