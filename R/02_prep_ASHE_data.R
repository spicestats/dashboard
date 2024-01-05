# load -------------------------------------------------------------------------

library(tidyverse)

# load backseries (nomis data) and inflators

backseries <- readRDS("data/nomis_ashe_data.rds") %>% 
  filter(geography_name != "Great Britain",
         geography_name != "England and Wales")

countries <- backseries %>% 
  filter(geography_type == "countries") %>% pull(geography_name) %>% unique()

councils <- backseries %>% 
  filter(geography_type != "countries") %>% pull(geography_name) %>% unique()

# new data (spreadsheets) ------------------------------------------------------

## import latest ---------------------------------------------------------------

## get filenames and latest year

files_latest <- list.files("data/ashetable8_latest", full.names = TRUE)

### data -----------------------------------------------------------------------
file_latest_hourly <- files_latest[grepl("Table 8.5a", files_latest)]
file_latest_weekly <- files_latest[grepl("Table 8.1a", files_latest)]
file_latest_annual <- files_latest[grepl("Table 8.7a", files_latest)]

year_latest <- str_sub(str_split_i(file_latest_hourly, " ", -1), 1, 4)

latest_weekly <- lapply(c("All", "Full-Time", "Part-Time"), function(x) {
  readxl::read_xls(path = file_latest_weekly, sheet = x, skip = 4) %>% 
    select(Description, Median) %>% 
    rename(region = Description,
           value = Median) %>% 
    filter(region %in% c(countries, councils)) %>% 
    mutate(year = year_latest,
           employee = x)
}) %>% 
  bind_rows() %>% 
  mutate(pay = "weekly")

latest_hourly <- lapply(c("All", "Full-Time", "Part-Time"), function(x) {
  readxl::read_xls(path = file_latest_hourly, sheet = x, skip = 4) %>% 
    select(Description, Median) %>% 
    rename(region = Description,
           value = Median) %>% 
    filter(region %in% c(countries, councils)) %>% 
    mutate(year = year_latest,
           employee = x)
}) %>% 
  bind_rows() %>% 
  mutate(pay = "hourly")

latest_annual <- lapply(c("All", "Full-Time", "Part-Time"), function(x) {
  readxl::read_xls(path = file_latest_annual, sheet = x, skip = 4) %>% 
    select(Description, Median) %>% 
    rename(region = Description,
           value = Median) %>% 
    filter(region %in% c(countries, councils)) %>% 
    mutate(year = year_latest,
           employee = x)
})  %>% 
  bind_rows() %>% 
  mutate(pay = "annual")

### confidence info (cv) -------------------------------------------------------
file_latest_hourly_cv <- files_latest[grepl("Table 8.5b", files_latest)]
file_latest_weekly_cv <- files_latest[grepl("Table 8.1b", files_latest)]
file_latest_annual_cv <- files_latest[grepl("Table 8.7b", files_latest)]

latest_weekly_cv <- lapply(c("All", "Full-Time", "Part-Time"), function(x) {
  readxl::read_xls(path = file_latest_weekly_cv, sheet = x, skip = 4) %>% 
    select(Description, Median) %>% 
    rename(region = Description,
           cv = Median) %>% 
    filter(region %in% c(countries, councils)) %>% 
    mutate(year = year_latest,
           employee = x)
}) %>% 
  bind_rows() %>% 
  mutate(pay = "weekly")

latest_hourly_cv <- lapply(c("All", "Full-Time", "Part-Time"), function(x) {
  readxl::read_xls(path = file_latest_hourly_cv, sheet = x, skip = 4) %>% 
    select(Description, Median) %>% 
    rename(region = Description,
           cv = Median) %>% 
    filter(region %in% c(countries, councils)) %>% 
    mutate(year = year_latest,
           employee = x)
}) %>% 
  bind_rows() %>% 
  mutate(pay = "hourly")

