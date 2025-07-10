#In this code I will work with final parcels shapefiles from Dr. Cary
library (sf)
library(dplyr)
library(tidyverse)
library(mapview)
# This uses st_read() to load the actual spatial data from the path
parcels <- st_read("C:\\Users\\altyyevaa\\Desktop\\SOLAR_PROJECT_FILES\\final_shapes\\final_shapes\\final_shapes.shp")

# Fix any invalid geometries in the parcels data
parcels <- st_make_valid(parcels)

facilities <- read_csv("clean_data/solar_facility.csv")

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

View(closest_facility_data)
# Add the new information as columns to the parcels dataset
# Make sure to use a real column name from your facility data
parcels_with_distance <- parcels %>%
  mutate(
    closest_facility_name = closest_facility_data$p_name,
    distance_meters = as.numeric(min_dist),
    facility_county = closest_facility_data$County,
    facility_year = closest_facility_data$Year
  )

head(parcels_with_distance)

#st_write(parcels_with_distance, "parcels_with_facility_distance.shp")
mapview(parcels_with_distance, col.regions = "brown") + mapview(solar_facilities, color = "gold", col.regions = "gold")

View(parcels_with_distance)


#standardizing the Location column
parcels_with_distance <- parcels_with_distance %>%
  mutate(
    # Overwrite the Locality column with its cleaned version
    LOCALITY = str_to_title(str_trim(
      str_replace_all(
        str_to_lower(LOCALITY), "county", ""
      )
    )),
    # Also overwrite the Location column with its cleaned version
    Location = str_to_title(str_trim(
      str_replace_all(
        str_to_lower(Location), "county", ""
      )
    )
  )
  )


View(parcels_with_distance)

# Three Binary Variables: Control and Treat groups ------------------------

#converting meters to miles for more clarity 
meters_to_miles <- 0.000621371

parcels_with_distance <- parcels_with_distance %>%
  mutate(
    distance_miles = distance_meters * meters_to_miles)

head(parcels_with_distance)


#adding the treated column: distances between solar facilites and parcels are within 5 miles
parcels_with_distance <- parcels_with_distance %>%
  mutate(treated = if_else(distance_miles <= 5, 1, 0))

head(parcels_with_distance)


#adding the control group1: distance between solar facilities and parcels within 5miles and 10 miles
parcels_with_distance <- parcels_with_distance %>%
  mutate(control_1 = if_else(distance_miles > 5 & distance_miles <= 10, 1, 0))

head(parcels_with_distance)

#adding the control gorup2: distance between solar facility and parcels greater than 5 miles but within the same county
parcels_with_distance <- parcels_with_distance %>%
mutate(control_2 = if_else(distance_miles > 5 & LOCALITY == facility_county, 1, 0))

View(parcels_with_distance)



# Computing average price per acre for each group -------------------------
all_group_averages <- parcels_with_distance %>%
 #Reshape the data from wide to long.
  pivot_longer(
    cols = c(treated, control_1, control_2), # Tell it which columns to pivot
    names_to = "group_name",                  # Name of the new column for the group names
    values_to = "is_in_group"                 # Name of the new column for the 0s and 1s
  ) %>%
  
  #Keep only the rows that are actually in a group.
  filter(is_in_group == 1) %>%
  
  # Group by the new 'group_name' column.
  # This prepares the data for summarizing each group.
  group_by(group_name) %>%
  
  # Calculate the average for each group.
  summarize(
    avg_per_acre = mean(per_acre, na.rm = TRUE),
    number_of_parcels = n() # Optional: also count parcels in each group
  )

#view the final, clean summary table
print(all_group_averages)
View(all_group_averages)




# Visualizations ----------------------------------------------------------

library(ggplot2)

#  getting the data into the long format
long_data <- parcels_with_distance %>%
  pivot_longer(
    cols = c(treated, control_1, control_2),
    names_to = "group_type",
    values_to = "is_in_group"
  ) %>%
  filter(is_in_group == 1)

#create the boxplot
ggplot(long_data, aes(x = group_type, y = per_acre, fill = group_type)) +
  geom_boxplot() +
  labs(title = "Distribution of Price Per Acre by Group", x = "Group", y = "Price Per Acre") +
  theme_minimal()



library(mapview)

