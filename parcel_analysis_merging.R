# If needed: install.packages("dplyr")
library(dplyr)
library(sf) # Or whatever package you use to read your data
library(tidyverse)
library(stringr)


attributes <- read_csv("clean_data/final_parcels_with_all_attributes.csv")

final_va_parcels <- final_virginia_parcels
View(final_va_parcels)

colnames(attributes)
colnames(final_va_parcels)

# Check for NAs in VGIN_QPID
sum(is.na(attributes$VGIN_QPID))
sum(is.na(final_va_parcels$VGIN_QPID))

# Check for duplicate values in VGIN_QPID
sum(duplicated(attributes$VGIN_QPID))
sum(duplicated(final_va_parcels$VGIN_QPID))



attributes %>%
  filter(VGIN_QPID %in% VGIN_QPID[duplicated(VGIN_QPID)]) %>%
  arrange(VGIN_QPID) %>%
  View()

# View the duplicated rows in the 'final_va_parcels' dataframe
final_va_parcels %>%
  filter(VGIN_QPID %in% VGIN_QPID[duplicated(VGIN_QPID)]) %>%
  arrange(VGIN_QPID) %>%
  View()




# Clean up the locality name in your new data frames
attributes_clean <- attributes %>%
  mutate(LOCALITY = str_trim(str_replace(LOCALITY, "County", "")), Location = str_trim(str_replace(Location, "County", "")))

final_va_parcels_clean <- final_va_parcels %>%
  mutate(LOCALITY = str_trim(str_replace(LOCALITY, "County", "")))
View(attributes_clean)

View(attributes_clean)
View(final_va_parcels)



attributes_clean <- attributes_clean %>%
  distinct(VGIN_QPID, year, consid, assess, .keep_all = TRUE)

# Clean the 'final_va_parcels' dataframe
final_va_parcels_clean <- final_va_parcels_clean %>%
  distinct(VGIN_QPID, year, consid, assess, .keep_all = TRUE)

# You can now check the number of rows to see how many were removed
nrow(attributes)
nrow(attributes_clean)

View(attributes_clean)
View(final_va_parcels_clean)



# example_qpid <- "5.1001e+12"
# 
# # This will show you ONLY the key columns for that specific parcel
# final_va_parcels_clean %>%
#   filter(VGIN_QPID == example_qpid) %>%
#   select(VGIN_QPID, year, consid, assess)

colnames(attributes_clean)
colnames(final_va_parcels_clean)


problematic_groups <- attributes_clean %>%
  group_by(VGIN_QPID, year) %>%
  filter(n() > 1) %>%
  ungroup()

# View the problematic rows to understand why they weren't removed
View(problematic_groups)


#Merging the datasets-----------------------------------------------------------
attributes_final_clean <- attributes_clean %>%
  distinct(VGIN_QPID, year, .keep_all = TRUE)

# Now, create the smaller table for joining from this new clean data
attributes_to_join <- attributes_final_clean %>%
  select(VGIN_QPID, year, dist_road_miles, dist_water_miles, dist_urban_miles, land_cover_code)

# Perform the join again. The warning should now be gone.
merged_data <- left_join(
  final_va_parcels_clean,
  attributes_to_join,
  by = c("VGIN_QPID", "year")
)


View(merged_data)



write_csv(attributes_to_join, "clean_data/attributes_for_join.csv")

# 2. Save your spatial 'final_va_parcels_clean' data as a GeoPackage.
# This keeps the geometry column perfectly intact.
st_write(final_va_parcels_clean, "clean_data/final_va_parcels_clean.gpkg", append = FALSE)




# merged_data some housekeeping -------------------------------------------

colnames(merged_data)
# Clean and transform the merged_data dataframe
final_parcel_level_data <- merged_data %>%
  rename(
    sales_price = consid,
    sf_pc_dist = distance_miles,
    parcel_geom = geometry
  ) %>%
  select(-distance_meters)

# You can check the new column names to confirm
colnames(final_parcel_level_data)
saveRDS(final_parcel_level_data, "clean_data/final_parcel_data.rds")
