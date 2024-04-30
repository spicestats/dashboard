
# load -------------------------------------------------------------------------

library(tidyverse)
library(highcharter)
library(sf)
library(geojsonsf)
library(rmapshaper)
#library(jsonlite)
#library(geojsonio)

source("R/functions/f_make_charts.R")
source("R/functions/f_get_region.R")

simd <- readRDS("data/tidy_simd_data.rds")

regions <- unique(simd$shares$Region)
regions <- regions[!is.na(regions)]



# maps -------------------------------------------------------------------------

## Region maps -----------------------------------------------------------------

# Scottish Parliamentary Regions (December 2022) Boundaries SC BGC
# Scottish Parliamentary Constituencies (December 2022) Boundaries SC BGC

# shapefiles from: 
# https://geoportal.statistics.gov.uk/search?q=BDY_SPC%20DEC_2022&sort=Title%7Ctitle%7Casc

const_sf <- "data/Scottish_Parliamentary_Constituencies_December_2022_Boundaries_SC_BGC_811473201121076359/SPC_DEC_2022_SC_BGC.shp"
regions_sf <- "data/Scottish_Parliamentary_Regions_December_2022_SC_BGC_362369918693762846/SPR_DEC_2022_SC_BGC.shp"

# prepare SPC boundary map from shapefile
shp_SPC <- sf::st_read(const_sf) %>% 
  mutate(Constituency = const_code_to_name(SPC22CD),
         Region = const_name_to_region(Constituency)) %>% 
  select(Region, Constituency, geometry) %>% 
  filter(Region %in% regions[1:2]) %>% 
  # reduce size of map by losing some detail
  rmapshaper::ms_simplify(keep = 0.3)

# prepare SPR boundary map from shapefile
shp_SPR <- sf::st_read(regions_sf) %>% 
  rename(Region = SPR22NM) %>% 
  select(Region, geometry) %>% 
  filter(Region %in% regions[1:2]) %>% 
  # reduce size of map by losing some detail
  rmapshaper::ms_simplify(keep = 0.3)

# testing --------

# prepare SIMD data
localshares <- simd$shares %>% 
  filter(simdDomain == "SIMD",
         Measure == "In most deprived fifth",
         Region %in% regions[1:2]) %>% 
  rename(Constituency = Area_name) %>% 
  mutate(Data = Data * 100)

region_map <- jsonlite::fromJSON(geojsonsf::sf_geojson(shp_SPR), simplifyVector = FALSE)[[2]]

highchart(type = "map") %>%
  hc_add_series_map(map = jsonlite::fromJSON(geojsonsf::sf_geojson(shp_SPC), simplifyVector = FALSE), 
                    name = "SIMD 2020 local share", 
                    df = localshares, 
                    value = "Data", 
                    joinBy = "Constituency", 
                    # borderWidth = 0.5, 
                    # borderColor = hex_to_rgba("#000000", 0.75),
                    tooltip = list(
                      enabled = TRUE,
                      pointFormat = "{point.Constituency}: {point.value:.1f}%")
  ) %>%
  # add region outlines
  hc_add_series(data = region_map,
                type = "mapline",
                lineWidth = 1) %>%
  hc_colorAxis(
    min = 0,
    max = 100,
    maxColor = unname(spcols["purple"]),
    labels = list(format = "{text}%",
                  step = 1)) %>% 
  hc_add_theme(my_theme) %>%
  hc_mapNavigation(enabled = TRUE)



## DZ map ----------------------------------------------------------------------

# DZ shapefile downloaded from:
# https://spatialdata.gov.scot/geonetwork/srv/api/records/7d3e8709-98fa-4d71-867c-d5c8293823f2

# DZ shapefile
shp_DZ <- sf::st_read("data/SG_DataZoneBdry_2011/SG_DataZone_Bdry_2011.shp") %>% 
  mutate(Constituency = dz_code_to_const(DataZone),
         Region = const_name_to_region(Constituency),
         DataZoneName = dz_code_to_name(DataZone)) %>% 
  select(Region, Constituency, DataZone, DataZoneName, geometry) %>%
  # reduce size of map by losing some detail
  rmapshaper::ms_simplify(keep = 0.2)

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
      
      title <- case_when(d == "SIMD" ~ paste0("Where SIMD deprivation is concentrated in ", c),
                         d == "Education, Skills and Training" ~ paste0("Where Education domain deprivation is concentrated in ", c),
                         d == "Access to Services" ~ paste0("Where Access domain deprivation is concentrated in ", c),
                         TRUE ~ paste0("Where ", d, " domain deprivation is concentrated in ", c))
      
      make_decile_map(sf = shp_DZ %>% filter(Region == r, Constituency == c), 
                      df = ranks %>%  filter(Region == r, Constituency == c)) %>% 
        hc_title(text = title) %>% 
        hc_subtitle(text = "Deprivation decile in each Data Zone (1 = most deprived)")
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
