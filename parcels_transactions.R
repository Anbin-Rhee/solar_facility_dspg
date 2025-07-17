
# Ceaning, merging parcel level datasets ----------------------------------

library(dplyr)
library(tidyverse)
library(stringr)
library(readr)
library(sf)
library(tigris)
#install.packages("mapview")
library(mapview)


transactions <- read_csv("C:\\Users\\altyyevaa\\Downloads\\parcels.csv")
View(transactions)

#Standardize the columns, and check missing values
transactions <- transactions %>%
  mutate(
    Location = str_to_title(Location),                     # Title case (First letter capital)
    Location = str_remove(Location, regex(" County$", ignore_case = TRUE))  # Remove 'County' at end
  ) %>%
  filter(!is.na(PIN), !is.na(per_acre))                     #filtering for the counties that don't have PIN number and price per acre



# Data Manipulation of parcel shapes --------------------------------------


parcel_shapes <- st_read("C:\\Users\\altyyevaa\\Downloads\\VirginiaParcel.shp")
head(parcel_shapes)


#Standardize the county names, and column names for merging
parcel_shapes <- parcel_shapes %>%
  mutate(
    LOCALITY = str_to_title(LOCALITY),
    LOCALITY = str_remove(LOCALITY, regex(" County$", ignore_case = TRUE))
  ) %>%
    rename(Location = LOCALITY, PIN = PARCELID)
  
#Remove Missing PIN observations
parcel_shapes <- parcel_shapes %>%
  filter(!is.na(PIN))
colnames(parcel_shapes)



#Checking the missing PINs in Parcel Shapefile
sum(is.na(parcel_shapes$PIN))
View(parcel_shapes)
colnames(transactions)


#merging the two datasets (parcels(transactions) and parcel shapes)
merged_data <- left_join(transactions, parcel_shapes, by = c("PIN", "Location"))

view(merged_data)

# how many didn't merge with a shape
sum(is.na(merged_data$geometry))  


merged_data <- st_as_sf(merged_data)



library(sf)

# Save the merged_data as a shapefile
st_write(merged_data, "clean_data/merged_data.shp", delete_layer = TRUE)



# Reconvert to sf using the geometry column
parcel_shapes <- st_as_sf(parcel_shapes)
class(parcel_shapes)
plot(parcel_shapes["geometry"])