latest_annual_cv <- lapply(c("All", "Full-Time", "Part-Time"), function(x) {
  readxl::read_xls(path = file_latest_annual_cv, sheet = x, skip = 4) %>% 
    select(Description, Median) %>% 
    rename(region = Description,
           cv = Median) %>% 
    filter(region %in% c(countries, councils)) %>% 
    mutate(year = year_latest,
           employee = x)
})  %>% 
  bind_rows() %>% 
  mutate(pay = "annual")


## import previous -------------------------------------------------------------

## get filenames and previous year

files_previous <- list.files("data/ashetable8_previous", full.names = TRUE, recursive = TRUE)

### data -----------------------------------------------------------------------

file_previous_hourly <- files_previous[grepl("Table 8.5a", files_previous)]
file_previous_weekly <- files_previous[grepl("Table 8.1a", files_previous)]
file_previous_annual <- files_previous[grepl("Table 8.7a", files_previous)]

year_previous <- str_sub(str_split_i(file_previous_hourly, " ", -1), 1, 4)

previous_weekly <- lapply(c("All", "Full-Time", "Part-Time"), function(x) {
  readxl::read_xls(path = file_previous_weekly, sheet = x, skip = 4) %>% 
    select(Description, Median) %>% 
    rename(region = Description,
           value = Median) %>% 
    filter(region %in% c(countries, councils)) %>% 
    mutate(year = year_previous,
           employee = x)
}) %>% 
  bind_rows() %>% 
  mutate(pay = "weekly")

previous_hourly <- lapply(c("All", "Full-Time", "Part-Time"), function(x) {
  readxl::read_xls(path = file_previous_hourly, sheet = x, skip = 4) %>% 
    select(Description, Median) %>% 
    rename(region = Description,
           value = Median) %>% 
    filter(region %in% c(countries, councils)) %>% 
    mutate(year = year_previous,
           employee = x)
}) %>% 
  bind_rows() %>% 
  mutate(pay = "hourly")

previous_annual <- lapply(c("All", "Full-Time", "Part-Time"), function(x) {
  readxl::read_xls(path = file_previous_annual, sheet = x, skip = 4) %>% 
    select(Description, Median) %>% 
    rename(region = Description,
           value = Median) %>% 
    filter(region %in% c(countries, councils)) %>% 
    mutate(year = year_previous,
           employee = x)
})  %>% 
  bind_rows() %>% 
  mutate(pay = "annual")

### cv -------------------------------------------------------------------------

file_previous_hourly_cv <- files_previous[grepl("Table 8.5b", files_previous)]
file_previous_weekly_cv <- files_previous[grepl("Table 8.1b", files_previous)]
file_previous_annual_cv <- files_previous[grepl("Table 8.7b", files_previous)]

previous_weekly_cv <- lapply(c("All", "Full-Time", "Part-Time"), function(x) {
  readxl::read_xls(path = file_previous_weekly_cv, sheet = x, skip = 4) %>% 
    select(Description, Median) %>% 
    rename(region = Description,
           cv = Median) %>% 
    filter(region %in% c(countries, councils)) %>% 
    mutate(year = year_previous,
           employee = x,
           cv = as.character(cv))
}) %>% 
  bind_rows() %>% 
  mutate(pay = "weekly")

previous_hourly_cv <- lapply(c("All", "Full-Time", "Part-Time"), function(x) {
  readxl::read_xls(path = file_previous_hourly_cv, sheet = x, skip = 4) %>% 
    select(Description, Median) %>% 
    rename(region = Description,
           cv = Median) %>% 
    filter(region %in% c(countries, councils)) %>% 
    mutate(year = year_previous,
           employee = x)
}) %>% 
  bind_rows() %>% 
  mutate(pay = "hourly")

previous_annual_cv <- lapply(c("All", "Full-Time", "Part-Time"), function(x) {
  readxl::read_xls(path = file_previous_annual_cv, sheet = x, skip = 4) %>% 
    select(Description, Median) %>% 
    rename(region = Description,
           cv = Median) %>% 
    filter(region %in% c(countries, councils)) %>% 
    mutate(year = year_previous,
           employee = x)
})  %>% 
  bind_rows() %>% 
  mutate(pay = "annual")


