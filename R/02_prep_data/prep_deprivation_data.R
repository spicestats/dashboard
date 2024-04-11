# load -------------------------------------------------------------------------

library(tidyverse)

source("R/functions/f_get_region.R")

simd_data <- readRDS("data/simd_data.rds")

tidy <- simd_data

# add constituencies and regions
# aggregate

saveRDS(tidy, "data/tidy_simd_data.rds")