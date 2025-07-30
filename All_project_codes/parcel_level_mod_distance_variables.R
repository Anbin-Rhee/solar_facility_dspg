#In this code I will work with final parcels shapefiles from Dr. Cary
library (sf)
library(dplyr)

library(tidyverse)
library(mapview)
install.packages("janitor")
library(janitor)
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


# Make sure you have the model object from the previous steps
# model <- lm(formula = log(per_acre) ~ distance_miles + I(distance_miles^2) + 
#               factor(Location) + factor(year), data = parcels_with_distance_clean)

# 1. Calculate the effect of distance for each observation based on the model's coefficients.
#    This isolates the part of the prediction due to distance.
distance_effect <- simple_distance_model$coefficients["distance_miles"] * parcels_with_distance_clean$distance_miles + 
  simple_distance_model$coefficients["I(distance_miles^2)"] * (parcels_with_distance_clean$distance_miles^2)

# 2. Calculate the partial residuals.
#    This is the model's regular residual plus the isolated distance effect.
partial_residuals <- residuals(simple_distance_model) + distance_effect

# 3. Create a new data frame for plotting
plot_data_general <- data.frame(
  distance_miles = parcels_with_distance_clean$distance_miles,
  partial_residual = partial_residuals
)

# 4. Create the plot using ggplot2
library(ggplot2)

ggplot(plot_data_general, aes(x = distance_miles, y = partial_residual)) +
  # Plot the partial residual points with some transparency
  geom_point(alpha = 0.2, color = "grey50") +
  
  # Add a smooth line to visualize the general trend.
  # 'gam' (Generalized Additive Model) is excellent for capturing complex curves.
  geom_smooth(method = "gam", formula = y ~ s(x), color = "#D55E00", size = 1.2) +
  
  # Add titles and labels
  labs(
    title = "General Effect of Distance on Price",
    subtitle = "Curve shows the relationship after accounting for Location and Year",
    x = "Distance from Solar Facility (miles)",
    y = "General Effect on Log(Price Per Acre)"
  ) +
  theme_minimal()

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

# creating the second dataset for the robustness check
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

summary(analysis_1x)
summary(analysis_2x)




# FINAL SECTION: Calculating Distances to Transmission Lines (Corrected)
#--------------------------------------------------------------------------

transmission_lines <- st_read("C:\\Users\\altyyevaa\\Downloads\\Transmission_Lines\\Transmission_Lines.shp")
transmission_lines_proj <- st_transform(transmission_lines, crs = st_crs(parcels_with_distance_clean))

nf1 <- st_nearest_feature(parcels_with_distance_clean, transmission_lines_proj)


# Below creates a one-to-one mapping of each house to the body of water it is closest to
p <- transmission_lines_proj[nf1, ]

dist <- st_distance(parcels_with_distance_clean, p, by_element = TRUE)

# Below adds 2 new columns to houses_filtered2_updated
parcels_with_distance_clean$dist_parcel_to_line <- as.numeric(dist) * 0.000621371
View(parcels_with_distance_clean)

#--------------------------------------------------------------------------
#VISUALIZING THE TRANSMISSION LINES
# Add this code to the end of your script
library(ggplot2)

# First, make sure you have a filtered data frame of just the VA transmission lines
# This code should already be in your script from a previous step
va_boundary <- tigris::states(cb = TRUE) %>% filter(NAME == "Virginia")
va_boundary_proj <- st_transform(va_boundary, crs = st_crs(parcels_with_distance_clean))
lines_va <- st_filter(transmission_lines_proj, va_boundary_proj)


# Now, create the plot

# Make sure you have the necessary libraries
library(leaflet)

# 1. Create a color palette function for the parcels
# This will map the 'dist_parcel_to_line' values to the "YlGnBu" color scheme.
pal <- colorNumeric(
  palette = "YlGnBu",
  domain = parcels_with_distance_clean$dist_parcel_to_line,
  reverse = TRUE # Makes lower values (closer distances) lighter in color
)

