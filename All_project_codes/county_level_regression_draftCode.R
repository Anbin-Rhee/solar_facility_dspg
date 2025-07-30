#Preliminary Model Code: Simple Linear Regression

#Goal: Build a regression model to predict land price at county-year level as a function of whether a solar facility exists in that county-year, 
#accounting for parcel size (acres) and transaction frequency

## Date: 6/11/2025 
library(readxl)
library(readr)
library(dplyr)
library(ggplot2)
library(stringr)


#reading the raw data 
raw_trans <- read_excel("C:/Users/altyyevaa/Desktop/SOLAR_PROJECT_FILES/raw_data_file.xlsx")
View(raw_trans)

colnames(raw_trans)
filtered_trans <- raw_trans %>%
  filter(Acres >= 20.0) %>%
  mutate(
    Location = str_to_upper(str_trim(str_replace_all(Location, regex("\\bcounty\\b", ignore_case = TRUE), "")))
  ) %>%
  rename(trans_year = year)

  

View(filtered_trans)

solar_data <- read_excel("C:/Users/altyyevaa/Desktop/SOLAR_PROJECT_FILES/Solar_facility_VA - Copy.xlsx")
View(solar_data)


# # solar_subset <- solar_data %>%
#   select(p_county, p_year)
# 
# trans_subset <- filtered_trans %>% 
#   select(Location, year)
# 
# solar_county_padded <- c(solar_subset$p_county, rep(NA, 19427 - nrow(solar_subset)))
# solar_year_padded <- c(solar_subset$p_year, rep(NA, 19427 - nrow(solar_subset)))
# 
# 
# final_data <- tibble(
#   solar_county = solar_county_padded,
#   trans_county = trans_subset$Location,
#   solar_year = solar_year_padded,
#   trans_year = trans_subset$year
# )
# 
# View(final_data)


# trans_summary <- filtered_trans %>%
#   group_by(Location, year) %>%
#   summarise(transaction_count = n(), .groups = "drop")
# 
# 
# solar_summary <- solar_data %>%
#   select(p_county, p_year) %>%
#   mutate(has_solar = 1) %>%
#   distinct() %>%
#   rename(Location = p_county, year = p_year)
# 
# 
# final_data <- trans_summary %>%
#   left_join(solar_summary, by = c("Location", "year")) %>%
#   mutate(has_solar = ifelse(is.na(has_solar), 0, 1))
# 
# View(final_data)



# 1. Clean solar data
solar_summary <- solar_data %>%
  select(p_county, p_year) %>%
  rename(Location = p_county, solar_year = p_year) %>%
  mutate(Location = str_to_upper(str_trim(str_replace_all(Location, regex("county", ignore_case = TRUE), "")))) %>%
  group_by(Location) %>%
  summarise(solar_year = min(solar_year), .groups = "drop")  


# 2. Join directly with transaction-level data (filtered_trans)
final_data <- filtered_trans %>%
  left_join(solar_summary, by = "Location") %>%
  mutate(has_solar = ifelse(!is.na(solar_year) & trans_year >= solar_year, 1, 0))

final_solar_data <- final_data %>%
  mutate(solar_county = ifelse(Location %in% solar_summary$Location, 1, 0))
nrow(final_data) == nrow(filtered_trans)  

View(final_solar_data)
table(final_solar_data$solar_county)


final_solar_data %>%
  filter(solar_county == 1) %>%
  distinct(Location) %>%
  nrow()

final_solar_data %>%
  filter(is.na(per_acre) | per_acre <= 0)


clean_data <- final_solar_data %>%
  filter(!is.na(per_acre) & per_acre > 0)




regression <- lm(log(per_acre) ~ solar_county * has_solar, data = clean_data)
summary(regression)

View(final_solar_data)

#the county with solar facility turned out to be less land value?
#has_solar 

regression2 <- lm(log(per_acre) ~ solar_county * has_solar+factor(trans_year)+factor(Location), data = clean_data)
summary(regression2)


