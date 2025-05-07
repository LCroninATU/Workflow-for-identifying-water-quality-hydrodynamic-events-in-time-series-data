### IMPORT DATA ###

# Packages may first need to be installed before loading.

# Load the packages
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

# Import the data file

# **Note: For these files, only data for temperature, specific conductivity and turbidity are valid as only these sensors were calibrated.**

# Import the .csv data file #
OW061024<-fread("01_ImportYSI_Data/Data/OW061024.txt",skip=1, header=T,select = c("      Date", "    Time"," Temp","SpCond","Turbid+"))[-1:-2] 
OW221024<-fread("01_ImportYSI_Data/Data/OW221024.txt",skip=1, header=T,select = c("      Date", "    Time"," Temp","SpCond","Turbid+"))[-1:-2]

# Display the structure of the imported file
str(OW061024)
str(OW221024)
# Display the class or the properties of the imported file, this affects how the imported file interacts with the R code
class(OW061024)
class(OW221024)

# OR If you don't want to select particular variables when importing, Alternatively import the entire file and then subset for the variables of interest.
# **Note: For these files, only data for temperature, specific conductivity and turbidity are valid as only these sensors were calibrated.**
# Import the data file
OW061024<-fread("01_ImportYSI_Data/Data/OW061024.txt",skip=1, header=T,)[-1:-2] 
OW221024<-fread("01_ImportYSI_Data/Data/OW221024.txt",skip=1, header=T)[-1:-2]
str(OW061024)
str(OW221024)
class(OW061024)
class(OW221024)

# Display the column names, this provides the exact column name (including any spaces!) when choosing columns of interest and then drop any unwanted variables by entering NULL against these.
colnames(OW061024)
colnames(OW221024)

# Subset for the variables of interest in OW061024 by dropping each column not required.
OW061024$` Cond`<-NULL
OW061024$`  TDS`<-NULL
OW061024$`   Sal`<-NULL
OW061024$`  Press`<-NULL
OW061024$`  Depth`<-NULL
OW061024$`   pH`<-NULL
OW061024$`     pH`<-NULL
OW061024$`  Chl`<-NULL
OW061024$"  Chl"<-NULL
OW061024$Battery<-NULL

# Subset for the variables of interest in OW221024 by dropping each column not required.
OW221024$` Cond`<-NULL
OW221024$`  TDS`<-NULL
OW221024$`   Sal`<-NULL
OW221024$`  Press`<-NULL
OW221024$`  Depth`<-NULL
OW221024$`   pH`<-NULL
OW221024$`     pH`<-NULL
OW221024$`  Chl`<-NULL
OW221024$"  Chl"<-NULL
OW221024$Battery<-NULL

# View the dataframe to see what variables have been retained (Note there is a number of spaces in the Date, Time and Temp column names). 
str(OW061024)
str(OW221024)


# Tidy the data and format the imported water quality data

#Combine date and time columns to form DateTime & change from chr to as.POSIXct (as.POSIXct stores both a date and time with an associated time zone)
OW061024$DateTime<-with(OW061024, dmy(OW061024$`      Date`) + hms(OW061024$`    Time`) )
OW221024$DateTime<-with(OW221024, dmy(OW221024$`      Date`) + hms(OW221024$`    Time`) )
str(OW061024)
str(OW221024)

# Rename the column names
OW061024<-setnames(OW061024, "Turbid+", "Turbidity")
OW061024<-setnames(OW061024," Temp", "Temp")        # this removes the space in front of Temp
OW221024<-setnames(OW221024, "Turbid+", "Turbidity")
OW221024<-setnames(OW221024," Temp", "Temp")
colnames(OW061024)
colnames(OW221024)

# Change variable format from chr to numeric
str(OW061024)
str(OW221024)
OW061024$SpCond<-as.numeric((OW061024$SpCond))
OW061024$`Temp`<-as.numeric((OW061024$Temp))
OW061024$Turbidity<-as.numeric((OW061024$Turbidity))

OW221024$SpCond<-as.numeric((OW221024$SpCond))
OW221024$`Temp`<-as.numeric((OW221024$Temp))
OW221024$Turbidity<-as.numeric((OW221024$Turbidity))


# View the structure after the format changes
str(OW061024)
str(OW221024)

# Review imported file and if required, remove out-of-the-water-edits i.e. data before sensor was deployed in the river if sensor is running before being deployed, and data after sensor is removed from the river.  Often the sensor will be put into operation to check everything is logging before being deployed in the water. #
# When importing multiple files together you will need to do this for each file imported 
OW061024 <- OW061024 %>% filter(DateTime > ymd_hms('2024-10-06 13:40:00'))
# and after removed from river
OW061024 <- OW061024 %>% filter(DateTime < ymd_hms('2024-10-21 17:20:00'))

OW221024 <- OW221024 %>% filter(DateTime > ymd_hms('2024-10-22 17:45:50'))
# and after removed from river
OW221024 <- OW221024 %>% filter(DateTime < ymd_hms('2024-11-05 11:46:50'))

# and similarly if the sensor was checked in situ during deployment

# Combine the files into a single dataframe if importing multiple files individually.
# To process the data as one file for visualization and event detection, the files need to be joined together.
# Bind OW061024 and OW221024 to form new object OWCombined
OWCombined<- bind_rows(OW061024,OW221024)


# NOTE: Continue to script for step 02 to embed source data context and save (export) the tidied dataframe as .csv and .rds files.
