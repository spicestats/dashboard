# note this is a bit inelegant - maybe refactor;
# main thing is to combine const. codes from lookup and gss file to cover all
# codes (including decommissioned ones)

# functions to convert the S16 codes for constituencies into the constituency
# names; and the names to regions

# You need to have downloaded this file from sharepoint to the data folder:
#   Scottish_Parliamentary_Constituency_to_Region_lookup.xlsx
#   office-spice > documents > projects > statistics > tools > 
#   https://scottish4.sharepoint.com/:x:/r/sites/office-spice/Shared%20Documents/Projects/Statistics/Tools/Scottish_Parliamentary_Constituency_to_Region_lookup.xlsx?d=w593e4e1a23d94f77a73ad910b3f88299&csf=1&web=1&e=5lcSC2

lookup <- readxl::read_excel("data/Scottish_Parliamentary_Constituency_to_Region_lookup.xlsx", 
                             skip = 1) %>% 
  rename(region = 2,
         const_code = 3,
         constituency = 4) %>% 
  select(region, const_code, constituency) %>% 
  mutate(constituency = case_when(constituency == "Perthshire South and Kinross-shire" 
                                  ~ "Perthshire South and Kinrossshire",
                                  TRUE ~ constituency)) %>% 
  arrange(const_code)

# constituency S16 code to constituency name
const_code_to_name <- function(x) {
  
  sapply(x, function(y) {
    lookup %>% 
      filter(tolower(const_code) == tolower(y)) %>% 
      pull(constituency)
  })
}

# constituency name to region
const_name_to_region <- function(x) {
  
  a <- lapply(x, function(y) {
    lookup %>% 
      filter(tolower(constituency) == tolower(y)) %>% 
      pull(region)
  }) 
    
  map_vec(a, ~ifelse(is.null(.x), NA, .x))
}

# GSS area codes to get from S16 codes (which change over time) to constituency 
# names (which don't change as much), downloaded from 
# https://www.gov.scot/publications/small-area-statistics-reference-materials/

gss_codes <- readxl::read_excel("data/Scotland+Register+of+GSS+Codes+September+2023.xlsx",
                                sheet = "S16_SPC") %>% select(InstanceCode, InstanceName) %>% 
  rename(const_code = InstanceCode,
         constituency = InstanceName) %>% 
  mutate(region = const_name_to_region(constituency)) %>% 
  filter(!is.na(region))

lookup <- lookup %>% 
  rbind(gss_codes) %>% 
  distinct()

# constituency S16 code to constituency name
const_code_to_name <- function(x) {
  
  sapply(x, function(y) {
    lookup %>% 
      filter(tolower(const_code) == tolower(y)) %>% 
      pull(constituency)
  })
}

# constituency name to region
const_name_to_region <- function(x) {
  
  a <- lapply(x, function(y) {
    lookup %>% 
      filter(tolower(constituency) == tolower(y)) %>% 
      pull(region)
  }) 
  
  map_vec(a, ~ifelse(is.null(.x), NA, .x))
}

