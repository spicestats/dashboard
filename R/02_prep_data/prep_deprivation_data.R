# load -------------------------------------------------------------------------

library(tidyverse)

source("R/functions/f_get_region.R")

simd_data <- readRDS("data/simd_data.rds")

tidy <- simd_data %>% 
  mutate(quintile = case_when(value <= 2 ~ 1,
                              value <= 4 ~ 2,
                              value <= 6 ~ 3,
                              value <= 8 ~ 4,
                              value <= 10 ~ 5),
         Constituency = dz_code_to_const(refArea),
         Region = const_name_to_region(Constituency)) %>% 
  summarise(q1 = sum(quintile == 1)/n(),
            q2 = sum(quintile == 2)/n(),
            q3 = sum(quintile == 3)/n(),
            q4 = sum(quintile == 4)/n(),
            q5 = sum(quintile == 5)/n(),
            .by = c(Region, Constituency, simdDomain))
  

# add constituencies and regions
# aggregate

saveRDS(tidy, "data/tidy_simd_data.rds")