#Summary:
# Compare to the baseline county (Year 2010), the log of price per acre in 2012 increases by  0.085902
# That is, land prices in 2012 were about exp( 0.085902) = 1.0897 times higher than in 2010

# Compared to the baseline county(Accomack county), log of land price per acre in AMHERST is 0.185053 higher
# Land in AMELIA is about exp(0.185053 ) = 1.203282 times higher than in ACCOMACK county


#Louisa Bar Chart
louisa <- filtered_trans %>%
  filter(Location == 'LOUISA')%>%
  group_by(trans_year) %>%
  summarize(num_trans = n()) 

View(louisa)

ggplot(louisa, aes(x= factor(trans_year), y = num_trans)) +
  geom_bar(stat="identity", fill = "#8e8bf2")+
  geom_vline(xintercept = c("2016", "2018", "2022"), color = "black", linetype = "dashed", size = 1)+
  labs(x = "Transaction Year", y = "Number of Transactions", title = "Number of Transactions by year in Louisa County")


#Spotsylvania Bar Chart
spotsylvania <- filtered_trans %>%
  filter (Location == "SPOTSYLVANIA") %>%
  group_by(trans_year) %>%
  summarize(num_trans = n())

View(spotsylvania)



ggplot(spotsylvania, aes( x = factor(trans_year), y  = num_trans)) +
  geom_bar(stat = "identity", fill = "#ebbd61")+
  geom_vline(xintercept = "2022", color = "black", linetype = "dashed", size = 2)+
  labs(x = "Transaction Year", y = "Number of Transactions", title = "Number of Transactions by year in Spotsylvania County" )
  

#Albemarle County

albemarle <- filtered_trans %>%
  filter (Location == "ALBEMARLE") %>%
  group_by(trans_year) %>%
  summarize(num_trans = n())

View(albemarle)


ggplot(albemarle, aes( x = factor(trans_year), y  = num_trans)) +
  geom_bar(stat = "identity", fill = "#609763")+
  labs(x = "Transaction Year", y = "Number of Transactions", title = "Number of Transactions by year in Albemarle County" )



#Fluvanna C

fluvanna <- filtered_trans %>%
  filter (Location == "FLUVANNA") %>%
  group_by(trans_year) %>%
  summarize(num_trans = n())

View(fluvanna)


ggplot(fluvanna, aes( x = factor(trans_year), y  = num_trans)) +
  geom_bar(stat = "identity", fill = "#c83131")+
  geom_vline(xintercept = c("2023", "2016"), color = "black", linetype = "dashed", size = 1)+
  labs(x = "Transaction Year", y = "Number of Transactions", title = "Number of Transactions by year in Fluvanna County" )





# Average Price Per Acre --------------------------------------------------

average_price <- filtered_trans %>%
  filter(Location== "LOUISA") %>%
  group_by(trans_year) %>%
  summarize(average_price_per_acre = mean(per_acre, na.rm=TRUE))

print(average_price)

ggplot(average_price, aes( x = factor(trans_year), y = average_price_per_acre))+
  geom_bar(stat = "identity",  fill = "#8e8bf2")+
  geom_vline(xintercept = c("2016", "2018", "2022"), color = "black", linetype = "dashed", size = 1)+
  labs(x = "Transaction Year", y = "Average Price Per Acre", title = "Average Price per Acre by Year in Louisa County" )
  

#Spotsylvania County
average_price <- filtered_trans %>%
  filter(Location== "SPOTSYLVANIA") %>%
  group_by(trans_year) %>%
  summarize(average_price_per_acre = mean(per_acre, na.rm=TRUE))

print(average_price)

ggplot(average_price, aes( x = factor(trans_year), y = average_price_per_acre))+
  geom_bar(stat = "identity",  fill = "#ebbd61")+
  geom_vline(xintercept = "2022", color = "black", linetype = "dashed", size = 2)+
  labs(x = "Transaction Year", y = "Average Price Per Acre", title = "Average Price per Acre by Year in Spotsylvania County" )

