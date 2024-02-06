
# load -------------------------------------------------------------------------

library(tidyverse)
library(statxplorer)
library(jsonlite)

# set key (available from StatXplore account)
statxplorer::load_api_key("data/API_key.txt")

# check for new data -----------------------------------------------------------
# check if Statxplore has new data and update json files accordingly

# import existing json query
json_old <- jsonlite::fromJSON("data/cilif_query.json")

# restructure some bits - don't remember why but this is required for the amended
# json query to work
json_old$database <- jsonlite::unbox(json_old$database)
json_old$recodes[[1]]$total <- jsonlite::unbox(json_old$recodes[[1]]$total)
json_old$recodes[[2]]$total <- jsonlite::unbox(json_old$recodes[[2]]$total)
json_old$recodes[[3]]$total <- jsonlite::unbox(json_old$recodes[[3]]$total)

# create new json file based on old
json_new <- json_old

## create new row for latest quarter
last_row <- tail(json_new$recodes[[grep("DATE", json_new$recodes)]]$map, 1)[1]
last_yr <- str_split_i(last_row, ":", -1)
new_yr = as.numeric(last_yr) + 1
new_row <- paste0(str_split_i(last_row, last_yr, 1), new_yr)

# add new row
json_new$recodes[[grep("DATE", json_new$recodes)]]$map <- rbind(json_new$recodes[[grep("DATE", json_new$recodes)]]$map, new_row)

# test if new quarterly data is available yet: if this throws up the error
# [...]"RECODE_FIELD_VALUE_NOT_FOUND"[...], data is not yet available
check_error <- try(fetch_table(toJSON(json_new)), silent = TRUE)

# if no error, overwrite json file
if (!inherits(check_error, "try-error")) {
  jsonlite::write_json(json_new, "data/cilif_query.json", pretty = TRUE)
  cat("CiLIF json query updated", fill = TRUE)
} else {
  cat("CiLIF - no updates available", fill = TRUE)
}

# import data ------------------------------------------------------------------
# load the queries from a file - query is easiest created in StatXplore

cilif_data <- fetch_table(filename = "data/cilif_query.json")

# save data --------------------------------------------------------------------

saveRDS(cilif_data, "data/cilif_data.rds")

message <- paste("Child poverty (CiLIF) data downloaded from StatXplore - latest data from",
                 last_yr)

cat(message, fill = TRUE)
