
# get all data for the current PowerBI constituency dashboard ready


# load -------------------------------------------------------------------------

# use writexl for creating Excels to use with Power 

library(tidyverse)
library(naniar)

socialsecurity <- readRDS("data/tidy_socialsecurity_data.rds")
housing <- readRDS("data/tidy_housing_data.rds")
labourmarket <- readRDS("data/tidy_labourmarket_data.rds")
lifeexpectancy <- readRDS("data/tidy_lifeexpectancy_data.rds")
population <- readRDS("data/tidy_population_data.rds")

socialsecurity %>% 
  mutate(across(c("Data", "Lower", "Upper", "Year"), as.numeric),
         Area_name = case_when(Area_name == "Perthshire South and Kinrossshire" 
                               ~ "Perthshire South and Kinross-shire",
                               TRUE ~ Area_name)) %>% 
  select(-Age, -CTBand, -Lower, -Upper) %>% 
  writexl::write_xlsx("C:/Users/s910140/OneDrive - The Scottish Parliament/Constituency Dashboard/socialsecurity.xlsx")

rbind(housing$house_prices_spc,
            housing$counciltax) %>% 
  mutate(across(c("Data", "Lower", "Upper", "Year"), as.numeric),
         Area_name = case_when(Area_name == "Perthshire South and Kinrossshire" 
                               ~ "Perthshire South and Kinross-shire",
                               TRUE ~ Area_name)) %>% 
  select(-Age, -Sex, -Lower, -Upper, -Year, -Month) %>% 
  writexl::write_xlsx("C:/Users/s910140/OneDrive - The Scottish Parliament/Constituency Dashboard/housing.xlsx")

labourmarket %>%
  mutate(across(c("Data", "Lower", "Upper", "Year"), as.numeric),
         Area_name = case_when(Area_name == "Perthshire South and Kinrossshire" 
                               ~ "Perthshire South and Kinross-shire",
                               TRUE ~ Area_name)) %>% 
  select(-Age, -CTBand) %>% 
  writexl::write_xlsx("C:/Users/s910140/OneDrive - The Scottish Parliament/Constituency Dashboard/labourmarket.xlsx")

lifeexpectancy %>% 
  mutate(across(c("Data", "Lower", "Upper", "Year"), as.numeric),
         Area_name = case_when(Area_name == "Perthshire South and Kinrossshire" 
                               ~ "Perthshire South and Kinross-shire",
                               TRUE ~ Area_name)) %>% 
  select(-Month, -CTBand, -Lower, -Upper) %>% 
  writexl::write_xlsx("C:/Users/s910140/OneDrive - The Scottish Parliament/Constituency Dashboard/lifeexpectancy.xlsx")

population %>% 
  ungroup() %>% 
  mutate(across(c("Data", "Lower", "Upper", "Year"), as.numeric),
         Area_name = case_when(Area_name == "Perthshire South and Kinrossshire" 
                               ~ "Perthshire South and Kinross-shire",
                               TRUE ~ Area_name)) %>% 
  select(-Month, -Year, -CTBand, -Lower, -Upper) %>% 
  writexl::write_xlsx("C:/Users/s910140/OneDrive - The Scottish Parliament/Constituency Dashboard/population.xlsx") 

  

