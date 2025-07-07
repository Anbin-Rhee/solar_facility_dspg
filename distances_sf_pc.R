#In this code I will work with final parcels shapefiles from Dr. Cary
library (sf)
library(dplyr)
library(tidyverse)
library(mapview)
# This uses st_read() to load the actual spatial data from the path
parcels <- st_read("C:\\Users\\altyyevaa\\Desktop\\SOLAR_PROJECT_FILES\\final_shapes\\final_shapes\\final_shapes.shp")

# Fix any invalid geometries in the parcels data
parcels <- st_make_valid(parcels)

facilities <- read_csv(" solar_fac.csv")

facilities_sf <- st_as_sf(facilities,
                          coords = c("xlong", "ylat"),
                          crs = 4326)

# transform the facilities layer to match the parcels' CRS
solar_facilities <- st_transform(facilities_sf, st_crs(parcels))

#calculates the distance from every parcel to every facility. 
#It creates a large table (a matrix) of all possible distances.
dist_matrix <- st_distance(parcels, solar_facilities)  


# Get the column index of the minimum distance for each parcel
closest_index <- apply(dist_matrix, 1, which.min)

# Get the value of that minimum distance for each parcel
min_dist <- apply(dist_matrix, 1, min)


# Use the index to get the data of the closest facilities
closest_facility_data <- solar_facilities[closest_index, ]

# Add the new information as columns to the parcels dataset
# Make sure to use a real column name from your facility data
parcels_with_distance <- parcels %>%
  mutate(
    closest_facility_name = closest_facility_data$p_name,
    distance_meters = as.numeric(min_dist)
  )

head(parcels_with_distance)

#st_write(parcels_with_distance, "parcels_with_facility_distance.shp")
mapview(parcels_with_distance, col.regions = "brown") + mapview(solar_facilities, color = "gold", col.regions = "gold")
