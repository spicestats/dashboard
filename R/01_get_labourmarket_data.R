
# Labour market data comes from the Annual Population Survey and is available on
# NOMIS

# load -------------------------------------------------------------------------

library(tidyverse)
library(nomisr)

# nomis datasets ---------------------------------------------------------------

# find APS / labour market datasets
#nomis_search(keywords = c("employment", "unemployment", "inactivity")) %>% view()

# APS dataset (residence based)
#APS_metadata <- nomis_get_metadata(id = "NM_17_5")

last_updated <- nomis_overview(id = "NM_17_5") %>% 
  filter(name == "lastupdated") %>% 
  unnest(value) %>% 
  pull(value)

# run these to understand what's in the datasets
#nomis_get_metadata(id = "NM_17_5", concept = "GEOGRAPHY")
#nomis_get_metadata(id = "NM_17_5", concept = "GEOGRAPHY", type = "TYPE") %>% view()
#nomis_get_metadata(id = "NM_17_5", concept = "TIME")
#nomis_get_metadata(id = "NM_17_5", concept = "MEASURES")
#nomis_get_metadata(id = "NM_17_5", concept = "FREQ")
#nomis_get_metadata(id = "NM_17_5", concept = "VARIABLE") %>% view()


# nomis queries ----------------------------------------------------------------

# APS rates
nomis_aps <- nomis_get_data(
  
  id = "NM_17_5", 
  
  # Scottish parliamentary regions & constituencies
  geography = c("TYPE241", "TYPE458"), 
  
  # frequency annual only (for now)
  freq = "A",
  
  # rates and confidence intervals
  # SP regional data only available since 12/2012 -> get numbers as well as rates
  # so can aggregate for older years
  measures = c(20599, 21001, 21002, 21003),
  
  # unemployment 16+ (all, male, female), employment 16-65 (a, m, f), inactivity 16-65 (a, m, f)
  # note that further age breakdowns are also available
  variable = c(83, 92, 101,
               45, 54, 63,
               111, 120, 129)
)

names(nomis_aps) <- tolower(names(nomis_aps))

# save data --------------------------------------------------------------------

saveRDS(nomis_aps, "data/labourmarketdata.rds")
# write message

cat("APS data downloaded from NOMIS - data last updated on NOMIS on", day(last_updated), 
    month.name[month(last_updated)], year(last_updated))
