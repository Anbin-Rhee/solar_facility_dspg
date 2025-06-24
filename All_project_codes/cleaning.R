# MERGING the DATASETS
library(tidyverse)
library(readxl)
library(stringr)


# Cleaning Transaction Data -----------------------------------------------
#Changed the column name from 'consid' to 'LandPrice' in Transadata:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAAAbElEQVR4Xs2RQQrAMAgEfZgf7W9LAguybljJpR3wEse5JOL3ZObDb4x1loDhHbBOFU6i2Ddnw2KNiXcdAXygJlwE8OFVBHDgKrLgSInN4WMe9iXiqIVsTMjH7z/GhNTEibOxQswcYIWYOR/zAjBJfiXh3jZ6AAAAAElFTkSuQmCCctions dataset
raw_data <- read_csv("data/raw_data_file.csv")

raw_data <- raw_data %>%
  rename(Year = year)
View(raw_data)


write_csv(raw_data, "clean_data/LandPrice.csv")

# Cleaning New Corn Data --------------------------------------------------


#check if New_Corn_Data has columns Year and County and rename those columns
new_corn_data <- read_csv("raw_data/New_Corn_Data.csv")

new_corn_data <- new_corn_data %>%
  rename(Year = year, County = county_name )


#Standardize the county name: Capitalize the first letter, remove the word "County"
new_corn_data <- new_corn_data %>%
  mutate(
    County = str_to_title(County),                     # Title case (First letter capital)
    County = str_remove(County, regex(" County$", ignore_case = TRUE))  # Remove 'County' at end
  )

View(new_corn_data)

write_csv(new_corn_data, "clean_data/new_corn_data.csv")



# Cleaning housing_Status Data ---------------------------------------------------
housing_status <- read_csv("raw_data/housing_status_all.csv")
housing_status <- housing_status %>%
  mutate(
    County = str_to_title(County),
    County = str_remove_all(County, regex("County", ignore_case = TRUE)),
    County = str_remove_all(County, regex(", Virginia", ignore_case = TRUE)),
    County = str_trim(County)
  )

View(housing_status)
write_csv(housing_status, "clean_data/housing_status.csv") 



# Cleaning Soy Data -------------------------------------------------------

new_soy_data <- read_csv("raw_data/New_Soy_Data.csv")
colnames(new_soy_data)


new_soy_data <- new_soy_data %>%
  mutate(
    County = str_to_title(County),  # Make it like "Accomack County"
    County = str_remove_all(County, regex("County", ignore_case = TRUE)),
    County = str_trim(County)
  )
    
View(new_soy_data)
write_csv(new_soy_data, "clean_data/new_soy_data.csv")
  
  
  

# Cleaning Solar Facility -------------------------------------------------

solar_fac <- read_excel("raw_data/Solar_facility_VA - Copy.xlsx")
View(solar_fac)
solar_fac <- solar_fac %>%
  rename(County = p_county, Year = p_year)
View(solar_fac)
write_csv(solar_fac, "clean_data/ solar_fac.csv")



# Cleaning VA population ---------------------------------------------
va_population <- read_csv("raw_data/va_county_pop_all.csv")
View(va_population)


va_population <- va_population %>%

mutate(
  County = str_to_title(County),
  County = str_remove_all(County, regex("County", ignore_case = TRUE)),
  County = str_remove_all(County, regex(", Virginia", ignore_case = TRUE)),
  County = str_trim(County)
)

write_csv(va_population, "clean_data/va_population.csv")


# Cleaning housing by year ------------------------------------------------

va_housing_year <- read_csv("raw_data/va_housing_by_year.csv") 
View(va_housing_year)

va_housing_year <- va_housing_year %>%
  mutate(
    County = str_to_title(County),
    County = str_remove_all(County, regex("County", ignore_case = TRUE)),
    County = str_remove_all(County, regex(", Virginia", ignore_case = TRUE)),
    County = str_trim(County)
  )


write_csv(va_housing_year, "clean_data/va_housing_year.csv")




# Cleaning VA housing status ----------------------------------------------

va_housing_status <- read_csv("raw_data/va_housing_status.csv")
View(va_housing_status)








