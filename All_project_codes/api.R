# Set the library and install the packages
# install.packages("censusapi")
# install.packages("tidycensus")
library(censusapi)
library(tidycensus) 

library(purrr)
library(dplyr)


# Acquire the API by registering through https://api.census.gov/data/key_signup.html

census_api_key("522bd247dd27b31129de62af04e6958aee5db91d", install = TRUE, overwrite = TRUE) # your key
# Acquire the API by registering through https://api.census.gov/data/key_signup.html
readRenviron("~/.Renviron")
Sys.getenv("CENSUS_API_KEY")
#The main function to retrive the data here are https://cran.r-project.org/web/packages/tidycensus/tidycensus.pdf

#to check the name of the variable
v15 <- load_variables(2015, "acs5", cache = TRUE)
View(v15)

# for example, if I want to know the age
# here is the explanation of the codebook: https://data.census.gov/table/ACSDT5Y2022.B01001

# nc_acs_2015 <- get_acs(geography = "county", 
#                        year = 2015,
#                        variables = c(age = "B01001A_003"), 
#                        state = "NC",
#                        survey = "acs5",
#                        output = "wide")
# 
# View(nc_acs_2015)
## example2 for total housing units
# set the year to analyze
years <- 2010:2023

# load the data by year
va_housing_by_year <- map_dfr(
  years,
  ~ get_acs(
    geography = "county",
    state = "VA",
    variables = "B25001_001",  # total housing units
    year = .x
  ) %>%
    mutate(year = .x)
)

# # check the results
View(va_housing_by_year)
write.csv(va_housing_by_year, "raw_data/va_housing_by_year.csv")
# 
# years <- 2010:2023
# 
# # Loop through years and collect population data
# va_county_pop_all <- map_dfr(years, ~{
#   get_acs(
#     geography = "county", 
#     year = .x,
#     variables = c(Total = "B01003_001"), 
#     state = "VA",
#     survey = "acs5",
#     output = "wide"
#   ) %>%
#     mutate(year = .x)  # Add year column to keep track
# })
# 
# View(va_county_pop_all)
# write.csv(va_county_pop_all, "data/va_county_pop_all.csv", row.names = FALSE)



years <- 2010:2023

housing_status_all <- map_dfr(years, ~{
  get_acs(
    geography = "county",
    state = "VA",
    variables = c(
      total = "B25002_001",
      occupied = "B25002_002",
      vacant = "B25002_003"
    ),
    year = .x,
    survey = "acs5",
    output = "wide"
  ) %>%
    mutate(Year = .x)
})

View(housing_status_all)
write.csv(housing_status_all, "raw_data/housing_status_all.csv", row.names = FALSE)


midpoints <- c(
  "B25034_002" = 2017,
  "B25034_003" = 2011,
  "B25034_004" = 2006,
  "B25034_005" = 2000,
  "B25034_006" = 1995,
  "B25034_007" = 1985,
  "B25034_008" = 1975,
  "B25034_009" = 1965,
  "B25034_010" = 1955,
  "B25034_011" = 1945,
  "B25034_012" = 1939
)

# Loop through years 2010 to 2023
years <- 2010:2023

housing_age_all <- map_dfr(years, ~{
  year_i <- .x
  
  # Get ACS 5-year data for housing year built
  housing_age <- get_acs(
    geography = "county",
    state = "VA",
    table = "B25034",
    year = year_i,
    survey = "acs5"
  )
  
  # Filter and calculate weighted average built year
  housing_age_filtered <- housing_age %>%
    filter(variable %in% names(midpoints)) %>%
    mutate(
      mid_year = midpoints[variable],
      weighted_year = estimate * mid_year
    ) %>%
    group_by(GEOID, NAME) %>%
    summarize(
      avg_year_built = sum(weighted_year, na.rm = TRUE) / sum(estimate, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      avg_age = year_i - avg_year_built,
      Year = year_i
    )
})

# Clean the County name column
housing_age_all <- housing_age_all %>%
  rename(County = NAME) %>%
  mutate(
    County = str_to_title(County),
    County = str_remove_all(County, regex("County", ignore_case = TRUE)),
    County = str_remove_all(County, regex(", Virginia", ignore_case = TRUE)),
    County = str_trim(County)
  )

View(housing_age_all)
write_csv(housing_age_all, "clean_data/va_avg_housing_age_all_years.csv")



