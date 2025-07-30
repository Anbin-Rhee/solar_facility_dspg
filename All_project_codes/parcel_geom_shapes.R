library(tidyverse)
library(stringr)
library(mapview)
library(tigris)
library(dplyr)
library(sf)

transactions <- read.csv('C:\\Users\\altyyevaa\\Downloads\\parcels.csv', fileEncoding = 'latin1')

parcel_shapes <- read_sf('C:\\Users\\altyyevaa\\Downloads\\VirginiaParcel.shp')

  conversions <- read.csv("C:\\Users\\altyyevaa\\Desktop\\SOLAR_PROJECT_FILES\\messy 1.csv")

datax <- transactions[which(transactions$PIN != ""),]

locs <- c()

for (i in 1:nrow(datax)) {
  locs <- c(locs, conversions$Clean[which(conversions$Messy == datax$Location[i])])
}

datax$LOCALITY <- locs

datax <- datax %>% arrange(LOCALITY)

parcel_ids <- c()
ptm_ids <- c()

for (l in unique(datax$LOCALITY)) {
  print(l)
  dx <- datax %>% filter(LOCALITY == l)
  tmp <- parcel_shapes %>% filter(LOCALITY == l)
  for (i in 1:nrow(dx)) {
    if (dx$PIN[i] %in% tmp$PARCELID) {
      parcel_ids <- c(parcel_ids, tmp[which(tmp$PARCELID == dx$PIN[i]),]$PARCELID[1])
    } else {
      parcel_ids <- c(parcel_ids, NA)
    }
    if (dx$PIN[i] %in% tmp$PTM_ID) {
      ptm_ids <- c(ptm_ids, tmp[which(tmp$PTM_ID == dx$PIN[i]),]$PTM_ID[1])
    } else {
      ptm_ids <- c(ptm_ids, NA)
    }
  }
}

datax$PARCELID <- parcel_ids
datax$PTM_ID <- ptm_ids

datax$ID1 <- 1 - as.integer(is.na(datax$PARCELID))
datax$ID2 <- 1 - as.integer(is.na(datax$PTM_ID))
datax$KEEP <- datax$ID1 + datax$ID2

# Subset dataframes


datax <- datax %>% filter(KEEP > 0)
parcel_df <- datax[!is.na(datax$PARCELID),]
ptm_df <- datax[!is.na(datax$PTM_ID),]

# Merge

parcel_df <- left_join(parcel_df, parcel_shapes, by = c('LOCALITY', 'PARCELID'))
ptm_df <- left_join(ptm_df, parcel_shapes, by = c('LOCALITY', 'PTM_ID'))

colnames(parcel_df)[11] <- 'PTM_ID'
colnames(parcel_df)[17] <- 'XXX'
colnames(ptm_df)[10] <- 'PARCELID'
colnames(ptm_df)[17] <- 'XXX'

colnames(parcel_df)
colnames(ptm_df)

final_data <- rbind(parcel_df, ptm_df)
final_data <- final_data[!duplicated(final_data),]

# Save space

rm(parcel_shapes)

# View

plot(final_data$geometry)
