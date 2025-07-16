# --- 1. UNIFIED SETUP: Load all libraries once ---
# Make sure you have these packages installed: install.packages(c("sf", "dplyr", "tidyr", "tigris", "readxl", "mapview"))
library(sf)
library(dplyr)
library(tidyr)
library(tigris)
library(readxl)
library(mapview)

# --- 2. LOAD & PROJECT DATA ONCE ---
print("Loading and projecting initial data...")

# Corrected file path using double backslashes
parcels <- st_read("C:\\Users\\collinh05\\Downloads\\Parcel Shapefile\\final_shapes\\final_shapes.shp")

# Define a single target CRS (UTM Zone 18N) for all distance calculations
target_crs <- 32618
# Define conversion factor from meters to miles
METERS_TO_MILES <- 0.000621371

# Create one projected version of the parcels to be used for all analyses
# This will be our main dataframe that we add columns to.
final_parcels <- st_transform(parcels, crs = target_crs)
final_parcels <- st_make_valid(final_parcels) # Validate geometry once

print("Initial data loaded and projected.")

# --- 3. ANALYSIS A: Distance to Roads ---
print("Calculating distance to nearest road...")
roads <- st_read("C:\\Users\\collinh05\\Downloads\\tl_2019_51_prisecroads\\tl_2019_51_prisecroads.shp")
roads_proj <- st_transform(roads, crs = target_crs)
nearest_road_idx <- st_nearest_feature(final_parcels, roads_proj)
dist_to_road_m <- st_distance(final_parcels, roads_proj[nearest_road_idx,], by_element = TRUE)
final_parcels$dist_road_m <- as.numeric(dist_to_road_m)
print("Road distance calculation complete.")

# --- VISUALIZE: Roads ---
# Uncomment the block below to view the map
 #mapview(final_parcels, zcol = "dist_road_m", layer.name = "Distance to Roads (m)") +
   #mapview(roads_proj, color = "black", layer.name = "Roads")

# --- 4. ANALYSIS B: Distance to All Water (from Tigris) ---
# This section was corrected to create a meters column first for consistency.
print("Calculating distance to all water bodies...")
water_features <- area_water(state = 'VA', county = counties(state = 'VA')$COUNTYFP)
water_proj <- st_transform(water_features, crs = target_crs)
water_proj <- st_make_valid(water_proj)
nearest_water_idx <- st_nearest_feature(final_parcels, water_proj)
dist_to_water_m <- st_distance(final_parcels, water_proj[nearest_water_idx,], by_element = TRUE)

# Add the new column in meters
final_parcels$dist_water_m <- as.numeric(dist_to_water_m)
print("Water distance calculation complete.")
#uncomment maps for water visualizations 
#mapview(final_parcels, zcol = "dist_water_m", layer.name = "Distance to Water (m)") +
# mapview(water_proj, col.regions = "blue", color = "blue", layer.name = "Water Bodies")

# --- 5. ANALYSIS C: Distance to Urban Centers ---
# This section was corrected to use the 'collinh05' user path.
print("Calculating distance to urban centers...")
rucc_data <- read_excel("C:\\Users\\collinh05\\Downloads\\Land Amenities data\\Ruralurbancontinuumcodes2023 (1).xlsx")
va_urban_centers <- rucc_data %>% filter(State == "VA", RUCC_2023 <= 3) %>% mutate(GEOID = as.character(FIPS))
urban_counties_sf <- counties(state = "VA", cb = TRUE, class = "sf") %>%
  left_join(va_urban_centers, by = "GEOID") %>%
  filter(!is.na(RUCC_2023)) # Ensure we only keep counties that are urban
urban_counties_proj <- st_transform(urban_counties_sf, crs = target_crs)
nearest_urban_idx <- st_nearest_feature(final_parcels, urban_counties_proj)
dist_to_urban_m <- st_distance(final_parcels, urban_counties_proj[nearest_urban_idx,], by_element = TRUE)
final_parcels$dist_urban_m <- as.numeric(dist_to_urban_m)
print("Urban distance calculation complete.")

# --- VISUALIZE: Urban ---
# Uncomment the block below to view the map
# mapview(final_parcels, zcol = "dist_urban_m", layer.name = "Distance to Urban (m)") +
 #  mapview(urban_counties_proj, col.regions = "yellow", alpha.regions = 0.4, layer.name = "Urban Counties")

# --- 6. FINAL CONVERSIONS & DATAFRAME ---
# This section was corrected to match the columns that were actually created.
print("Converting all distances to miles...")
final_parcels_with_miles <- final_parcels %>%
  mutate(
    dist_road_miles = dist_road_m * METERS_TO_MILES,
    dist_water_miles = dist_water_m * METERS_TO_MILES,
    dist_urban_miles = dist_urban_m * METERS_TO_MILES
  ) %>%
  # Select only the final columns you need to keep the file clean
  select(
    # Add any other original columns from 'final_parcels' you want to keep here
    # For example: select(PARCEL_ID, dist_road_miles, ...)
    starts_with("dist_"), # A shortcut to keep all distance columns
    geometry
  )

print("All analyses complete. Final dataframe head:")
head(st_drop_geometry(final_parcels_with_miles))
View(final_parcels_with_miles)

# You can now save this single, complete file
# write.csv(st_drop_geometry(final_parcels_with_miles), "clean data/final_parcels_with_all_distances.csv", row.names = FALSE)