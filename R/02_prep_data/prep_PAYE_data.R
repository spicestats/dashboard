# TO DO ----

#- check latest spreadsheets; somethings going wrong, maybe columns have moved


# Note that PAYE local data is available on LAU1 (41), and NUTS3-level (23), but 
# not on any sensible geographic (SPR, SPC or council) level

# load -------------------------------------------------------------------------

library(tidyverse)
source("R/functions/f_import_PAYE.R")

# Updated monthly

# 7. Employees by region (NUTS1)
# 8. Median pay by region (NUTS1)

# The sheets below get updated quarterly; import will return "A tibble: 0 x 0"

# 19. Employees by region (LA)
# 20. Median pay by region (LA)
# 32. Employees (NUTS1*age)
# 33. Median pay (NUTS1*age)
# 36. Employees(NUTS1*sector)
# 37. Median pay (NUTS1*sector)

sheet_n <- c(7, 8, 19, 20, 32, 33, 36, 37)
sheet_names <- c("7. Employees (NUTS1)",
                 "8. Median pay (NUTS1)",
                 "19. Employees (LA)",
                 "20. Median pay (LA)",
                 "32. Employees (NUTS1Age)", 
                 "33. Median pay (NUTS1Age)", 
                 "36. Employees (NUTS1Sector)", 
                 "37. Median pay (NUTS1Sector)")

# import spreadsheets
data <- lapply(sheet_names, function(x) {f_import_PAYE(1, x)})
names(data) <- paste0("sheet", sheet_n)

# those that aren't populated, import a previous version of the spreadsheet
for (i in 1:length(data)) {
  if (length(data[[i]]) < 3) {
    data[[i]] <- f_import_PAYE(2, sheet_names[i])
  }
}

for (i in 1:length(data)) {
  if (length(data[[i]]) < 3) {
    data[[i]] <- f_import_PAYE(3, sheet_names[i])
  }
}

for (i in 1:length(data)) {
  if (length(data[[i]]) < 3) {
    data[[i]] <- f_import_PAYE(4, sheet_names[i])
  }
}

# tidy employees data ----------------------------------------------------------

employees_region <- data$sheet7 %>% 
  mutate(Date = my(Date)) %>% 
  pivot_longer(cols = names(data$sheet7)[2:ncol(data$sheet7)],
               names_to = "UK_Region",
               values_to = "Data") %>% 
  mutate(SIC = "All",
         Age = "All",
         UK_Region = ifelse(UK_Region == "UK", "All", UK_Region),
         LAU = NA)


var_names <- names(data$sheet19)
country <- str_sub(var_names, 1, 1)

names(data$sheet19) <- paste0(country, "_", unlist(data$sheet19[1, ]))
names(data$sheet19)[1] <- "Date"

employees_LAU <- data$sheet19 %>% 
  filter(Date != "Date") %>% 
  mutate(Date = my(Date)) %>% 
  pivot_longer(cols = names(data$sheet19)[2:ncol(data$sheet19)],
               names_to = "LAU",
               values_to = "Data") %>% 
  filter(!grepl("E_", LAU),
         !grepl("W_", LAU),
         !grepl("N_", LAU),
         LAU != "._UK") %>% 
  mutate(SIC = "All",
         Age = "All",
         UK_Region = "Scotland",
         LAU = str_split_i(LAU, "_", 2))

employees_sector <- data$sheet36 %>% 
  mutate(Date = my(Date)) %>% 
  pivot_longer(cols = names(data$sheet36)[2:ncol(data$sheet36)],
               names_to = "region_sector",
               values_to = "Data") %>% 
  mutate(UK_Region = str_split_i(region_sector, ":", 1),
         SIC = str_split_i(region_sector, ":", 2),
         Age = "All",
         LAU = NA) %>% 
  filter(UK_Region == "Scotland") %>% 
  select(-region_sector)

employees_age <- data$sheet32 %>% 
  mutate(Date = my(Date)) %>% 
  pivot_longer(cols = names(data$sheet32)[2:ncol(data$sheet32)],
               names_to = "region_age",
               values_to = "Data") %>% 
  mutate(UK_Region = str_split_i(region_age, ":", 1),
         Age = str_split_i(region_age, ":", 2),
         SIC = "All", 
         LAU = NA) %>% 
  filter(UK_Region == "Scotland") %>% 
  select(-region_age)