# 2. Create the interactive map object
interactive_map <- leaflet() %>%
  # Add a clean base map layer
  addProviderTiles(providers$CartoDB.Positron, group = "Base Map") %>%
  
  # Add the transmission lines layer
  addPolylines(
    data = lines_va,
    color = "green",
    weight = 2,
    opacity = 0.9,
    # Basic popup for the lines
    popup = ~paste("Transmission Line"),
    group = "Transmission Lines"
  ) %>%
  
  # Add the parcels layer
  addPolygons(
    data = parcels_with_distance_clean,
    # Set the fill color using the palette function we created
    fillColor = ~pal(dist_parcel_to_line),
    fillOpacity = 0.7,
    # Remove parcel borders for better performance and a cleaner look
    stroke = FALSE, 
    # Create informative popups that appear on click
    popup = ~paste0(
      "<b>Parcel ID:</b> ", PARCELID, "<br>",
      "<b>Distance to Line:</b> ", round(dist_parcel_to_line, 3), " miles<br>",
      "<b>Price Per Acre:</b> $", prettyNum(round(per_acre, 0), big.mark = ",")
    ),
    group = "Parcels"
  ) %>%
  
  # Add a legend to explain the parcel colors
  addLegend(
    pal = pal,
    values = parcels_with_distance_clean$dist_parcel_to_line,
    title = "Distance (miles)",
    position = "bottomright"
  ) %>%
  
  # Add a layer control box to toggle layers on and off
  addLayersControl(
    overlayGroups = c("Parcels", "Transmission Lines"),
    options = layersControlOptions(collapsed = FALSE)
  )

# 3. Display the map
interactive_map



# Computing the Distance between Solar Facilities and Transmission --------

# Get unique facility names from your parcel data
unique_facility_names <- unique(parcels_with_distance_clean$closest_facility_name)

# Filter your master facility list to get the locations for those specific facilities
relevant_facilities_sf <- facilities_sf %>%
  filter(p_name %in% unique_facility_names)


st_crs(relevant_facilities_sf)
st_crs(transmission_lines_proj)

relevant_facilities_sf <- st_transform(relevant_facilities_sf, crs = st_crs(transmission_lines_proj))
# Find the index of the nearest transmission line for each facility
nearest_line_index <- st_nearest_feature(relevant_facilities_sf, transmission_lines_proj)

# Get the actual geometries of those nearest lines
nearest_lines <- transmission_lines_proj[nearest_line_index, ]

# Calculate the distance from each facility to its nearest line
dist_fac_to_line <- st_distance(relevant_facilities_sf, nearest_lines, by_element = TRUE)

# Convert the distance to miles
dist_fac_to_line_miles <- as.numeric(dist_fac_to_line) * 0.000621371


# Create a simple lookup table: facility name -> distance to line
facility_dist_lookup <- data.frame(
  p_name = relevant_facilities_sf$p_name,
  dist_facility_to_line = dist_fac_to_line_miles
)

# Join the new distances back to your main parcel dataset
parcels_with_distance_clean <- parcels_with_distance_clean %>%
  left_join(
    facility_dist_lookup,
    by = c("closest_facility_name" = "p_name")
  )

# View your final data with the new column
# parcels_clean <- parcels_with_distance_clean %>%
#   select(-c(distance_col, distance_parcel_tline, dist_facility_to_line_mi))
parcels_clean <- parcels_with_distance_clean
View(parcels_clean)

# Compare total rows vs. distinct rows
print(paste("Total rows:", nrow(parcels_clean)))
print(paste("Distinct rows:", nrow(distinct(parcels_clean))))

get_dupes(parcels_clean)


parcels_clean <- parcels_clean %>%
  distinct()

View(parcels_clean)






# Flatness Indicator Code -------------------------------------------------

message("Original CRS of parcels:")
print(st_crs(parcels_clean))


install.packages("terra")
install.packages("elevatr")
# Or, to update all installed packages:
update.packages(ask = FALSE) 
library(terra)     # For raster data (DEM, slope, TRI) - modern, fast alternative to 'raster'
library(elevatr)



