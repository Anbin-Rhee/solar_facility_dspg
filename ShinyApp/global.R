# ===================================================================
# THIS IS THE ENTIRE CONTENT OF global.R
# ===================================================================

# 1. LOAD ALL LIBRARIES
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
addResourcePath("myimages", file.path(getwd(), "www"))

# 2. DEFINE GLOBAL VARIABLES & LOAD RAW DATA
map_variables <- c(
  "Sale Price" = "sales_price",
  "Assessed Value" = "assess",
  "Price per Acre" = "per_acre",
  "Distance to Solar Facility" = "sf_pc_dist",
  "Flatness Score" = "composite_flatness_score",
  "Distance to Road" = "dist_road_miles"
)

final_data <- readRDS("data/final_parcel_data.rds")
transmission_lines <- st_read("data/Transmission_Lines/Transmission_Lines.shp")
solar_data <- read_csv("data/solar_facility.csv")
va_counties <- counties(state = "VA", cb = TRUE)

# 3. PROCESS AND TRANSFORM DATA
map_data <- solar_data %>%
  select(
    Facility_Name = p_name,
    County = County,
    Latitude = ylat,
    Longitude = xlong,
    Capacity_MW = p_cap_ac,
    Commission_Year = Year
  )

final_data <- final_data %>%
  mutate(across(all_of(unname(map_variables)), as.numeric)) %>%
  st_transform(crs = 4326)

va_counties <- st_transform(va_counties, crs = 4326)
va_state_border <- st_union(va_counties)

transmission_lines_proj <- st_transform(transmission_lines, crs = st_crs(va_counties))
lines_va <- st_filter(transmission_lines_proj, st_transform(va_state_border, st_crs(transmission_lines_proj)))

# 4. SOURCE MODEL SCRIPTS
source("scripts/county_level_reg_mods.R")
source("scripts/parcel_level_reg_mods.R")