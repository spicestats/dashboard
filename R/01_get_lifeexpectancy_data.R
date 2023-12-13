
# load -------------------------------------------------------------------------

library(tidyverse)
library(opendatascot)

# download data ----------------------------------------------------------------

# get list of constituencies in dataset
spc <- ods_find_lower_geographies("S92000003") %>% 
  filter(grepl("S16", geography)) %>% 
  distinct() %>% 
  pull(geography)

data <- ods_dataset("Life-Expectancy",
            measureType = "count",
            simdQuintiles = "all",
            
            # life expectancy at age 0
            age = "0-years",
            urbanRuralClassification = "all",
            refArea = spc)

# save dataset -----------------------------------------------------------------

saveRDS(data, "data/lifeexpectancy.rds")

cat("Life expectancy data downloaded from statistics.gov.scot - latest data from",
                  max(data$refPeriod))
rm(list = ls())


  
  