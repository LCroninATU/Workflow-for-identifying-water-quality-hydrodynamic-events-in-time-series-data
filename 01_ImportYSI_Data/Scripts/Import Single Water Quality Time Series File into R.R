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


# Import the .csv data file #
OW061024<-fread("./Data/OW061024.txt",skip=1, header=T,select = c("      Date", "    Time"," Temp","SpCond","Turbid+"))[-1:-2] 
str(OW061024)
class(OW061024)

# OR If you don't want to select particular variables when importing, Alternatively import the entire file and then subset for the variables of interest.
# Import the data file
OW061024<-fread("./Data/OW061024.txt",skip=1, header=T,)[-1:-2] 
str(OW061024)
class(OW061024)
# Display the column names to have exact column name when choosing columns of interest.
colnames(OW061024)
# Subset for the variables of interest by dropping each column not required.
OW061024$` Cond`<-NULL
OW061024$`  TDS`<-NULL
OW061024$`   Sal`<-NULL
OW061024$`  Press`<-NULL
OW061024$`  Depth`<-NULL
OW061024$`   pH`<-NULL
OW061024$`     pH`<-NULL
OW061024$`  Chl`<-NULL
OW061024$`  Chl`<-NULL
OW061024$Battery<-NULL
# View the dataframe to see what variables have been removed. 
View(OW061024)


# Combine date and time columns to form DateTime & change from chr to as.POSIXct
OW061024$DateTime<-with(OW061024, dmy(OW061024$`      Date`) + hms(OW061024$`    Time`) )
str(OW061024)

# Rename the column names
OW061024<-setnames(OW061024, "Turbid+", "Turbidity")
OW061024<-setnames(OW061024," Temp", "Temp")
colnames(OW061024)

## Review imported file and remove data for before sensor deployed in the river if sensor is running before being deployed and after being removed##
OW061024 <- OW061024 %>% filter(DateTime > ymd_hms('2024-10-06 13:40:00'))
# and after removed from river
OW061024 <- OW061024 %>% filter(DateTime < ymd_hms('2024-10-21 17:20:00'))

# and similarly if the sensor was checked in situ


# Change variable format from chr to numeric
str(OW061024)
OW061024$SpCond<-as.numeric((OW061024$SpCond))
OW061024$Temp<-as.numeric((OW061024$Temp))
OW061024$Turbidity<-as.numeric((OW061024$Turbidity))

# Embed the source data context in the datafile by adding variable labels.

OW061024<-OW061024|>
  labelled::set_variable_labels(
    DateTime = "Measurement Date and Time (GMT) of River Owenmore ",
    Temp = "Temperature (degC) YSI6600EDSV2_2 6560 Conductivity_Temperature Probe",
    SpCond = "Specific Conductance uScm-1 YSI6600EDSV2-2 6560 Conductivity_Temperature Probe",
    Turbidity = "Turbidity (NTU) - YSI_6600_EDS_V2-2 - 6136 Turbidity Probe"
  )

# To view the variable labels
View(OW061024)

# Export the cleaned datafile as .csv to the working directory #
write.table(OW061024,"./Output_Files/OW061024C.csv",row.names=F, sep = ",")

# save the file as RData
saveRDS(OW061024, file = "./Output_Files/OW061024C.RData")
saveRDS(OW061024, file = "./Output_Files/OW061024C.rds")

# Record the Session information
sessionInfo()