# Filter for the control_2 group
control_2_parcels <- parcels_with_distance %>%
  filter(control_2 == 1)

# Create an interactive map, colored by price per acre
mapview(control_2_parcels, zcol = "per_acre")



# Analysis for parcels below 50k ------------------------------------------

parcels_under_50k <- parcels_with_distance %>%
  filter(per_acre <= 50000)


# Calculating averages for ONLY parcels under $50k
under_50k_summary <- parcels_under_50k %>%
  pivot_longer(
    cols = c(treated, control_1, control_2),
    names_to = "group_name",
    values_to = "is_in_group"
  ) %>%
  filter(is_in_group == 1) %>%
  group_by(group_name) %>%
  summarize(
    avg_per_acre = mean(per_acre, na.rm = TRUE),
    sd_per_acre = sd(per_acre, na.rm = TRUE),
    number_of_parcels = n()
  )

View(under_50k_summary)



#Visualization for parcels under 50k
long_data_under_50k <- parcels_under_50k %>%
  pivot_longer(
    cols = c(treated, control_1, control_2),
    names_to = "group_type",
    values_to = "is_in_group"
  ) %>%
  filter(is_in_group == 1)

# creating the boxplot using this new long data
ggplot(long_data_under_50k, aes(x = group_type, y = per_acre, fill = group_type)) +
  geom_boxplot() +
  labs(
    title = "Distribution of Price Per Acre by Group (Parcels Under $50k)",
    x = "Group",
    y = "Price Per Acre"
  ) +
  theme_minimal()




# OLS Regression ----------------------------------------------------------

View(parcels_with_distance)
parcels_with_distance_clean <- parcels_with_distance %>%
  #na.omit() %>%
  filter(per_acre > 0)

sum(is.na(parcels_with_distance_clean$per_acre))
View(parcels_with_distance_clean)
simple_distance_model <- lm(log(per_acre) ~ distance_miles + I(distance_miles^2) + factor(Location) + factor(year), data = parcels_with_distance_clean)
summary(simple_distance_model)




# DiD Code ----------------------------------------------------------------

parcels_with_distance_clean <- parcels_with_distance_clean %>%
  mutate(
    # 1 if parcel is within 5 miles (treatment group), 0 otherwise
    is_treated = if_else(distance_miles <= 5, 1, 0),
    
    # 1 if the sale happened after the facility was built, 0 if before
    is_post_period = if_else(year >= facility_year, 1, 0)
  )




#DiD variable
parcels_with_distance_clean <- parcels_with_distance_clean %>%
  mutate(
    did_variable = is_treated * is_post_period
  )

View(parcels_with_distance_clean)


# BASIC DID Regression Model
did_model_basic <- lm(log(per_acre) ~ is_treated + is_post_period + did_variable, 
                      data = parcels_with_distance_clean)


summary(did_model_basic)  



#Another regression model with additonal control variables
# 
did_model_full <- lm(log(per_acre) ~ is_treated + is_post_period + did_variable + 
                       distance_miles + I(distance_miles^2) + Acres + factor(Location) + factor(year), 
                     data = parcels_with_distance_clean)


summary(did_model_full)


#REGRESSIONS that Matter

analysis_data_1 <- parcels_with_distance_clean %>%
  filter(is_treated == 1 | control_1 == 1)
View(analysis_data_1)

# 2. Create the second dataset for your robustness check
analysis_data_2 <- parcels_with_distance_clean %>%
  filter(is_treated == 1 | control_2 == 1)
View(analysis_data_2)

analysis_1 <- lm(log(per_acre) ~ did_variable + is_treated + is_post_period + factor(Location) + factor(year), data = analysis_data_1)

analysis_2 <- lm(log(per_acre) ~ did_variable + is_treated + is_post_period + factor(Location) + factor(year), data = analysis_data_2)
 
summary(analysis_1)
summary(analysis_2)



#Clustered STandard Errors Analysis:
library(lmtest)
library(sandwich)

#analysis for control_1 group
analysis_1x <- coeftest(analysis_1, vcov = vcovCL, cluster = ~Location)
print(analysis_1x)


#analysis for control_2 group

analysis_2x <- coeftest(analysis_2, vcov = vcovCL, cluster = ~Location)
print(analysis_2x)
