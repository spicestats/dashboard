# note this is a bit inelegant - maybe refactor;
# main thing is to combine const. codes from lookup and gss file to cover all
# codes (including decommissioned ones)

# functions to convert the S16 codes for constituencies into the constituency
# names; and the names to regions


lookup <- readxl::read_excel("data/region_lookup.xlsx", skip = 1) %>% 
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

# GSS area codes

gss_codes <- readxl::read_excel("data/gss_codes.xlsx",
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

