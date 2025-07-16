# Load the libraries for your session
library(sf)
library(ggplot2)
library(leaflet)
library(dplyr)


my_data <- st_read("C:\\Users\\altyyevaa\\Downloads\\County-Level Shapefiles\\County-Level Shapefiles\\TNC_VASolarAnalysis_County_50acres\\TNC_VASolarAnalysis_County_50acres.shp")

# --- Explore the data ---

# Print the header and information (coordinate system, geometry type, etc.)
print(my_data)

# View the attribute table as a regular data frame
# The 'geometry' column holds the spatial data
head(my_data)



#VISUALIZATIONS 
# Transform the projection for a better-looking US map
my_data_transformed <- st_transform(my_data, crs = 5070)

# Now plot the transformed data
ggplot(data = my_data_transformed) +
  geom_sf() +
  theme_void() # A clean theme with no axes or gridlines


colnames(my_data)


ggplot(data = my_data_transformed) +
  # Use CV_ACRE for the fill color. The color of the borders is set to white.
  geom_sf(aes(fill = CV_ACRE), color = "white", size = 0.1) +
  
  # Use a color-blind friendly palette that's good for continuous data
  scale_fill_viridis_c(option = "plasma") +
  
  # Add labels and use a clean theme
  labs(title = "Solar Farm Suitability by County",
       subtitle = "Based on 'CV_ACRE' values",
       fill = "Suitable Acres") +
  theme_void()




