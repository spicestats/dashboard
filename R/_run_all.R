
# 01 download data -------------------------------------------------------------

source("R/01_get_gss_codes.R")
source("R/01_get_ASHE_data.R")
source("R/01_get_housing_data.R")
source("R/01_get_inflation_data.R")
source("R/01_get_labourmarket_data.R")
source("R/01_get_lifeexpectancy_data.R")
source("R/01_get_population_data.R")
source("R/01_get_socialsecurity_data.R")

# 02 prep data -----------------------------------------------------------------

source("R/02_prep_ASHE_data.R")
source("R/02_prep_housing_data.R")
source("R/02_prep_labourmarket_data.R")
source("R/02_prep_lifeexpectancy_data.R")
source("R/02_prep_population_data.R")
source("R/02_prep_socialsecurity_data.R")

# 03 spreadsheet for powerBI ---------------------------------------------------

source("R/03_spreadsheet_powerbi.R")

# 03 present data --------------------------------------------------------------

source("R/03_charts_earnings.R")
source("R/03_charts_housing.R")
source("R/03_charts_labourmarket.R")

# 04 create website ------------------------------------------------------------

source("R/04_website.R")