#Albemarle County
average_price <- filtered_trans %>%
  filter(Location== "ALBEMARLE") %>%
  group_by(trans_year) %>%
  summarize(average_price_per_acre = mean(per_acre, na.rm=TRUE))

print(average_price)

ggplot(average_price, aes( x = factor(trans_year), y = average_price_per_acre))+
  geom_bar(stat = "identity",  fill = "#609763")+
  labs(x = "Transaction Year", y = "Average Price Per Acre", title = "Average Price per Acre by Year in Albemarle County" )


#Fluvanna County
average_price <- filtered_trans %>%
  filter(Location== "FLUVANNA") %>%
  group_by(trans_year) %>%
  summarize(average_price_per_acre = mean(per_acre, na.rm=TRUE))

print(average_price)

ggplot(average_price, aes( x = factor(trans_year), y = average_price_per_acre))+
  geom_bar(stat = "identity",  fill = "#c83131")+
  geom_vline(xintercept = c("2023", "2016"), color = "black", linetype = "dashed", size = 1)+
  labs(x = "Transaction Year", y = "Average Price Per Acre", title = "Average Price per Acre by Year in Fluvanna County" )



# Average Acres by County -------------------------------------------------

#Louisa County
average_acres <- filtered_trans %>%
  filter(Location == "LOUISA") %>%
  group_by(trans_year) %>%
  summarize (average_acres_size = mean(Acres, na.rm = TRUE))

print(average_acres)

ggplot(average_acres, aes(x = factor(trans_year), y = average_acres_size)) +
    geom_bar(stat = "identity", fill = "#8e8bf2")+
  geom_vline(xintercept = c("2016", "2018", "2022"), color = "black", linetype = "dashed", size = 1)+
  labs(x = "Transaction Year", y = "Average Acre Size", title = "Average Acre Size by Year in Louisa County" )


#Spotsylvania County
average_acres <- filtered_trans %>%
  filter(Location == "SPOTSYLVANIA") %>%
  group_by(trans_year) %>%
  summarize (average_acres_size = mean(Acres, na.rm = TRUE))

print(average_acres)

ggplot(average_acres, aes(x = factor(trans_year), y = average_acres_size)) +
  geom_bar(stat = "identity", fill = "#ebbd61")+
  geom_vline(xintercept = "2022", color = "black", linetype = "dashed", size = 2)+
  labs(x = "Transaction Year", y = "Average Acre Size", title = "Average Acre Size by Year in Spotsylvania County" )

check_spotsylvania <- filtered_trans %>%
  filter(Location =="SPOTSYLVANIA") %>%
  group_by(trans_year)
View(check_spotsylvania)



#Albemarle County
#Spotsylvania County
average_acres <- filtered_trans %>%
  filter(Location == "ALBEMARLE") %>%
  group_by(trans_year) %>%
  summarize (average_acres_size = mean(Acres, na.rm = TRUE))

print(average_acres)

ggplot(average_acres, aes(x = factor(trans_year), y = average_acres_size)) +
  geom_bar(stat = "identity", fill = "#609763")+
  labs(x = "Transaction Year", y = "Average Acre Size", title = "Average Acre Size by Year in Albemarle County" )




#Fluvanna County
average_acres <- filtered_trans %>%
  filter(Location == "FLUVANNA") %>%
  group_by(trans_year) %>%
  summarize (average_acres_size = mean(Acres, na.rm = TRUE))

print(average_acres)

ggplot(average_acres, aes(x = factor(trans_year), y = average_acres_size)) +
  geom_bar(stat = "identity", fill = "#c83131")+
  geom_vline(xintercept = c("2023", "2016"), color = "black", linetype = "dashed", size = 1)+
  labs(x = "Transaction Year", y = "Average Acre Size", title = "Average Acre Size by Year in Fluvanna County" )




temp <- filtered_trans %>%
  filter(Location=="LOUISA")
View(temp)
