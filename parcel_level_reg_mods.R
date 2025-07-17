library(dplyr)
library(tidyverse)
install.packages("fixest")
library(fixest)


final_va_mod_parcels <- readRDS("clean_data/final_parcel_data.rds")
View(final_va_mod_parcels)




# Convert fixed effects and categorical variables to factors
# Also, create the log-transformed dependent variable
final_va_mod_parcels <- final_va_mod_parcels %>%
  mutate(
    log_per_acre = log(per_acre),
    year = factor(year),
    LOCALITY = factor(LOCALITY),
    land_cover_code = factor(land_cover_code)
  )

# Remove infinite values that may result from log(0)
# Use base R's square brackets for filtering
final_va_mod_parcels <- final_va_mod_parcels[is.finite(final_va_mod_parcels$log_per_acre), ]
final_va_mod_parcels <- final_va_mod_parcels %>%
  mutate(Acres = as.numeric(as.character(Acres)))


#DiD Model----------------------------------------------------------------------
did_model <- feols(log_per_acre ~ did_variable + Acres + composite_flatness_score + 
                     dist_parcel_to_line + dist_road_miles + dist_water_miles + 
                     dist_urban_miles | year + LOCALITY + land_cover_code, 
                   data = final_va_mod_parcels)


summary(did_model)

# View results with standard errors clustered by county (highly recommended)
summary(did_model, cluster = ~LOCALITY)




#Another regression-------------------------------------------------------------------------------

final_va_mod_parcels <- final_va_mod_parcels %>%
  mutate(
    log_sf_dist = log(sf_pc_dist + 1),
    log_grid_dist = log(dist_parcel_to_line + 1)
  )

# Step 2: Run the regression using your 'is_post_period' variable
new_did_model <- feols(log_per_acre ~ log_sf_dist * is_post_period + log_grid_dist * is_post_period + 
                         Acres + composite_flatness_score + dist_road_miles + 
                         dist_water_miles + dist_urban_miles | year + LOCALITY + land_cover_code, 
                       data = final_va_mod_parcels)

# View the results
summary(new_did_model, cluster = ~LOCALITY)
