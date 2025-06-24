library(tidycensus)
library(dplyr)
library(stringr)
library(readr)
library(lubridate)
#install.packages("stargazer")
library(stargazer)

#Creating the 2010- 2023 Grid
va_counties <- get_acs(
  geography = "county",
  variables = "B01003_001",  # total population
  state = "VA",
  year = 2020,
  survey = "acs5"
) %>%
  select(GEOID, NAME) %>%
  mutate(
    County = str_to_title(NAME),
    County = str_remove_all(County, regex("County", ignore_case = TRUE)),
    County = str_remove_all(County, regex(", Virginia", ignore_case = TRUE)),
    County = str_trim(County)
  ) %>%
  select(County) %>%
  distinct()

years <- 2010:2023

county_year_grid <- expand.grid(
  County = va_counties$County,
  Year = years
) %>%
  arrange(County, Year)

View(county_year_grid)


# Adding Land Transactions to the grid
land_price_summary <- read_csv("clean_data/LandPrice.csv")
colnames(land_price_summary)


merged_data <- county_year_grid
merged_data <- merged_data %>%
  left_join(land_price_summary %>% select(County, Year, Price_Per_Acre),
            by = c("County", "Year"))
View(merged_data)

#Merging Corn Yield to the grid
#_____________________________________________________________________________
new_corn_data <- read_csv("clean_data/new_corn_data.csv")
new_corn_data <- new_corn_data %>%
  rename(CornYield = Value)


merged_data <- merged_data %>%
  left_join(new_corn_data %>% select(County, Year, CornYield), 
            by = c("County", "Year"))
View(merged_data)


#Merging SOy Yield data to the grid
#_______________________________________________________________________________
new_soy_data <- read_csv("clean_data/new_soy_data.csv")
new_soy_data <- new_soy_data %>%
  rename(SoyYield = Value)
merged_data <- merged_data %>%
  left_join(new_soy_data %>% select(County, Year, SoyYield),
            by = c("County", "Year"))
summary(merged_data$SoyYield)

View(merged_data)


#Merging house age to the grid
#_______________________________________________________________________________
housing_age_all <- read_csv("clean_data/va_avg_housing_age_all_years.csv")
colnames(housing_age_all)
housing_age_all <- housing_age_all %>%
  rename(HousingAge = avg_age)
merged_data <- merged_data %>%
  left_join(housing_age_all %>% select(County, Year, HousingAge),
            by = c("County", "Year"))
View(merged_data)


#Merging population data to the grid
#________________________________________________________________________________
va_pop <- read_csv("clean_data/va_population.csv")
colnames(va_pop)
va_pop <- va_pop %>%
  rename(Population = TotalE) 
merged_data <- merged_data %>%
  left_join(va_pop %>% select(County, Year, Population),
            by = c("County", "Year"))
View(merged_data)


#Merging the hosuing status data to the grid
#________________________________________________________________________________

housing_status <- read_csv("clean_data/housing_status.csv")
colnames(housing_status)
housing_status <- housing_status %>%
  rename(
    TotalHousingUnits = totalE,
    OccupiedUnits = occupiedE,
    VacantUnits = vacantE
  )
merged_data <- merged_data %>%
  left_join(housing_status %>% select(County, Year, TotalHousingUnits, OccupiedUnits, VacantUnits),
            by = c("County", "Year"))
View(merged_data)


#________________________________________________________________________________
solar <- read_csv("clean_data/ solar_fac.csv")

treated_counties <- solar %>%
  mutate(
    County = str_to_title(County),
    County = str_remove_all(County, regex("County", ignore_case = TRUE)),
    County = str_trim(County)
  ) %>%
  group_by(County) %>%
  summarize(SF_Year = min(Year, na.rm = TRUE)) %>% #the first year the county had solar facility
  ungroup()

merged_data <- merged_data %>%
  left_join(treated_counties, by = "County")

View(merged_data)


merged_data <- merged_data %>%
  mutate(
    Treated = if_else(!is.na(SF_Year), 1, 0),
    Post = if_else(!is.na(SF_Year) & Year >= SF_Year, 1, 0),
    DiD = Treated * Post
  )

table(merged_data$Treated, merged_data$Post)
table(merged_data$DiD)
View(merged_data)


# merged_data %>%
#   count(County, Year) %>%
#   arrange(desc(n)) %>%
#   head(10)


View(merged_data)



cleaned_model_data <- merged_data %>%
  filter(!is.na(Price_Per_Acre),
         Price_Per_Acre > 0,
         !is.na(DiD),
         !is.na(Population),
         Population > 0,
         !is.na(CornYield),
         CornYield > 0,
         !is.na(SoyYield),
         SoyYield > 0,
         !is.na(HousingAge),
         HousingAge > 0,
         !is.na(TotalHousingUnits),
         TotalHousingUnits > 0)

model1 <- lm(log(Price_Per_Acre) ~ DiD + log(Population) + log(CornYield) + log(SoyYield) + log(HousingAge) + log(TotalHousingUnits ) + factor(County) + factor(Year),
            data = cleaned_model_data)
summary(model1) 

model2 <- lm(log(Price_Per_Acre) ~ DiD + log(Population) + log(CornYield) + log(SoyYield) + log(HousingAge) + log(TotalHousingUnits ),
             data = cleaned_model_data)
summary(model2)

model3 <- lm(log(Price_Per_Acre) ~ DiD + factor(County) + factor(Year), data = cleaned_model_data)
#summary(model)

stargazer(model1, model2, model3,
          type = 'text',
          out = "regression_output.txt",
          omit = c("County", "Year"), p.auto = TRUE)

colnames(cleaned_model_data)
model_vacancy <- lm(log(VacantUnits) ~ DiD + factor(County) + factor(Year), data = cleaned_model_data)
summary(model_vacancy)
# model_results <- read_csv("model_results.csv")

model_vacancy_2 <- lm(log(VacantUnits) ~ DiD, data = cleaned_model_data)
stargazer(model_vacancy, model_vacancy_2, type = "text", out = "vacancy_model_output.txt",
          omit = c("County", "Year"), p.auto = TRUE)
# View(model_results)