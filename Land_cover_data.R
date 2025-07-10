#install.packages("exactextractr")
# --- 1. Load Libraries ---
# Make sure you have these packages installed: install.packages(c("terra", "sf", "dplyr", "exactextractr", "tidyr"))
library(terra)
library(sf)
library(dplyr)
library(exactextractr)
library(tidyr)

final_shapes <- st_read("C:\\Users\\cchen\\Downloads\\final_shapes\\final_shapes")

cdl_raster <- rast("C:\\Users\\cchen\\Downloads\\polygonclip_20250708105129_1949911031//CDL_2024_51.tif") 

parcel_sf <- st_transform(final_shapes, crs(cdl_raster))

# Extract land cover value for each parcel (mode of pixels within each polygon)

parcel_sf$land_cover <- terra::extract(cdl_raster, vect(parcel_sf), fun = modal, na.rm = TRUE)[,2]

# Check results

# parcel_sf$land_cover
head(parcel_sf)
table(parcel_sf$land_cover)

#---------------------------------------------------------------data cleaning-----------------


View(cdl_raster)


# --- 3. Pre-processing: Ensure CRS Match ---
# It's good practice to ensure both layers are in the same projection.
# We will transform the parcels to match the raster's CRS.
print("Transforming parcel CRS to match raster CRS...")
parcel_sf <- st_transform(final_shapes, crs = st_crs(cdl_raster))
print("CRS transformation complete.")


# --- 4. Reclassify the Raster Data ---
print("Reclassifying raster data into broader categories...")

# Step 4a: Define the reclassification scheme in a data frame.
# This makes it easy to see and edit your new categories.
# New categories: 1=Agriculture, 2=Developed, 3=Forest, 4=Water, 5=Other
reclass_df <- data.frame(
  from = c(1, 2, 4, 5, 24, 25, 26, 27, 37, 42, 43, 47, 61, # Agriculture
           121, 122, 123, 124,                              # Developed
           141, 142, 143,                                  # Forest
           111,                                             # Water
           131, 152, 176, 190, 195),                       # Other
  to = c(rep(1, 13),  # All in the first group map to 1
         rep(2, 4),   # All in the second group map to 2
         rep(3, 3),   # All in the third group map to 3
         4,           # Water maps to 4
         rep(5, 5))   # All in the last group map to 5
)

# Step 4b: Convert the data frame to a matrix format required by terra::classify()
reclass_matrix <- as.matrix(reclass_df)

# Step 4c: Apply the reclassification to the raster
# This creates a NEW raster where each pixel has one of our 5 new category values.
cdl_reclassified <- classify(cdl_raster, reclass_matrix, others = NA) # 'others=NA' makes other values disappear

# Optional: Define labels for the new categories for easier interpretation
levels(cdl_reclassified) <- data.frame(
  value = c(1, 2, 3, 4, 5),
  category = c("Agriculture", "Developed", "Forest", "Water", "Other")
)


# --- 5. Extract the Reclassified Land Cover ---
print("Extracting the majority reclassified land cover for each parcel...")

# Now, extract the modal (most frequent) value from the NEW reclassified raster
# The result will be the dominant broad category (1, 2, 3, 4, or 5) for each parcel.
parcel_sf$land_cover_code <- terra::extract(cdl_reclassified, vect(parcel_sf), fun = modal, na.rm = TRUE)[,2]

# Add the category name as a new column for clarity
category_levels <- levels(cdl_reclassified)[[1]] # Get the category labels
parcel_sf <- parcel_sf %>%
  left_join(category_levels, by = c("land_cover_code" = "value"))


# --- 6. Check Results ---
print("Analysis complete. Here are the first few results:")
head(st_drop_geometry(parcel_sf))

print("Frequency table of the new broad land cover categories:")
table(parcel_sf$category)



