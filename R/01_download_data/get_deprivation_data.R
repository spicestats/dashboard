
# load -------------------------------------------------------------------------

library(tidyverse)
library(opendatascot)

# SIMD -------------------------------------------------------------------------

simd_data <- ods_dataset("scottish-index-of-multiple-deprivation",
                         measureType = "decile",
                         simdDomain = c("simd", "income", "employment", 
                                        "housing", "health", 
                                        "education-skills-and-training",
                                        "crime"))


# save data --------------------------------------------------------------------

saveRDS(simd_data, "data/simd_data.rds")

message <- paste("SIMD data downloaded from statistics.gov.scot - data from", simd_data$refPeriod[1])

cat(message, fill = TRUE)
