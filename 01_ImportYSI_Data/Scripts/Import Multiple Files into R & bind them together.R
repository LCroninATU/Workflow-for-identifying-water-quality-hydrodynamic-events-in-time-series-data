### IMPORT River Owenmore YSI DATA ###

library(data.table)
library(dplyr)
library(lubridate)
library(here)
library(labelled)

## set the timezone (no daylight saving)
Sys.setenv(TZ='UTC')
Sys.timezone()

# Check the wd
here::here()

list.files("../")

# Load the .csv data files
#' **Note: For these files, only data for temperature, specific conductivity and turbidity are valid as only these sensors were calibrated.**
### Watch out for spaces in column names in some txt files if importing by variable name. 
OW061024<-fread("./01_ImportYSI_Data/Data/OW061024.txt",skip=1, header=T,select = c("      Date", "    Time"," Temp","SpCond","Turbid+"))[-1:-2] 
OW221024<-fread("./01_ImportYSI_Data./Data/OW221024.txt",skip=1, header=T,select = c("      Date", "    Time"," Temp","SpCond","Turbid+"))[-1:-2] 

# Combine date and time columns to form DateTime & change from chr to as.POSIXct
OW061024$DateTime<-with(OW061024, dmy(OW061024$`      Date`) + hms(OW061024$`    Time`) )
OW221024$DateTime<-with(OW221024, dmy(OW221024$`      Date`) + hms(OW221024$`    Time`) )
str(OW061024)
str(OW221024)

## Review imported file and remove out-of-the-water-edits i.e. data before sensor was deployed in the river if sensor is running before being deployed, 
# and data after sensor is removed from the river.  Often the sensor will be put into operation to check everything is logging before being deployed in the water. 
OW061024 <- OW061024 %>% filter(DateTime > ymd_hms('2024-10-06 13:40:00'))
# and after removed from river
OW061024 <- OW061024 %>% filter(DateTime < ymd_hms('2024-10-21 17:20:00'))

OW221024 <- OW221024 %>% filter(DateTime > ymd_hms('2024-10-22 17:45:50'))
# and after removed from river
OW221024 <- OW221024 %>% filter(DateTime < ymd_hms('2024-11-05 11:46:50'))

# and similarly if the sensor was checked in situ

## Step 3 combine the loaded csv files ##

# Bind OW061024 and OW221024 to form new object OWCombined
OWCombined<- bind_rows(OW061024, OW221024)
OWCombined


# Rename the column names
OWCombined<-setnames(OWCombined, "Turbid+", "Turbidity")
OWCombined<-setnames(OWCombined," Temp", "Temp")
colnames(OWCombined)


# Change variable format from chr to numeric
str(OWCombined)
OWCombined$SpCond<-as.numeric((OWCombined$SpCond))
OWCombined$`Temp`<-as.numeric((OWCombined$Temp))
OWCombined$Turbidity<-as.numeric((OWCombined$Turbidity))
str(OWCombined)

# NOTE: Continue to script for step 02 to embed source data context and save (export) the tidied dataframe as .csv and .rds files.

# Session information
sessionInfo()
