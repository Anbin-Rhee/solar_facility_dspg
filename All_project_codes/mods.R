# This script runs regressions for hte 2025 DSPG solar project

# Loading libraries
#install.packages("lmtest")
#install.packages("sandwich")
library(stargazer)
library(dplyr)
library(lmtest)
library(tigris)
library(sandwich)
library(sf)

# Read in data (I was lazy and left the data in downloads - judge me)

data <- read.csv('clean_data/merged_data.csv')

# Remove transactions where the price was zero

datax <- data %>% filter(Price_Per_Acre > 0)

# Remove outliers (top and bottom percentile)

upper <- quantile(datax$Price_Per_Acre, c(.99), na.rm = TRUE)
lower <- quantile(datax$Price_Per_Acre, c(.01), na.rm = TRUE)
datax <- datax[which(datax$Price_Per_Acre <= upper & datax$Price_Per_Acre >= lower),]

# Run regressions

mod1 <- lm(log(Price_Per_Acre) ~ DiD + factor(County) + factor(Year), data = datax)

mod2 <- lm(log(Price_Per_Acre) ~ DiD + log(CornYield) + log(SoyYield) + factor(County) + factor(Year), data = datax)

mod3 <- lm(log(Price_Per_Acre) ~ DiD + log(CornYield) + factor(County) + factor(Year), data = datax)

mod4 <- lm(log(Price_Per_Acre) ~ DiD + log(SoyYield) + factor(County) + factor(Year), data = datax)

mod5 <- lm(log(Price_Per_Acre) ~ DiD + log(CornYield) + log(SoyYield) + log(Population) + log(HousingAge) 
           + log(TotalHousingUnits) + log(VacantUnits) + factor(County) + factor(Year), data = datax)

mod6 <- lm(log(Price_Per_Acre) ~ DiD + log(Population) + log(HousingAge) + log(TotalHousingUnits) + log(VacantUnits) + 
             factor(County) + factor(Year), data = datax)

mod1x <- coeftest(mod1, vcov = vcovCL, cluster = ~County)
mod2x <- coeftest(mod2, vcov = vcovCL, cluster = ~County)
mod3x <- coeftest(mod3, vcov = vcovCL, cluster = ~County)
mod4x <- coeftest(mod4, vcov = vcovCL, cluster = ~County)
mod5x <- coeftest(mod5, vcov = vcovCL, cluster = ~County)
mod6x <- coeftest(mod6, vcov = vcovCL, cluster = ~County)

#stargazer(mod1, mod1x, mod2, mod2x, mod3, mod3x, mod4, mod4x, mod5, mod5x, mod6, mod6x, type = 'text', omit = c('County', 'Year'), omit.stat = c('ser', 'f'))
stargazer(mod1, mod2, mod3, mod4, mod5, mod6, type = 'text', omit = c('County', 'Year'), omit.stat = c('ser', 'f'))
stargazer(mod1x, mod2x, mod3x, mod4x, mod5x, mod6x, type = 'text', omit = c('County', 'Year'), omit.stat = c('ser', 'f'))

# Check if DiD affects controls

dataxx <- datax[,c(1,2,4:14)]
dataxx <- dataxx[!duplicated(dataxx),]

moda <- lm(log(Population) ~ DiD + factor(County) + factor(Year), data = dataxx)
modb <- lm(log(TotalHousingUnits) ~ DiD + factor(County) + factor(Year), data = dataxx)
modc <- lm(log(VacantUnits) ~ DiD + factor(County) + factor(Year), data = dataxx)
modd <- lm(log(CornYield) ~ DiD + factor(County) + factor(Year), data = dataxx)
mode <- lm(log(SoyYield) ~ DiD + factor(County) + factor(Year), data = dataxx)

modax <- coeftest(moda, vcov = vcovCL, cluster = ~County)
modbx <- coeftest(modb, vcov = vcovCL, cluster = ~County)
modcx <- coeftest(modc, vcov = vcovCL, cluster = ~County)
moddx <- coeftest(modd, vcov = vcovCL, cluster = ~County)
modex <- coeftest(mode, vcov = vcovCL, cluster = ~County)

stargazer(moda, modb, modc, modd, mode, type = 'text', omit = c('County', 'Year'), omit.stat = c('ser', 'f'))
stargazer(modax, modbx, modcx, moddx, modex, type = 'text', omit = c('County', 'Year'), omit.stat = c('ser', 'f'))

### Start TIGRIS Shapefile Stuff ###

# Get Virginia counties using tigris

va <- counties(state = 'VA')

# Determining which counties are adjacent for the spillover analysis

adjacencies <- st_touches(va) # Gets the rows from va for adjacent counties

# Create a new column for merging

good_names <- unique(datax$County)[which(unique(datax$County) %in% va$NAME)]

new_names <- c()

for (i in 1:nrow(datax)) {
  if (datax$County[i] %in% good_names) {
    new_names <- c(new_names, datax$County[i])
  } else if (datax$County[i] == 'King And Queen') {
    new_names <- c(new_names, 'King and Queen')
  }else if (datax$County[i] == 'Isle Of Wight') {
    new_names <- c(new_names, 'Isle of Wight')
  } else {
    new_names <- c(new_names, substr(datax$County[i], 1, nchar(datax$County[i])-5))
  }
}

datax$County2 <- new_names

# Initialize a matrix

A <- matrix(0, nrow(va), nrow(va)) # Initialize an empty matrix

# Fill in the matrix

for (i in 1:(nrow(va)-1)) {
  for (j in (i+1):nrow(va)) {
    if (j %in% adjacencies[[i]]) {
      A[i,j] <- 1
      A[j,i] <- 1
    }
  }
}