# Create a directory for results if it doesn't exist
if (!dir.exists("results")) {
  dir.create("results")
}

virginia_parcels <- parcels_clean

# Define the target projected CRS. UTM Zone 17N (EPSG:26917) is suitable for much of Virginia.
# Units are meters, which is good for slope calculations.
target_crs_epsg <- 26917

if (st_crs(virginia_parcels)$epsg != target_crs_epsg) {
  message(paste0("Reprojecting parcels to EPSG:", target_crs_epsg, " (NAD83 / UTM Zone 17N)..."))
  virginia_parcels <- st_transform(virginia_parcels, crs = target_crs_epsg)
  message("Reprojection complete. New CRS:")
  print(st_crs(virginia_parcels))
} else {
  message("Parcels already in target projected CRS or no reprojection needed.")
}

# --- 1.2 Add Unique ID and Select Relevant Columns ---

message("\nStep 1.2: Preparing parcels for analysis (adding unique ID, PARCELID, county, and cleaning columns)...")

# --- ACTION REQUIRED: REPLACE "YOUR_ACTUAL_COUNTY_COLUMN_NAME" with the correct name ---
# Example: county_col_name <- "CountyName"
county_col_name <- "Location" # <--- **YOU MUST CHANGE THIS!**

# --- Part 1: Ensure unique_row_id exists and identify join_id_column ---
if (!"unique_row_id" %in% names(virginia_parcels)) {
  # If unique_row_id doesn't exist, create it.
  virginia_parcels <- virginia_parcels %>%
    mutate(unique_row_id = 1:n())
  message("Created 'unique_row_id' column for robust joining.")
} else {
  message("'unique_row_id' column already exists.")
}

# The primary join ID will ALWAYS be unique_row_id, as PARCELID is not unique (based on your earlier output)
join_id_column <- "unique_row_id"
message(paste0("Using '", join_id_column, "' for all joins."))


# --- Part 2: Select the desired columns for virginia_parcels_clean ---
# Start with the essential unique_row_id and geometry
cols_to_select <- c("unique_row_id", "geometry")

# Conditionally add PARCELID if it exists in the original data
if ("PARCELID" %in% names(virginia_parcels)) {
  cols_to_select <- c(cols_to_select, "PARCELID")
  message("Retaining 'PARCELID' column.")
} else {
  warning("WARNING: 'PARCELID' column not found in original parcel data.")
}

# Conditionally add the specified county column if it exists in the original data
if (county_col_name %in% names(virginia_parcels)) {
  cols_to_select <- c(cols_to_select, county_col_name)
  message(paste0("Retaining county column: '", county_col_name, "'."))
} else {
  warning(paste0("WARNING: County column '", county_col_name, "' not found in original parcel data. Will not be included in analysis."))
  # If you *need* the county column to exist later, you could add a stop() here instead.
}

# Perform the selection to create virginia_parcels_clean
virginia_parcels_clean <- virginia_parcels %>%
  select(!!!syms(cols_to_select)) # Use !!!syms() for dynamic column selection

message("Parcels data prepared with selected columns. Number of parcels:", nrow(virginia_parcels_clean))
print(head(virginia_parcels_clean))

# --- End of Step 1.2 ---


# --- 2. Acquire Digital Elevation Model (DEM) Data ---

dem_zoom_level <- 12 # Start with a lower 'z' if you had size issues

message(paste0("\nStep 2: Downloading DEM data for parcels at zoom level z=", dem_zoom_level, ". This may take a while..."))
tryCatch({
  dem_raster_raw <- get_elev_raster( # Renamed to dem_raster_raw for clarity of conversion
    locations = virginia_parcels_clean,
    z = dem_zoom_level,
    src = "aws"
  )
  # Explicitly convert to SpatRaster if it's not already (best practice for terra)
  if (!inherits(dem_raster_raw, "SpatRaster")) {
    dem_raster <- terra::rast(dem_raster_raw)
    message("Converted raw DEM to SpatRaster.")
  } else {
    dem_raster <- dem_raster_raw # If already SpatRaster, just assign
  }
  
  message("DEM download complete.")
  print(dem_raster) # Print the SpatRaster object
}, error = function(e) {
  stop(paste("Error downloading DEM data:", e$message, "\nTry a lower 'z' value if download fails repeatedly, or check your internet connection."))
})


