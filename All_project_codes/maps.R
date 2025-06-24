library(tigris)
library(tidycensus)
library(dplyr)
library(ggplot2)
library(sf)
library(scales)

options(tigris_use_cache = TRUE)

# Load shapefile
counties_sf <- counties(state = "VA", cb = TRUE, year = 2022, class = "sf")

# Total Housing Unit Map --------------------------------------------------


# Load ACS: Total Housing Units
va_housing <- get_acs(
  geography = "county",
  state = "VA",
  variables = "B25001_001",  # Total housing units
  year = 2022,
  survey = "acs5",
  geometry = FALSE
)

# Join on GEOID
va_map_data <- counties_sf %>%
  left_join(va_housing, by = "GEOID")

# Plot
ggplot(va_map_data) +
  geom_sf(aes(fill = estimate)) +
  scale_fill_viridis_c(option = "plasma", name = "Housing Units", labels = scales::comma) +
  labs(
    title = "Total Housing Units by County (VA, 2022)",
    caption = "Source: U.S. Census Bureau via tidycensus"
  ) +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    panel.grid.major = element_line(color = "gray90"),
    plot.caption = element_text(hjust = 0.5) 
  )


# Total Population by County ----------------------------------------------

va_county_pop_all <- map_dfr(years, ~{
  get_acs(
    geography = "county", 
    year = .x,
    variables = c(Total = "B01003_001"), 
    state = "VA",
    survey = "acs5",
    output = "wide"
  ) %>%
    mutate(year = .x)  # Add year column to keep track
})

va_counties <- counties(state = "VA", cb = TRUE, year = 2022, class = "sf")

va_pop_map_data <- va_counties %>%
  left_join(va_county_pop_all, by = "GEOID")


ggplot(va_pop_map_data) +
  geom_sf(aes(fill = TotalE)) +
  scale_fill_viridis_c(
    option = "plasma",
    name = "Population",
    labels = comma  # formats 200000 as 200,000
  ) +
  labs(
    title = "Total Population by County (VA, 2022)",
    caption = "Source: U.S. Census Bureau via tidycensus"
  ) +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    plot.caption = element_text(hjust = 0.5)
  )


