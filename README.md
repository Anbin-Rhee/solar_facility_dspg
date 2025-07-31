# ☀️ Impact of Utility-Scale Solar Facilities on Land Values in Virginia

This repository contains data, scripts, and a Shiny app developed for the **2025 Data Science for the Public Good (DSPG)** program at Virginia Tech. Our research investigates how proximity to utility-scale solar facilities affects land values across Virginia at both the **county** and **parcel** levels.

---

## 📁 Repository Structure

solar_facility_dspg/


├── All_project_codes/     - All data cleaning, merging, and regression scripts  
├── clean_data/            - Cleaned datasets (CSV, shapefiles, RDS) for analysis  
├── raw_data/              - Raw, unprocessed datasets from public/state sources  
├── ShinyApp/              - R Shiny dashboard for interactive exploration  
├── README.md              - You are here  
└── DSPG_Git.Rproj         - R project file

---

## Reproducibility Guide

### 1. Required R Packages

Install the following R packages:

tidyverse, sf, plm, broom, readr, ggplot2,  
tigris, leaflet, shiny, shinythemes, shinyWidgets,  
DT, lubridate, stringr, readxl, rgdal

---

##  Data Overview

### Final Datasets for Regression

- clean_data/county_level_cleaned_model_data.csv — County-level dataset for panel regression  
- clean_data/final_parcel_data.rds — Final parcel-level dataset (merged attributes, distances, zoning)  

### Raw Input Files (raw_data/)

- Solar_facility_VA - Copy.xlsx — Raw solar facility info with coordinates  
- va_county_pop_all.csv, va_avg_housing_age.csv — County-level ACS/demographic data  
- New_Corn_Data.csv, New_Soy_Data.csv — Raw crop yield data  
- old_Corn_data.xlsx, old_Soy_data.xlsx — Deprecated crop data  
- va_housing_by_year.csv, va_housing_status.csv — Raw housing status metrics  

### Cleaned Data (clean_data/)

- parcel_level_variables.csv, final_parcels_with_all_attributes.csv — Intermediate merged parcel datasets  
- parcels_urban_dist.csv, parcels_water_dist.csv — Parcel-level distance to urban/water  
- parcel_land_cover.csv — Land cover classification per parcel  
- solar_facility.csv — Cleaned solar facility data  
- va_population.csv, va_housing_year.csv — ACS demographic inputs  
- final_va_parcels_clean.gpkg, merged_data.shp — Spatial layers  
- model_results.csv — Regression model output  

---

## Running the Regression Models

### County-Level

Run in R:

source("All_project_codes/county_level_reg_mods.R")

Optional supporting scripts:  
- county_level_merge_code.R  
- county_level_variables.R

### Parcel-Level

Run in R:

source("All_project_codes/parcel_level_reg_mods.R")

Supporting scripts:  
- parcel_level_mod_distance_variables.R  
- parcel_level_variables_merging.R  
- parcels_transactions.R

---

## 🌐 R Shiny Dashboard

To launch the dashboard:

setwd("ShinyApp")  
shiny::runApp()

The dashboard includes:  
- Parcel and county map layers  
- Solar facility locations  
- Transmission line overlays  
- Regression model outputs  
- Team and methodology tabs

---

## Acknowledgments

This research was conducted as part of the **Virginia Tech Data Science for the Public Good (DSPG) Summer 2025** program.  
Supported by the USDA NIFA DATA-ACRE Grant No. **2022-67037-36639**.

---

## Project Team

**Aziza Altyyeva** & **Collin Holt**  
Mentored by Dr. Michael Cary, Anbin Rhee  
Contact: altyyevaa@berea.edu