# --- 3. Calculate Terrain Metrics from the DEM ---

message("\nStep 3: Calculating terrain metrics (Slope, TRI, TPI) from DEM...")

# Now, dem_raster is guaranteed to be a SpatRaster, so terra::terrain will work correctly
message("Calculating Slope (Degrees)...")
slope_raster <- terra::terrain(dem_raster, v = "slope", unit = "degrees", neighbors = 8)

message("Calculating Terrain Ruggedness Index (TRI)...")
tri_raster <- terra::terrain(dem_raster, v = "TRI", neighbors = 8)

message("Calculating Topographic Position Index (TPI)...")
tpi_raster <- terra::terrain(dem_raster, v = "TPI", neighbors = 8)

message("Terrain metrics calculated.")


# --- 4. Extract/Summarize Raster Values Per Parcel (Zonal Statistics) ---


message("\nStep 4: Extracting zonal statistics for each parcel...")

# Convert sf object to SpatVector for terra functions (this is correct)
parcels_spatvec <- vect(virginia_parcels_clean)

# Define a custom function for elevation statistics
get_elev_stats <- function(x, ...) {
  # Remove NA values first, to ensure robust stats calculation
  x_clean <- x[!is.na(x)]
  
  # If no valid data after NA removal, return NAs for all stats
  if (length(x_clean) == 0) {
    return(c(min_elev = NA_real_, max_elev = NA_real_, mean_elev = NA_real_, sd_elev = NA_real_, range_elev = NA_real_))
  }
  
  # Calculate SD robustly: if one value or all same values, SD is 0
  sd_val <- if (length(unique(x_clean)) <= 1) 0 else sd(x_clean)
  
  c(
    min_elev = min(x_clean),
    max_elev = max(x_clean),
    mean_elev = mean(x_clean),
    sd_elev = sd_val,
    range_elev = max(x_clean) - min(x_clean)
  )
}


# Extract statistics for each raster type
message("  - Extracting slope statistics...")
parcel_slope_stats_raw <- terra::extract(slope_raster, parcels_spatvec, fun = mean, na.rm = TRUE, ID = FALSE)
parcel_slope_stats <- as_tibble(parcel_slope_stats_raw)
names(parcel_slope_stats) <- "mean_slope_deg" # This one is simple and should be fine

message("  - Extracting TRI statistics...")
parcel_tri_stats_raw <- terra::extract(tri_raster, parcels_spatvec, fun = mean, na.rm = TRUE, ID = FALSE)
parcel_tri_stats <- as_tibble(parcel_tri_stats_raw)

names(parcel_tri_stats) <- "mean_tri"

message("  - Extracting TPI statistics...")
parcel_tpi_stats_raw <- terra::extract(tpi_raster, parcels_spatvec, fun = mean, na.rm = TRUE, ID = FALSE)
parcel_tpi_stats <- as_tibble(parcel_tpi_stats_raw)
names(parcel_tpi_stats) <- "mean_tpi"

message("  - Extracting elevation statistics...")
parcel_elevation_stats_raw <- terra::extract(dem_raster, parcels_spatvec, fun = get_elev_stats, na.rm = TRUE, ID = FALSE)
parcel_elevation_stats <- as_tibble(parcel_elevation_stats_raw)

# *** IMPORTANT FIX HERE: Manually set the column names for elevation stats ***
# This ensures that even if terra::extract or as_tibble doesn't auto-name, they are correct.
names(parcel_elevation_stats) <- c("min_elev", "max_elev", "mean_elev", "sd_elev", "range_elev") # <--- ADD THIS LINE

