# load -------------------------------------------------------------------------

library(tidyverse)

# load backseries (nomis data) and inflators

backseries <- readRDS("data/nomis_data.rds")
inflators <- readRDS("data/inflators.rds")

regions <- unique(backseries$geography_name)

# new data (spreadsheets) ------------------------------------------------------

## import latest ---------------------------------------------------------------

## get filenames and latest year

files_latest <- list.files("data/ashetable5_latest", full.names = TRUE)
file_latest_hourly <- files_latest[grepl("Table 5.5a", files_latest)]
file_latest_weekly <- files_latest[grepl("Table 5.1a", files_latest)]
file_latest_annual <- files_latest[grepl("Table 5.7a", files_latest)]
year_latest <- str_sub(str_split_i(file_latest_hourly, " ", -1), 1, 4)

latest_weekly <- lapply(c("All", "Full-Time", "Part-Time"), function(x) {
  readxl::read_xls(path = file_latest_weekly, sheet = x, skip = 4) %>% 
    select(Description, Median) %>% 
    rename(region = Description,
           value = Median) %>% 
    filter(region %in% regions) %>% 
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
    filter(region %in% regions) %>% 
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
    filter(region %in% regions) %>% 
    mutate(year = year_latest,
           employee = x)
})  %>% 
  bind_rows() %>% 
  mutate(pay = "annual")


## import previous -------------------------------------------------------------

## get filenames and previous year

files_previous <- list.files("data/ashetable5_previous", full.names = TRUE, recursive = TRUE)
file_previous_hourly <- files_previous[grepl("Table 5.5a", files_previous)]
file_previous_weekly <- files_previous[grepl("Table 5.1a", files_previous)]
file_previous_annual <- files_previous[grepl("Table 5.7a", files_previous)]
year_previous <- str_sub(str_split_i(file_previous_hourly, " ", -1), 1, 4)

previous_weekly <- lapply(c("All", "Full-Time", "Part-Time"), function(x) {
  readxl::read_xls(path = file_previous_weekly, sheet = x, skip = 4) %>% 
    select(Description, Median) %>% 
    rename(region = Description,
           value = Median) %>% 
    filter(region %in% regions) %>% 
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
    filter(region %in% regions) %>% 
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
    filter(region %in% regions) %>% 
    mutate(year = year_previous,
           employee = x)
})  %>% 
  bind_rows() %>% 
  mutate(pay = "annual")

# combine ----------------------------------------------------------------------

new <- rbind(latest_hourly, latest_weekly, latest_annual, previous_hourly,
              previous_weekly, previous_annual) %>% 
  mutate(year = as.numeric(year),
         value = as.numeric(value))


# backseries (nomis) -----------------------------------------------------------

nomis <- backseries %>% 
  select(date, geography_name, sex_name, pay_name, obs_value) %>% 
  rename(year = 1,
         region = 2,
         employee = 3,
         pay = 4, 
         value = 5) %>% 
  # remove provisional data as we have revised data from spreadsheets
  filter(year != max(year)) %>% 
  mutate(pay = case_when(pay == "Weekly pay - gross" ~ "weekly",
                         pay == "Hourly pay - gross" ~ "hourly",
                         pay == "Annual pay - gross" ~ "annual"),
         employee = case_when(employee == "Total" ~ "All",
                              employee == "Full Time Workers" ~ "Full-Time",
                              employee == "Part Time Workers" ~ "Part-Time"))

# combine all ------------------------------------------------------------------

data <- new %>% 
  rbind(nomis) %>% 
  left_join(inflators, by = "year") %>% 
  arrange(year, pay, employee)


# save data --------------------------------------------------------------------

saveRDS(data, "data/tidy_earnings.rds")

rm(list = ls())

