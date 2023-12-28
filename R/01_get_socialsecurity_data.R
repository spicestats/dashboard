# get from StatXplore:
# - Attendance Allownace
# - Carer's Allowance
# - Disability Living Allowance


# load -------------------------------------------------------------------------

library(tidyverse)
library(statxplorer)
library(jsonlite)

# set key (available from StatXplore account)
statxplorer::load_api_key("data/API_key.txt")

# check for new data -----------------------------------------------------------
# check if Statxplore has new data and update json files accordingly

for (benefit in c("AA", "CA", "DLA")) {
  
  # import existing json file
  json_old <- jsonlite::fromJSON(paste0("data/", benefit, "_query.json"))
  
  # restructure some bits
  json_old$database <- unbox(json_old$database)
  json_old$recodes[[1]]$total <- unbox(json_old$recodes[[1]]$total)
  json_old$recodes[[2]]$total <- unbox(json_old$recodes[[2]]$total)
  json_old$recodes[[3]]$total <- unbox(json_old$recodes[[3]]$total)
  
  # check it works (for debugging)
  # data_old <- fetch_table(toJSON(json_old))
  
  # create new json file based on old
  json_new <- json_old
  
  ## create new row for latest quarter
  last_row <- tail(json_new$recodes[[grep("DATE", json_new$recodes)]]$map, 1)[1]
  last_qtr <- str_split_i(last_row, ":", -1)
  last_yr <- as.numeric(str_sub(last_qtr, 1, 4))
  last_month <- str_sub(last_qtr, 5, 6)
  new_yr = ifelse(as.numeric(last_month) >= 11, last_yr + 1, last_yr)
  new_month = case_when(last_month == "05" ~ "08",
                        last_month == "08" ~ "11",
                        last_month == "11" ~ "02",
                        last_month == "02" ~ "05")
  new_row <- paste0(str_split_i(last_row, "20", 1), new_yr, new_month)
  
  # add new row
  json_new$recodes[[grep("DATE", json_new$recodes)]]$map <- rbind(json_new$recodes[[grep("DATE", json_new$recodes)]]$map, new_row)
  
  # test if new quarterly data is available yet: if this throws up the error
  # [...]"RECODE_FIELD_VALUE_NOT_FOUND"[...], data is not yet available
  check_error <- try(fetch_table(toJSON(json_new)), silent = TRUE)
  
  # if no error, overwrite json file
  if (!inherits(check_error, "try-error")) {
    write_json(json_new, paste0("data/", benefit, "_query.json"), pretty = TRUE)
    cat(benefit, "json query updated", fill = TRUE)
  } else {
    cat(benefit, "- no updates available", fill = TRUE)
  }
  
}

# import data ------------------------------------------------------------------
# load the queries from a file - query is easiest created in StatXplore

AA_data <- fetch_table(filename = "data/AA_query.json")
CA_data <- fetch_table(filename = "data/CA_query.json")
DLA_data <- fetch_table(filename = "data/DLA_query.json")

# save data --------------------------------------------------------------------

saveRDS(list(AA = AA_data, CA= CA_data, DLA = DLA_data),
        "data/social_security_data.rds")

message1 <- paste("Social security data downloaded from StatXplore - latest AA data from",
                  tail(AA_data$dfs[[1]]$Quarter, 1))
message2 <- paste("Social security data downloaded from StatXplore - latest CA data from",
                  tail(CA_data$dfs[[1]]$Quarter, 1))
message3 <- paste("Social security data downloaded from StatXplore - latest DLA data from",
                  tail(DLA_data$dfs[[1]]$Quarter, 1))

cat(message1, message2, message3, fill = TRUE)
