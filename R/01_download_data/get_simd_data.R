
# load -------------------------------------------------------------------------

library(tidyverse)
library(opendatascot)

# SIMD -------------------------------------------------------------------------

# split query into 4 so the api can cope

deciles <- ods_dataset("scottish-index-of-multiple-deprivation",
                         measureType = "decile",
                         simdDomain = c("simd", "income", "employment", 
                                        "housing", "health", 
                                        "education-skills-and-training",
                                        "crime"))

deciles_access_domain <- ods_dataset("scottish-index-of-multiple-deprivation",
                       measureType = "decile",
                       simdDomain = "access-to-services")

ranks <- ods_dataset("scottish-index-of-multiple-deprivation",
                       measureType = "rank",
                       simdDomain = c("simd", "income", "employment", 
                                      "housing", "health", 
                                      "education-skills-and-training",
                                      "crime"))

ranks_access_domain <- ods_dataset("scottish-index-of-multiple-deprivation",
                                     measureType = "rank",
                                     simdDomain = "access-to-services")

# save data --------------------------------------------------------------------

saveRDS(rbind(deciles, ranks, deciles_access_domain, ranks_access_domain), "data/simd_data.rds")

message <- paste("SIMD data downloaded from statistics.gov.scot - data from", deciles$refPeriod[1])

cat(message, fill = TRUE)
