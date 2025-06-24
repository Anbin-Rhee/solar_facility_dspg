library(sf)
library(dplyr)
library(readr)
library(stringr)
library(readxl)

# Load the parcel shapefile
#shapefile_path <- "C:/Users/altyyevaa/Downloads/VirginiaParcel.shp (1)"
#parcels <- st_read(shapefile_path)

# OPTIONAL: Select only county-related columns
county_cols <- parcels %>% select(contains("county", ignore.case = TRUE))

# 🔹 Load the transaction CSV file
#transactions_2010 <- read_excel("C:/Users/altyyevaa/Downloads/Transactions (1)/Transactions/Transactions_2010.xlsx")
# 🔹 Clean county + parcel ID columns in both datasets
# Replace these column names (CountyName, PIN, County, ParcelID) with your actual ones if different

colnames(parcels)

parcels <- parcels %>%
  mutate(
    county_clean = as.character(LOCALITY, "\\s+", ""),
    PIN_clean = str_replace_all(PARCELID, "\\s+", "")
  )

transactions_2010 <- transactions_2010 %>%
  mutate(
    county_clean = as.character(county, "\\s+", ""),
    PIN_clean = str_replace_all(pin, "\\s+", "")
  )

# 🔹 Join on both county and parcel ID
joined_data <- inner_join(parcels, transactions_2010, by = c("county_clean", "PIN_clean"))
View(joined_data)

library(dplyr)

# Filter rows where LOCALITY is "James City County"
james_county_parcels <- parcels %>%
  filter(LOCALITY == "James City County")