message("Zonal statistics extraction complete.")

# ... (Rest of Step 5 and 6 remain the same, but they will now find the correct column names) ...
# --- 5. Join Statistics Back to Parcels ---

message("\nStep 5: Joining calculated statistics back to parcel data...")

# Now, parcel_slope_stats and others are tibbles, so dplyr::left_join will work correctly.
# Add the join_id_column back to these data frames for a robust join.
parcel_slope_stats[[join_id_column]] <- virginia_parcels_clean[[join_id_column]]
parcel_tri_stats[[join_id_column]] <- virginia_parcels_clean[[join_id_column]]
parcel_tpi_stats[[join_id_column]] <- virginia_parcels_clean[[join_id_column]]
parcel_elevation_stats[[join_id_column]] <- virginia_parcels_clean[[join_id_column]]


# Perform the joins using the determined 'join_id_column'
virginia_parcels_flatness <- virginia_parcels_clean %>%
  left_join(parcel_slope_stats, by = join_id_column) %>%
  left_join(parcel_tri_stats, by = join_id_column) %>%
  left_join(parcel_tpi_stats, by = join_id_column) %>%
  left_join(parcel_elevation_stats, by = join_id_column)

message("Statistics successfully joined to parcel data.")
print(head(virginia_parcels_flatness))

message("\nDebugging: Checking columns in virginia_parcels_flatness:")
print(names(virginia_parcels_flatness))

# Also check the structure of parcel_elevation_stats immediately after it's created in Step 4
# You can temporarily add this right after:
# parcel_elevation_stats <- as_tibble(parcel_elevation_stats_raw) # <--- ADD THIS CONVERSION
# print(head(parcel_elevation_stats)) # Debugging line
# print(names(parcel_elevation_stats)) # Debugging line

# --- 6. Define and Calculate Your "Flatness Score" ---

message("\nStep 6: Calculating composite flatness score and categories...")

# Handle potential NaNs that can occur if a parcel is tiny or has no data
virginia_parcels_flatness <- virginia_parcels_flatness %>%
  mutate(across(c(mean_slope_deg, mean_tri, sd_elev, mean_tpi, min_elev, max_elev, range_elev),
                ~replace_na(., 0))) # Replace NA with 0 for calculations (or another suitable value)


# Example 1: Simple Flatness Category based on Mean Slope
virginia_parcels_flatness <- virginia_parcels_flatness %>%
  mutate(
    flatness_category_slope = cut(mean_slope_deg,
                                  breaks = c(-Inf, 2, 5, 10, 20, Inf), # Define your thresholds
                                  labels = c("Very Flat (<2°)", "Flat (2-5°)", "Gently Rolling (5-10°)", "Rolling (10-20°)", "Steep (>20°)"),
                                  right = FALSE, # Left-inclusive, e.g., [2,5)
                                  include.lowest = TRUE)
  )

# Example 2: Composite Flatness Index (0-100, higher is flatter)
# This requires scaling your metrics so they contribute equally or as desired.

# Find the max for scaling, excluding Inf if any
# Using pmax(0, ...) to ensure non-negative values for max calculation
max_slope <- max(virginia_parcels_flatness$mean_slope_deg, na.rm = TRUE)
max_tri <- max(virginia_parcels_flatness$mean_tri, na.rm = TRUE)
max_sd_elev <- max(virginia_parcels_flatness$sd_elev, na.rm = TRUE)
max_tpi_abs <- max(abs(virginia_parcels_flatness$mean_tpi), na.rm = TRUE) # Absolute value for TPI

# Add a small constant to denominators to prevent division by zero if all values are 0
epsilon <- 1e-6

