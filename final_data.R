library(terra)
library(sf)
library(dplyr)
library(exactextractr)
library(tidyr)
library(tidyverse)
library(tigris)
library(readxl)
library(mapview)
#final shapes, parcels  



view(parcels_water_dist)

View(parcels_with_urban_dist)

View(parcel_Land_cov)

# Write the dataframe with water distances
write.csv(parcels_water_dist, "clean_data/parcels_water_dist.csv", row.names = FALSE)

# Write the dataframe with urban distances
write.csv(parcels_with_urban_dist, "clean_data/parcels_urban_dist.csv", row.names = FALSE)

# Write the dataframe with land cover data
write.csv(parcel_Land_cov, "clean_data/parcel_land_cover.csv", row.names = FALSE)
#----------------------------------------final data code below#########----------------------

# --- 1. UNIFIED SETUP: Load all libraries once ---
# install.packages(c("terra", "sf", "dplyr", "exactextractr", "tidyr", "tidyverse", "tigris", "readxl", "mapview"))
library(terra)
library(sf)
library(dplyr)
library(tidyr)
library(tigris)
library(readxl)
library(mapview)
library(exactextractr) # Ensure this is loaded

# --- 2. LOAD & PROJECT DATA ONCE ---
print("Loading and projecting initial data...")

# Load the base parcel data
parcels <- st_read("C:\\Users\\collinh05\\Downloads\\Parcel Shapefile\\final_shapes\\final_shapes.shp")

# Define a single target CRS (UTM Zone 18N) for all distance calculations
target_crs <- 32618

# Define conversion factor from meters to miles
METERS_TO_MILES <- 0.000621371

# Create one projected version of the parcels to be used for all analyses
parcels_proj <- st_transform(parcels, crs = target_crs)
parcels_proj <- st_make_valid(parcels_proj) # Validate geometry once

print("Initial data loaded and projected.")

# --- 3. ANALYSIS A: Land Cover ---
print("Starting Land Cover analysis...")
cdl_raster <- rast("C:\\Users\\collinh05\\Downloads\\Land Cover Data\\CDL_2024_51\\CDL_2024_51.tif")
reclass_df <- data.frame(
  from = c(1, 2, 4, 5, 24, 27, 37, 42, 43, 47, 61, 121, 122, 123, 124, 141, 142, 143, 111, 131, 152, 176, 190, 195),
  to = c(rep(1, 11), rep(2, 4), rep(3, 3), 4, rep(5, 5))
)
reclass_matrix <- as.matrix(reclass_df)
cdl_reclassified <- classify(cdl_raster, reclass_matrix, others = NA)
levels(cdl_reclassified) <- data.frame(value = 1:5, category = c("Agriculture", "Developed", "Forest", "Water", "Other"))

# Extract data and ADD IT to our main projected dataframe
land_cover_codes <- terra::extract(cdl_reclassified, vect(st_transform(parcels, crs(cdl_reclassified))), fun = modal, na.rm = TRUE)[,2]
final_parcels <- parcels_proj %>%
  mutate(land_cover_code = land_cover_codes) %>%
  left_join(levels(cdl_reclassified)[[1]], by = c("land_cover_code" = "value"))

print("Land Cover analysis complete.")

# --- 4. ANALYSIS B: Distance to Roads ---
print("Calculating distance to roads...")
roads <- st_read("C:\\Users\\collinh05\\Downloads\\tl_2019_51_prisecroads\\tl_2019_51_prisecroads.shp")
roads_proj <- st_transform(roads, crs = target_crs)
nearest_road_idx <- st_nearest_feature(final_parcels, roads_proj)
dist_to_road_m <- st_distance(final_parcels, roads_proj[nearest_road_idx,], by_element = TRUE)

# ADD the new column, converting to miles and renaming the column
final_parcels$dist_road_miles <- as.numeric(dist_to_road_m) * METERS_TO_MILES
print("Road distance calculation complete.")

# --- 5. ANALYSIS C: Distance to Water ---
print("Calculating distance to water...")
water_features <- area_water(state = 'VA', county = counties(state = 'VA')$COUNTYFP)
water_proj <- st_transform(water_features, crs = target_crs)
water_proj <- st_make_valid(water_proj)
nearest_water_idx <- st_nearest_feature(final_parcels, water_proj)
dist_to_water_m <- st_distance(final_parcels, water_proj[nearest_water_idx,], by_element = TRUE)

# ADD the new column, converting to miles and renaming the column
final_parcels$dist_water_miles <- as.numeric(dist_to_water_m) * METERS_TO_MILES
print("Water distance calculation complete.")

# --- 6. ANALYSIS D: Distance to Urban Centers ---
print("Calculating distance to urban centers...")
rucc_data <- read_excel("C:\\Users\\collinh05\\Downloads\\Land Amenities data\\Ruralurbancontinuumcodes2023 (1).xlsx")
va_urban_centers <- rucc_data %>% filter(State == "VA", RUCC_2023 <= 3) %>% mutate(GEOID = as.character(FIPS))
urban_counties_sf <- counties(state = "VA", cb = TRUE) %>%
  left_join(va_urban_centers, by = "GEOID") %>%
  filter(RUCC_2023 <= 3)
urban_counties_proj <- st_transform(urban_counties_sf, crs = target_crs)
nearest_urban_idx <- st_nearest_feature(final_parcels, urban_counties_proj)
dist_to_urban_m <- st_distance(final_parcels, urban_counties_proj[nearest_urban_idx,], by_element = TRUE)

# ADD the new column, converting to miles and renaming the column
final_parcels$dist_urban_miles <- as.numeric(dist_to_urban_m) * METERS_TO_MILES
print("Urban distance calculation complete.")


# --- 7. FINAL DATAFRAME ---
# Now, 'final_parcels' contains ALL the new columns in one clean object.
print("All analyses complete. Final dataframe head:")
head(st_drop_geometry(final_parcels))
View(final_parcels)
# You can now save this single, complete file
write.csv(st_drop_geometry(final_parcels), "C:\\Users\\collinh05\\solar_facility_dspg\\clean_data\\final_parcels_with_all_attributes.csv", row.names = FALSE)