employees <- rbind(employees_region, employees_LAU, employees_sector,
                   employees_age)  %>% 
  filter(!(UK_Region == "All" & is.na(LAU))) %>% 
  mutate(Area_name = case_when(is.na(LAU) ~ UK_Region,
                               !is.na(LAU) ~ LAU),
         Area_type = case_when(is.na(LAU) ~ "UK Region",
                               !is.na(LAU) ~ "LAU1"), 
         Region = NA, 
         Subject = "Labour market", 
         Measure = "Employees", 
         TimePeriod = Date, 
         Year = year(Date), 
         Month = month(Date), 
         Sex = NA, 
         CTBand = NA, 
         Data = as.numeric(Data), 
         Lower = NA, 
         Upper = NA) %>% 
  
  select(Area_name, Area_type, Region, Subject, Measure, TimePeriod, Year, Month, 
         Sex, Age, CTBand, Data, Lower, Upper) %>% 
  arrange(Year, Region, Area_type, Area_name)

# tidy pay data ----------------------------------------------------------------

pay_region <- data$sheet8 %>% 
  mutate(Date = my(Date)) %>% 
  pivot_longer(cols = names(data$sheet8)[2:ncol(data$sheet8)],
               names_to = "UK_Region",
               values_to = "Data") %>% 
  mutate(SIC = "All",
         Age = "All",
         UK_Region = ifelse(UK_Region == "UK", "All", UK_Region),
         LAU = NA)

var_names <- names(data$sheet20)
country <- str_sub(var_names, 1, 1)

names(data$sheet20) <- paste0(country, "_", unlist(data$sheet20[1, ]))
names(data$sheet20)[1] <- "Date"

pay_LAU <- data$sheet20 %>% 
  filter(Date != "Date") %>% 
  mutate(Date = my(Date)) %>% 
  pivot_longer(cols = names(data$sheet20)[2:ncol(data$sheet20)],
               names_to = "LAU",
               values_to = "Data") %>% 
  filter(!grepl("E_", LAU),
         !grepl("W_", LAU),
         !grepl("N_", LAU),
         LAU != "._UK") %>% 
  mutate(SIC = "All",
         Age = "All",
         UK_Region = "Scotland",
         LAU = str_split_i(LAU, "_", 2))

pay_sector <- data$sheet37 %>% 
  mutate(Date = my(Date)) %>% 
  pivot_longer(cols = names(data$sheet37)[2:ncol(data$sheet37)],
               names_to = "region_sector",
               values_to = "Data") %>% 
  mutate(UK_Region = str_split_i(region_sector, ":", 1),
         SIC = str_split_i(region_sector, ":", 2),
         Age = "All",
         LAU = NA) %>% 
  filter(UK_Region == "Scotland") %>% 
  select(-region_sector)

pay_age <- data$sheet33 %>% 
  mutate(Date = my(Date)) %>% 
  pivot_longer(cols = names(data$sheet33)[2:ncol(data$sheet33)],
               names_to = "region_age",
               values_to = "Data") %>% 
  mutate(UK_Region = str_split_i(region_age, ":", 1),
         Age = str_split_i(region_age, ":", 2),
         SIC = "All", 
         LAU = NA) %>% 
  filter(UK_Region == "Scotland") %>% 
  select(-region_age)

pay <- rbind(pay_region, pay_LAU, pay_sector, pay_age) %>% 
  filter(!(UK_Region == "All" & is.na(LAU))) %>% 
  mutate(Area_name = case_when(is.na(LAU) ~ UK_Region,
                               !is.na(LAU) ~ LAU),
         Area_type = case_when(is.na(LAU) ~ "UK Region",
                               !is.na(LAU) ~ "LAU1"), 
         Region = NA, 
         Subject = "Labour market", 
         Measure = "Earnings", 
         TimePeriod = Date, 
         Year = year(Date), 
         Month = month(Date), 
         Sex = NA, 
         CTBand = NA, 
         Data = as.numeric(Data), 
         Lower = NA, 
         Upper = NA) %>% 
  
  select(Area_name, Area_type, Region, Subject, Measure, TimePeriod, Year, Month, 
         Sex, Age, CTBand, Data, Lower, Upper) %>% 
  arrange(Year, Region, Area_type, Area_name)

saveRDS(list(paye = pay,
             employees = employees), "data/tidy_PAYE_data.rds")

rm(list = ls())
