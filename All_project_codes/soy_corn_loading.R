#### NASS
install.packages("rnassqs")
library(rnassqs)
# go to https://quickstats.nass.usda.gov/api and requeset API key
# Replace "YOUR_API_KEY" with your actual API key
nassqs_auth(key = "86B4FE8E-AA22-3D44-9034-C1648DA1552E")

# Create a query: corn yield, county-level, in Virginia
params <- list(
  commodity_desc = "CORN",
  statisticcat_desc = "YIELD",
  agg_level_desc = "COUNTY",
  state_name = "VIRGINIA"
)
# Retrieve the data
corn_yield_va <- nassqs(params)

# Define the query for soybean yield
params_soybean <- list(
  commodity_desc = "SOYBEANS",
  statisticcat_desc = "YIELD",
  agg_level_desc = "COUNTY",
  state_name = "VIRGINIA"
)

soybean_yield_va <- nassqs(params_soybean)

View(corn_yield_va)
write_csv(corn_yield_va, "raw_data/New_Corn_Data.csv")

write_csv(soybean_yield_va, "raw_data/New_Soy_Data.csv")