virginia_parcels_flatness <- virginia_parcels_flatness %>%
  mutate(
    # Scale metrics to a 0-1 range. Inverse for those where lower is flatter.
    scaled_slope = (mean_slope_deg / (max_slope + epsilon)),
    scaled_tri = (mean_tri / (max_tri + epsilon)),
    scaled_sd_elev = (sd_elev / (max_sd_elev + epsilon)),
    scaled_tpi_inverted = 1 - (abs(mean_tpi) / (max_tpi_abs + epsilon)), # TPI: 0 is flat, so invert absolute value
    
    # Calculate composite score (weights are subjective, adjust as needed)
    # Higher score = flatter
    composite_flatness_score = (
      (1 - scaled_slope) * 0.40 +        # Slope is often the most direct indicator (40% weight)
        (1 - scaled_tri) * 0.25 +         # TRI adds roughness (25% weight)
        (1 - scaled_sd_elev) * 0.25 +     # SD of elevation adds overall variability (25% weight)
        scaled_tpi_inverted * 0.10        # TPI adds positional context (10% weight)
    ) * 100 # Scale to 0-100
  ) %>%
  # Cap the composite score to ensure it's within 0-100, handling any edge cases
  mutate(composite_flatness_score = pmax(0, pmin(100, composite_flatness_score)))


message("Flatness scores calculated.")
print(head(virginia_parcels_flatness))


# --- 7. Visualize Results (Optional) ---

message("\nStep 7: Generating flatness visualizations (check your R plots window)...")

# Plot by mean slope
tryCatch({
  ggplot(virginia_parcels_flatness) +
    geom_sf(aes(fill = mean_slope_deg), color = NA) +
    scale_fill_viridis_c(option = "plasma", direction = -1, name = "Mean Slope (Degrees)") + # -1 for flatter = lighter/greener
    labs(title = "Virginia Parcels: Mean Slope as Flatness Indicator",
         caption = paste0("DEM Source: USGS 3DEP (z=", dem_zoom_level, ")")) +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5), legend.position = "right")
}, error = function(e) {
  message(paste("Could not generate slope plot:", e$message))
})


# Plot by composite flatness score
tryCatch({
  ggplot(virginia_parcels_flatness) +
    geom_sf(aes(fill = composite_flatness_score), color = NA) +
    scale_fill_viridis_c(option = "viridis", name = "Composite Flatness Score (0-100)", direction = 1) + # 1 for higher = greener
    labs(title = "Virginia Parcels: Composite Flatness Score",
         caption = paste0("DEM Source: USGS 3DEP (z=", dem_zoom_level, ")")) +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5), legend.position = "right")
}, error = function(e) {
  message(paste("Could not generate composite flatness plot:", e$message))
})


# --- 8. Save Your Results ---

# Save the updated sf object with all the new flatness attributes
output_path <- "results/virginia_parcels_with_flatness.shp"
message(paste0("\nStep 8: Saving results to: ", output_path))
tryCatch({
  st_write(virginia_parcels_flatness, output_path, append = FALSE, driver = "ESRI Shapefile")
  message("Process complete. Check your output file in the 'results' folder.")
}, error = function(e) {
  stop(paste("Error saving shapefile:", e$message, "\nMake sure 'results' folder exists or check file permissions."))
})

View(virginia_parcels_flatness) 

View(virginia_parcels)


#MERGING Parcels Flatness Score and Virginia Parcels

if (!"unique_row_id" %in% names(virginia_parcels)) {
  virginia_parcels <- virginia_parcels %>%
    mutate(unique_row_id = 1:n())
}

# Select only 'unique_row_id' and 'composite_flatness_score' from virginia_parcels_flatness,
# then remove its geometry to prepare for the join.
flatness_score_column <- virginia_parcels_flatness %>%
  select(unique_row_id, composite_flatness_score) %>%
  st_drop_geometry()

# Perform the left join based on 'unique_row_id'.
# The result will be your original 'virginia_parcels' with the 'composite_flatness_score' column added.
final_virginia_parcels <- virginia_parcels %>%
  left_join(flatness_score_column, by = "unique_row_id")

View(final_virginia_parcels)

library(sf)
# Define the output folder and file name


write.csv(final_virginia_parcels, "results/final_va_parcels.csv")

View(final_va_parcels)
