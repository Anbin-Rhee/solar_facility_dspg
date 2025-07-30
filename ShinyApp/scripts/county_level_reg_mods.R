library(dplyr)
library(fixest)
library(tidyverse)

# Read in data
data <- read_csv("data/county_level_merged_data.csv")

# Prepare and clean data
datax <- data %>% 
  # IMPORTANT: Filter out rows where variables to be logged are not positive
  filter(Price_Per_Acre > 0, CornYield > 0, SoyYield > 0, Population > 0, 
         HousingAge > 0, TotalHousingUnits > 0, VacantUnits > 0) %>%
  mutate(
    Year = factor(Year),
    County = factor(County)
  )

# Remove outliers (this step is optional but good practice)
upper <- quantile(datax$Price_Per_Acre, .99, na.rm = TRUE)
lower <- quantile(datax$Price_Per_Acre, .01, na.rm = TRUE)
datax <- datax[which(datax$Price_Per_Acre <= upper & datax$Price_Per_Acre >= lower),]

# Model 1: Simple model with only fixed effects
county_model_simple <- feols(log(Price_Per_Acre) ~ DiD | County + Year, 
                             cluster = ~County,
                             data = datax)

# Model 2: Full model with all control variables
county_model_full <- feols(log(Price_Per_Acre) ~ DiD + log(CornYield) + log(SoyYield) + 
                             log(Population) + log(HousingAge) + log(TotalHousingUnits) + 
                             log(VacantUnits) | County + Year, 
                           cluster = ~County,
                           data = datax)