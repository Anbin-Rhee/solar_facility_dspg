# ===================================================================
# CLEANED & OPTIMIZED VERSION OF global.R
# ===================================================================

# 1. LOAD LIBRARIES
library(shiny)
library(leaflet) 
library(shinyjs)
library(gt)
library(fixest)
library(modelsummary)
library(tidyverse)
library(bslib)
library(sf)
library(tigris)

# Static resource path
addResourcePath("myimages", file.path(getwd(), "www"))

# 2. GLOBAL CONSTANTS
TARGET_CRS <- 4326

# 3. LOAD RAW DATA
final_data <- readRDS("data/final_parcel_data.rds")
transmission_lines_raw <- st_read("data/Transmission_Lines/Transmission_Lines.shp")
solar_data_raw <- read_csv("data/solar_facility.csv")
va_counties_raw <- counties(state = "VA", cb = TRUE)
county_level_data_raw <- read_csv("data/county_level_merged_data.csv")
water_features_raw <- read_csv("data/virginia_water_features.csv")
VA_roads_raw <- st_read("data/VA_roads/tl_2019_51_prisecroads.shp")
VA_cities_raw <- st_read("data/VA_Cities/VA_Cities.shp")

# 4. PROCESS DATA

# --- Solar Facility Map Data (for leaflet popups)
map_data <- solar_data_raw %>%
  select(
    Facility_Name = p_name,
    County = County,
    Latitude = ylat,
    Longitude = xlong,
    Capacity_MW = p_cap_ac,
    Commission_Year = Year
  ) %>%
  drop_na(Latitude, Longitude)

# --- County shapefile and join
va_counties <- va_counties_raw %>%
  st_transform(crs = TARGET_CRS) %>%
  mutate(county_clean = str_to_title(NAME))

county_level_data <- county_level_data_raw %>%
  mutate(
    across(c(Price_Per_Acre, CornYield, SoyYield, HousingAge, Population, VacantUnits), as.numeric),
    county_clean = str_to_title(gsub(" County", "", County))
  )

county_level_sf <- left_join(va_counties, county_level_data, by = "county_clean")
va_state_border <- st_union(va_counties)

county_year_summary <- county_level_data_raw %>%
  group_by(County, Year) %>%
  summarise(
    Price_Per_Acre = mean(Price_Per_Acre, na.rm = TRUE),
    CornYield = mean(CornYield, na.rm = TRUE),
    SoyYield = mean(SoyYield, na.rm = TRUE),
    HousingAge = mean(HousingAge, na.rm = TRUE),
    Population = mean(Population, na.rm = TRUE),
    TotalHousingUnits = mean(TotalHousingUnits, na.rm = TRUE),
    OccupiedUnits = mean(OccupiedUnits, na.rm = TRUE),
    VacantUnits = mean(VacantUnits, na.rm = TRUE),
    Treated = max(Treated, na.rm = TRUE),
    Post = max(Post, na.rm = TRUE),
    .groups = "drop"
  )

# --- Final Parcel Data
final_data <- final_data %>%
  mutate(across(c(sales_price, assess, per_acre, Acres), as.numeric)) %>%
  st_transform(crs = TARGET_CRS)

# --- Transmission Lines
lines_va <- transmission_lines_raw %>%
  st_transform(crs = TARGET_CRS) %>%
  st_filter(va_state_border)

# --- Roads (simplified for performance)
VA_roads <- VA_roads_raw %>%
  st_transform(crs = TARGET_CRS) %>%
  st_simplify(dTolerance = 0.0005, preserveTopology = TRUE)

# --- Cities (filter to largest by population)
VA_cities <- VA_cities_raw %>%
  st_transform(crs = TARGET_CRS) %>%
  mutate(POP_2010 = ifelse(POP_2010 < 0, NA, POP_2010)) %>%
  filter(!is.na(POP_2010)) %>%
  slice_max(order_by = POP_2010, n = 300)

# --- Water Features (keep top N by name or area)
water_features <- water_features_raw %>%
  st_as_sf(coords = c("INTPTLON", "INTPTLAT"), crs = TARGET_CRS) %>%
  slice_max(order_by = FULLNAME, n = 500)

# 5. LOAD REGRESSION MODELS
source("scripts/county_level_reg_mods.R")
source("scripts/parcel_level_reg_mods.R")

# ===================================================================
