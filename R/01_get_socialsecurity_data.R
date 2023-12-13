# get from StatXplore:
# - Attendance Allownace
# - Carer's Allowance
# - Disability Living Allowance


# load -------------------------------------------------------------------------

library(tidyverse)
library(statxplorer)

# set key (available from StatXplore account)
statxplorer::load_api_key("data/API_key.txt")

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
