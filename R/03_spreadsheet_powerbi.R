
# get all data for the current PowerBI constituency dashboard ready


# load -------------------------------------------------------------------------

library(tidyverse)

socialsecurity <- readRDS("data/tidy_socialsecurity_data.rds")
housing <- readRDS("data/tidy_housing_data.rds")
labourmarket <- readRDS("data/tidy_labourmarket_data.rds")
lifeexpectancy <- readRDS("data/tidy_lifeexpectancy_data.rds")
population <- readRDS("data/tidy_population_data.rds")

data <- rbind(socialsecurity,
              housing$house_prices_spc,
              housing$counciltax,
              labourmarket,
              population,
              lifeexpectancy)

openxlsx::write.xlsx(data, "output/data_for_powerBI_constituency_dashboard.xlsx",
                     gridLines = FALSE)
