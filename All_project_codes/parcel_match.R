library(dplyr)
library(sf)
library(readxl)

data <- read.csv("C:\\Users\\altyyevaa\\Desktop\\SOLAR_PROJECT_FILES\\raw_data_file.csv", fileEncoding = 'latin1')
shape <- read_sf("C:\\Users\\altyyevaa\\Downloads\\VirginiaParcel.shp")

conversions <- read_excel("C:\\Users\\altyyevaa\\Downloads\\messy.xlsx")

datax <- data[which(data$PIN != ""),]

locs <- c()

for (i in 1:nrow(datax)) {
  print(i)
  locs <- c(locs, conversions$Clean[which(conversions$Messy == datax$Location[i])])
}

datax$LOCALITY <- locs

datax <- datax %>% arrange(LOCALITY)

parcel_ids <- c()
ptm_ids <- c()

for (l in unique(datax$LOCALITY)[1:10]) {
  print(l)
  dx <- datax %>% filter(LOCALITY == l)
  tmp <- shape %>% filter(LOCALITY == l)
  for (i in 1:nrow(dx)) {
    if (dx$PIN[i] %in% tmp$PARCELID) {
      parcel_ids <- c(parcel_ids, tmp[which(tmp$PARCELID == dx$PIN[i]),]$PARCELID[1])
    } else {
      parcel_ids <- c(parcel_ids, NA)
    }
    if (dx$PIN[i] %in% tmp$PTM_ID) {
      print('yes')
      ptm_ids <- c(ptm_ids, tmp[which(tmp$PTM_ID == dx$PIN[i]),]$PTM_ID[1])
    } else {
      ptm_ids <- c(ptm_ids, NA)
    }
  }
}

