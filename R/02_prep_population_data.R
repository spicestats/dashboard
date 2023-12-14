# load -------------------------------------------------------------------------

library(tidyverse)
source("R/functions/f_get_region.R")

data_years <- readxl::excel_sheets("data/spc_population.xlsx")
data_years <- data_years[!(data_years %in% c("General_notes", "Table_of_contents"))]

pop_data <- lapply(seq_along(data_years), function(x) {
  readxl::read_excel("data/spc_population.xlsx", sheet = data_years[x], skip = 3) %>% 
    mutate(year = data_years[x]) }) %>% 
  bind_rows()

pop <- pop_data %>% 
  rename(Constituency = "Scottish Parliamentary Constituency name",
         Year = year) %>% 
  pivot_longer(cols = c(paste("Age", 0:89), "Age 90 and over"), names_to = "Age",
               values_to = "population") %>% 
  mutate(Constituency = case_when(Constituency == "Perthshire South and Kinross-shire" ~ "Perthshire South and Kinrossshire",
                                  TRUE ~ Constituency),
         Sex = case_when(Sex == "Females" ~ "Female",
                         Sex == "Males" ~ "Male",
                         Sex == "Persons" ~ "All"),
         Age = as.numeric(str_sub(Age, 4, 6)),
         agegroup = case_when(Age < 16 ~ "Under 16",
                                  Age <= 24 ~ "16 to 24",
                                  Age <= 49 ~ "25 to 49",
                                  Age <= 64 ~ "50 to 64",
                                  Age <= 84 ~ "65 to 84",
                                  TRUE ~ "85 and over"),
         agegroup = factor(agegroup, ordered = TRUE),
         agegroup = fct_relevel(agegroup, "Under 16", after = 0L)) %>% 
  group_by(Year, Constituency, Sex, agegroup) %>% 
  summarise(Total = Total[1],
            population = sum(population),
            share = population/Total) %>% 
  mutate(Region = const_name_to_region(Constituency),
         Subject = "Population",
         Measure = "Age groups",
         TimePeriod = Year,
         Age = agegroup, 
         Month = NA,
         CTBand = "All",
         Data = population,
         Lower = NA,
         Upper = NA) %>% 
  select(Region, Constituency, Subject, Measure, TimePeriod, Year, Month, Sex, Age, 
         CTBand, Data, Lower, Upper) %>% 
  arrange(Year, Region, Constituency)

# save tidy data ---------------------------------------------------------------

saveRDS(pop, "data/tidy_population_data.rds")
rm(list = ls())

cat("Population data prepped", fill = TRUE)