# For loop to create what we want

spillovers <- c()

for (i in 1:nrow(datax)) {
  print(i)
  yr <- datax$Year[i]
  if (datax$County2[i] %in% c('Fairfax', 'Franklin', 'Richmond', 'Roanoke')) {
    idx <- which(va$NAME == datax$County2[i])[2]
  } else {
    idx <- which(va$NAME == datax$County2[i])
  }
  ads <- adjacencies[[idx]]
  ad.names <- va$NAME[ads]
  val <- 0
  for (n in ad.names) {
    tmp <- datax %>% filter(Year == yr) %>% filter(County2 == n)
    if (nrow(tmp) > 0) {
      val <- val + tmp$DiD[1]
    }
  }
  spillovers <- c(spillovers, val)
}

datax$Spillovers <- spillovers
datax$Spill_Binary <- as.integer(datax$Spillovers > 0)

# Running regressions with spillovers

smod1 <- lm(log(Price_Per_Acre) ~ DiD + Spillovers + factor(County) + factor(Year), data = datax)

smod2 <- lm(log(Price_Per_Acre) ~ DiD + Spillovers + log(CornYield) + log(SoyYield) + factor(County) + factor(Year), data = datax)

smod3 <- lm(log(Price_Per_Acre) ~ DiD + Spillovers + log(CornYield) + factor(County) + factor(Year), data = datax)

smod4 <- lm(log(Price_Per_Acre) ~ DiD + Spillovers + log(SoyYield) + factor(County) + factor(Year), data = datax)

smod5 <- lm(log(Price_Per_Acre) ~ DiD + Spillovers + log(CornYield) + log(SoyYield) + log(Population) + log(HousingAge) 
            + log(TotalHousingUnits) + log(VacantUnits) + factor(County) + factor(Year), data = datax)

smod6 <- lm(log(Price_Per_Acre) ~ DiD + Spillovers + log(Population) + log(HousingAge) + log(TotalHousingUnits) + log(VacantUnits) + factor(County) + factor(Year), data = datax)

smod1x <- coeftest(smod1, vcov = vcovCL, cluster = ~County)
smod2x <- coeftest(smod2, vcov = vcovCL, cluster = ~County)
smod3x <- coeftest(smod3, vcov = vcovCL, cluster = ~County)
smod4x <- coeftest(smod4, vcov = vcovCL, cluster = ~County)
smod5x <- coeftest(smod5, vcov = vcovCL, cluster = ~County)
smod6x <- coeftest(smod6, vcov = vcovCL, cluster = ~County)

#stargazer(mod1, mod1x, mod2, mod2x, mod3, mod3x, mod4, mod4x, mod5, mod5x, mod6, mod6x, type = 'text', omit = c('County', 'Year'), omit.stat = c('ser', 'f'))
stargazer(smod1, smod2, smod3, smod4, smod5, smod6, type = 'text', omit = c('County', 'Year'), omit.stat = c('ser', 'f'))
stargazer(smod1x, smod2x, smod3x, smod4x, smod5x, smod6x, type = 'text', omit = c('County', 'Year'), omit.stat = c('ser', 'f'))

# Binary spillovers

ssmod1 <- lm(log(Price_Per_Acre) ~ DiD + Spill_Binary + factor(County) + factor(Year), data = datax)

ssmod2 <- lm(log(Price_Per_Acre) ~ DiD + Spill_Binary + log(CornYield) + log(SoyYield) + factor(County) + factor(Year), data = datax)

ssmod3 <- lm(log(Price_Per_Acre) ~ DiD + Spill_Binary + log(CornYield) + factor(County) + factor(Year), data = datax)

ssmod4 <- lm(log(Price_Per_Acre) ~ DiD + Spill_Binary + log(SoyYield) + factor(County) + factor(Year), data = datax)

ssmod5 <- lm(log(Price_Per_Acre) ~ DiD + Spill_Binary + log(CornYield) + log(SoyYield) + log(Population) + log(HousingAge) 
             + log(TotalHousingUnits) + log(VacantUnits) + factor(County) + factor(Year), data = datax)

ssmod6 <- lm(log(Price_Per_Acre) ~ DiD + Spill_Binary + log(Population) + log(HousingAge) + log(TotalHousingUnits) + log(VacantUnits) + factor(County) + factor(Year), data = datax)

ssmod1x <- coeftest(ssmod1, vcov = vcovCL, cluster = ~County)
ssmod2x <- coeftest(ssmod2, vcov = vcovCL, cluster = ~County)
ssmod3x <- coeftest(ssmod3, vcov = vcovCL, cluster = ~County)
ssmod4x <- coeftest(ssmod4, vcov = vcovCL, cluster = ~County)
ssmod5x <- coeftest(ssmod5, vcov = vcovCL, cluster = ~County)
ssmod6x <- coeftest(ssmod6, vcov = vcovCL, cluster = ~County)

#stargazer(mod1, mod1x, mod2, mod2x, mod3, mod3x, mod4, mod4x, mod5, mod5x, mod6, mod6x, type = 'text', omit = c('County', 'Year'), omit.stat = c('ser', 'f'))
stargazer(ssmod1, ssmod2, ssmod3, ssmod4, ssmod5, ssmod6, type = 'text', omit = c('County', 'Year'), omit.stat = c('ser', 'f'))
stargazer(ssmod1x, ssmod2x, ssmod3x, ssmod4x, ssmod5x, ssmod6x, type = 'text', omit = c('County', 'Year'), omit.stat = c('ser', 'f'))
