#install.packages("mapview")
library(terra)
library(sf)
library(dplyr)
library(exactextractr)
library(tidyr)
library(tidyverse)
library(tigris)
library(readxl)
library(mapview)

# Load parcels (using the 'final_shapes' name from your previous code)
final_shapes <- st_read("C:\\Users\\collinh05\\Downloads\\Parcel Shapefile\\final_shapes\\final_shapes.shp")

#---------------------Creating distance of parcels to roads and Map Visualization for it -----------------------------------
roads <- st_read("C:\\Users\\collinh05\\Downloads\\tl_2019_51_prisecroads\\tl_2019_51_prisecroads.shp")
roads_proj <- st_transform(roads, crs = st_crs(parcels_proj))
# compute the distance
dist_to_roads <- st_distance(parcels_proj, roads_proj)

# Take the minimum distance for each parcel
dist_to_road_m <- as.numeric(apply(dist_to_roads, 1, min))
# attach distance to my parcel data
parcels_with_distances <- parcels_proj %>%
  mutate(dist_to_road_m = dist_to_road_m)
# visualization
mapview(parcels_with_distances, zcol = "dist_to_road_m") +
  mapview(roads_proj, color = "black")


#-------------------------------------------------------------------------------bodies of water final distance measurement and interactive map
vaco <- counties(state = 'VA')

options(tigris_use_cache = TRUE)

water <- as.data.frame(NULL)

for (c in vaco$COUNTYFP) {
  print(c)
  tmp <- area_water(state = 'VA', county = c)
  water <- rbind(water, tmp)
}

parcels <- st_read("C:\\Users\\collinh05\\Downloads\\Parcel Shapefile\\final_shapes\\final_shapes.shp")


# Set tigris options to cache downloaded files
options(tigris_use_cache = TRUE)




# --- 3. Reproject Data for Accurate Distance Calculation ---
# To measure distance in meters, we must use a projected coordinate system (CRS).
# We'll project both layers to a common CRS for Virginia: UTM Zone 18N (EPSG: 32618).

print("Reprojecting all layers to a common CRS (UTM Zone 18N)...")
target_crs <- 32618 
parcels_proj <- st_transform(parcels, crs = target_crs)
water_proj <- st_transform(water, crs = target_crs)

# It's also good practice to ensure geometries are valid
parcels_proj <- st_make_valid(parcels_proj)
water_proj <- st_make_valid(water_proj)

print("Reprojection complete.")


# --- 4. Calculate Distance to Nearest Water Body ---
# This is the most efficient method for large datasets.
# Step A: Find the *index* of the nearest water feature for each parcel.
# Step B: Calculate the distance only between each parcel and its single nearest feature.

print("Calculating distance from each parcel to the nearest water body...")

# Step A: Find the index of the nearest water polygon for each parcel
nearest_water_index <- st_nearest_feature(parcels_proj, water_proj)

# Step B: Calculate the actual distance using the index found above.
# 'by_element = TRUE' ensures we get a 1-to-1 distance vector.
distances <- st_distance(
  parcels_proj, 
  water_proj[nearest_water_index, ], 
  by_element = TRUE
)

print("Distance calculation complete.")


# --- 5. Add Distances to the Parcel Data Frame ---
# The 'distances' object is a special 'units' class. We convert it to a number.
# The result will be in meters, as defined by our projected CRS.

parcels_with_distance_water <- parcels_proj %>%
  mutate(
    dist_to_water_m = as.numeric(distances)
  )
METERS_TO_MILES <- 0.000621371

# Use mutate to add a new column for distance in miles
parcels_water_dist <- parcels_with_distance_water %>%
  mutate(
    dist_to_water_miles = dist_to_water_m * METERS_TO_MILES
  )

# View the first few rows with both meter and mile columns
# We use st_drop_geometry() to make the table easier to read
head(st_drop_geometry(parcels_water_dist))
view(parcels_water_dist)
# --- 6. View the Final Results ---
print("Analysis complete. Here are the first few parcels with their new distance column:")

# View the first few rows of the data frame. 
# We use st_drop_geometry() here to make the table easier to read in the console.
head(st_drop_geometry(parcels_with_distance_water))

# You can also view the full table
View(parcels_with_distance_water)


# --- 7. (Optional) Visualize the Results ---
# An interactive map is a great way to check your work.
# This requires the 'mapview' package: install.packages("mapview")
if (require("mapview")) {
  print("Generating interactive map...")
  mapview(parcels_with_distance, zcol = "dist_to_water_m", layer.name = "Parcels Distance to Water (m)") +
    mapview(water_proj, col.regions = "blue", color = "blue", layer.name = "Water Bodies")
}





#--------------------------------------------distance from parcel to urban city centers wither RUC codes----

rucc_data <- read_excel("C:\\Users\\collinh05\\Downloads\\Land Amenities data\\Ruralurbancontinuumcodes2023 (1).xlsx")

va_urban_centers <- rucc_data %>%
  
  filter(State == "VA", RUCC_2023 <= 3) %>%
  
  mutate(GEOID = as.character(FIPS))


va_counties_geo <- counties(state = "VA", cb = TRUE, class = "sf")  # gets county geometries

# Join geometries with RUCC data

urban_counties_sf <- va_counties_geo %>%
  
  mutate(GEOID = as.character(GEOID)) %>%
  
  left_join(va_urban_centers, by = "GEOID") %>%
  
  filter(RUCC_2023 <= 3)

# Check CRS of parcels

st_crs(parcels_proj)  # assume it’s EPSG:32618

urban_counties_proj <- st_transform(urban_counties_sf, crs = st_crs(parcels_proj))

# Matrix of distances (in meters)

dist_to_urban <- st_distance(parcels_proj, urban_counties_proj)

# Get the minimum distance per parcel

parcels_with_urban_dist <- parcels_proj %>%
  
  mutate(dist_to_urban_m = apply(dist_to_urban, 1, min))

head(parcels_with_urban_dist)

summary(parcels_with_urban_dist$dist_to_urban_m)

# Add a new column by dividing the meters column by this value.
parcels_with_urban_dist <- parcels_with_urban_dist %>%
  mutate(dist_to_urban_miles = dist_to_urban_m / 1609.34)

# View the first few rows to see your new column
head(parcels_with_urban_dist)

# You can also get a summary of the new distance column in miles
summary(parcels_with_urban_dist$dist_to_urban_miles)

#Create the interactive map
# This visualizes the parcels, colored by the 'dist_to_urban_miles' column,
# and overlays the urban county polygons in a semi-transparent yellow.
mapview(parcels_with_urban_dist, zcol = "dist_to_urban_miles", layer.name = "Distance to Urban (Miles)") + 
  mapview(urban_counties_proj, col.regions = "yellow", alpha.regions = 0.4, layer.name = "Urban Counties (RUCC 1-3)")