# combine ----------------------------------------------------------------------

new_data <- rbind(latest_hourly, latest_weekly, latest_annual, 
             previous_hourly, previous_weekly, previous_annual)
new_cv <- rbind(latest_hourly_cv, latest_weekly_cv, latest_annual_cv, 
             previous_hourly_cv, previous_weekly_cv, previous_annual_cv)

new <- new_data %>% 
  left_join(new_cv, by = join_by(region, year, employee, pay)) %>% 
  mutate(across(c(year, value, cv), as.numeric)) %>% # ignore warning (NAs introduced by coercion)
 arrange(year, region, employee, pay)


# backseries (nomis) -----------------------------------------------------------

nomis <- backseries %>% 
  mutate(# only keep reliable estimates; mark unreliable as missing
    obs_value = case_when(obs_status == "A" ~ obs_value)) %>% 
  select(-pay) %>% 
  rename(year = date,
         region = geography_name,
         employee = sex_name,
         pay = pay_name, 
         value = obs_value) %>% 
  select(year, region, employee, pay, value, measures_name) %>% 
  # remove the years that are available from spreadsheets (potentially more up-to-date)
  filter(year != as.numeric(year_latest),
         year != as.numeric(year_latest) - 1) %>% 
  mutate(pay = case_when(pay == "Weekly pay - gross" ~ "weekly",
                         pay == "Hourly pay - gross" ~ "hourly",
                         pay == "Annual pay - gross" ~ "annual"),
         employee = case_when(employee == "Total" ~ "All",
                              employee == "Full Time Workers" ~ "Full-Time",
                              employee == "Part Time Workers" ~ "Part-Time")) %>% 
  pivot_wider(names_from = measures_name, values_from = value) %>% 
  rename(value = Value,
         cv = Confidence) %>% 
  arrange(year, region, employee, pay) 

# combine all ------------------------------------------------------------------

data <- new %>% 
  rbind(nomis) %>% 
  arrange(year, pay, employee) %>% 
  # format year as date (April)
  mutate(TimePeriod = lubridate::my(paste("Apr", year)),
         Area_name = region,
         Area_type = case_when(region %in% countries ~ "Country",
                               TRUE ~ "Council"),
         Region = NA,
         Subject = "Labour market",
         Measure = case_when(pay == "hourly" & employee == "Full-Time" ~ "Median hourly full-time employee earnings",
                             pay == "weekly" & employee == "Full-Time" ~ "Median weekly full-time employee earnings",
                             pay == "annual" & employee == "Full-Time" ~ "Median annual full-time employee earnings",
                             pay == "hourly" & employee == "Part-Time" ~ "Median hourly part-time employee earnings",
                             pay == "weekly" & employee == "Part-Time" ~ "Median weekly part-time employee earnings",
                             pay == "annual" & employee == "Part-Time" ~ "Median annual part-time employee earnings",
                             pay == "hourly" & employee == "All" ~ "Median hourly employee earnings",
                             pay == "weekly" & employee == "All" ~ "Median weekly employee earnings",
                             pay == "annual" & employee == "All" ~ "Median annual employee earnings"),
         Year = year(TimePeriod),
         Month = month(TimePeriod),
         Sex = "All",
         Age = "All",
         CTBand = "All",
         Data = value,
         
         # calculate 95% confidence interval
         Lower = Data - Data * cv * 1.96 / 100,
         Upper = Data + Data * cv * 1.96 / 100) %>% 
  select(Area_name, Area_type, Region, Subject, Measure, TimePeriod, Year, Month, 
         Sex, Age, CTBand, Data, Lower, Upper) %>% 
  arrange(Year, Month, Region, Area_type, Area_name) 


# save data --------------------------------------------------------------------

saveRDS(data, "data/tidy_earnings_data.rds")

rm(list = ls())

cat("ASHE earnings data prepped", fill = TRUE)


