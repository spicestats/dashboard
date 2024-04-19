# load -------------------------------------------------------------------------

library(tidyverse)

source("R/functions/f_get_region.R")

cilif_data <- readRDS("data/cilif_data.rds")
population <- readRDS("data/tidy_population_data.rds")

# note that there is currently (Feb 2024) no 2022 population data available for 
# Scotland's DZs or SPCs (Scotland-level and council-level only) -> use 2021 
# population data (for now)

# child population -------------------------------------------------------------
# data goes up to 2021 only

child_pop <- population %>% 
  ungroup() %>% 
  filter(Sex == "All",
         Age %in% c("0 to 4", "5 to 10", "11 to 15")) %>% 
  mutate(TimePeriod = paste0(Year, "/", str_sub(as.numeric(str_sub(Year, 3, 4)) + 101, 2, 3)),
         Pop = Data,
         Age = case_when(Age == "0 to 4" ~ "0-4",
                         Age == "5 to 10" ~ "5-10",
                         Age == "11 to 15" ~ "11-15")) %>% 
  select(Area_name, TimePeriod, Pop, Age) 

child_pop_Scotland <- child_pop %>% 
  group_by(TimePeriod, Age) %>% 
  summarise(Area_name = "Scotland",
            Pop = sum(Pop))

# add another table with 2021 data and call this 2022 data (=DWP methodology)

pop22 <- rbind(child_pop, child_pop_Scotland) %>% 
  filter(TimePeriod == "2021/22") %>% 
  mutate(TimePeriod = "2022/23")


# tidy CiLIF data --------------------------------------------------------------

cilif <- cilif_data$dfs[[1]] %>% 
  rename(TimePeriod = Year,
         Age = 'Age of Child (years and bands)',
         Data = 'Relative Low Income') %>% 
  mutate(Area_name = dz_code_to_const(DZ),
         Area_name = case_when(DZ == "Total"~ "Scotland", 
                               Area_name == "Perthshire South and Kinross-shire" ~ "Perthshire South and Kinrossshire",
                               TRUE ~ Area_name),
         Area_type = ifelse(Area_name == "Scotland", "Country", "SP Constituency")) %>% 
  summarise(Data = sum(Data), .by = c("TimePeriod", "Area_type", "Area_name", "Age")) %>% 
  left_join(rbind(child_pop, child_pop_Scotland, pop22), by = c("Area_name", "TimePeriod", "Age")) %>% 
  mutate(Region = const_name_to_region(Area_name),
         Age = ifelse(Age == "Total", "All", Age),
         Age = factor(Age, levels = c("0-4", "5-10", "11-15", "16-19", "All", "Unknown or missing"), ordered = TRUE),
         Measure = 'Children in relative poverty',
         Subject = "Poverty",
         Year = TimePeriod,
         Month = NA,
         Sex = "All",
         CTBand = "All",
         Lower = NA,
         Upper = NA,
         Measure = "Children in low income families") %>% 
  select(Area_name, Area_type, Region, Subject, Measure, TimePeriod, Year, Month, 
         Sex, Age, CTBand, Data, Pop, Lower, Upper) %>% 
  arrange(Year, Region, Area_type, Area_name) %>% 
  filter(!(Age == "Unknown or missing" & Data == 0))

cilif_number <- cilif %>% select(-Pop)

cilif_rate_age <- cilif %>% 
  filter(Age %in% c("0-4", "5-10", "11-15")) %>% 
  group_by(TimePeriod, Area_name, Age) %>% 
  mutate(Data = sum(Data)/sum(Pop)) %>% 
  mutate(Measure = "Child poverty rate by age") %>% 
  select(-Pop)

cilif_rate <- cilif %>% 
  filter(Age %in% c("0-4", "5-10", "11-15")) %>% 
  group_by(TimePeriod, Area_name) %>% 
  mutate(Data = sum(Data)/sum(Pop),
         Age = "0-15",
         Measure = "Child poverty rate (0-15)") %>% 
  slice_head(n = 1) %>% 
  select(-Pop)

# save all ---------------------------------------------------------------------

saveRDS(rbind(cilif_number, cilif_rate, cilif_rate_age), "data/tidy_cilif_data.rds")

rm(list = ls())

cat("Poverty data prepped", fill = TRUE)

