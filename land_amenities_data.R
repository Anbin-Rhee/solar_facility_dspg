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
#---------------------Creating distance of parcels to roads and Map Visualization for it -----------------------------------
roads <- st_read("C:\\Users\\cchen\\Downloads\\tl_2019_51_prisecroads\\tl_2019_51_prisecroads.shp")
View(roads)
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

#---------------------------------------------------------------------------------------------------------------------
#Reading in the water data of Rivers, Estuaries, Lakes, Ponds, Reservoirs 

# Provide the full path directly to the .shp file
streams_rivers <- st_read("C:\\Users\\cchen\\Downloads\\All_Steams___Rivers\\All_Steams___Rivers.shp")
# Now, this should work
head(streams_rivers)

# Do the same for the lakes and ponds data
lakes_ponds <- st_read("C:\\Users\\cchen\\Downloads\\Lakes_Ponds_Reservoirs_Estuaries\\Lakes_Ponds_Reservoirs_Estuaries.shp")

# And this should also work now
head(lakes_ponds)

# Load parcels (using the 'final_shapes' name from your previous code)
final_shapes <- st_read("C:\\Users\\cchen\\Downloads\\final_shapes\\final_shapes")

# --- 3. Reproject Data for Accurate Distance Calculation ---
# Distance calculations must be done in a projected coordinate system (CRS), not in latitude/longitude.
# We will project all layers to a common CRS for Virginia, like UTM Zone 18N (EPSG: 32618).

print("Reprojecting all layers to UTM Zone 18N...")
parcels_proj <- st_transform(final_shapes, crs = 32618)
streams_proj <- st_transform(streams_rivers, crs = 32618)
lakes_proj <- st_transform(lakes_ponds, crs = 32618)
print("Reprojection complete.")


# --- 4. Calculate Distance to Nearest Feature ---
# The st_distance() function calculates the shortest distance from each feature
# in the first dataset to any feature in the second dataset.
# NOTE: This can be slow on very large datasets. You might test with a sample first.
# sample_parcels <- head(parcels_proj, 100)

print("Calculating distance to nearest stream/river...")
dist_to_streams <- st_distance(parcels_proj, streams_proj)

print("Calculating distance to nearest lake/pond...")
dist_to_lakes <- st_distance(parcels_proj, lakes_proj)


print("Adding new distance columns to the parcel data...")

# The output of st_distance is a matrix. We take the minimum distance for each row.
# The units will be in meters because our CRS (UTM) is in meters.
parcels_with_distances <- parcels_proj %>%
  mutate(
    dist_to_stream_m = as.numeric(apply(dist_to_streams, 1, min)),
    dist_to_lake_m = as.numeric(apply(dist_to_lakes, 1, min))
  )


# --- 6. View the Final Results ---
print("Analysis complete. Here are the first few parcels with their distances:")

# View the first few rows of the data frame, hiding the geometry for readability
head(st_drop_geometry(parcels_with_distances))

View(dist_to_lakes)
# Interactive map of the bodies of water to the parcels 
map_streams <- mapview(parcels_with_distances, zcol = "dist_to_stream_m")
map_lakes <- mapview(parcels_with_distances, zcol = "dist_to_lake_m")

print(map_streams)
print(map_lakes)

combined_map <- map_streams + map_lakes
print(combined_map)
#--------------------------------------------distance from parcel to urban city centers wither RUC codes----

rucc_data <- read_excel("C:\\Users\\cchen\\Downloads\\Ruralurbancontinuumcodes2023 (1).xlsx")

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

