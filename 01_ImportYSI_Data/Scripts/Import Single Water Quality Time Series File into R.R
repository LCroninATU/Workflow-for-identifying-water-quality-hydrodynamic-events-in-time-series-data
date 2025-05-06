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


# 1.4 Tidy the data and format the imported water quality data

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

# 1.5 Combine the files into a single dataframe if importing multiple files individually.
# To process the data as one file for visualization and event detection, the files need to be joined together.
# Bind OW061024 and OW221024 to form new object OWCombined
OWCombined<- bind_rows(OW061024,OW221024)


# Data Integrity

# Embed source data context for data integrity by adding variable labels.
# To ensure the integrity of the data persists once imported into R, it is
# very useful to embed the source data context in the datafile.  Embed the
# source data context by adding variable labels to the sensor data. 
# In this case the site name and sensor details are embedded.

# Embed the source data context in a single datafile by adding variable labels.

OW061024<-OW061024|>
  labelled::set_variable_labels(
    DateTime = "Measurement Date and Time (GMT) of River Owenmore ",
    Temp = "Temperature (degC) YSI6600EDSV2_2 6560 Conductivity_Temperature Probe",
    SpCond = "Specific Conductance uScm-1 YSI6600EDSV2-2 6560 Conductivity_Temperature Probe",
    Turbidity = "Turbidity (NTU) - YSI_6600_EDS_V2-2 - 6136 Turbidity Probe"
  )

# To view the variable labels
View(OW061024)

#  OR Embed the source data context in a combined datafile by adding variable labels
OWCombined<-OWCombined|>
  labelled::set_variable_labels(
    DateTime = "Measurement Date and Time of River Owenmore, Sligo ",
    Temp = "Temperature (degC) YSI6600EDSV2_2 6560 Conductivity_Temp. Probe",
    SpCond = "Specific Conductance uScm-1 YSI6600EDSV2-2 6560 Conductivity_Temp. Probe",
    Turbidity = "Turbidity (NTU) - YSI_6600_EDS_V2-2 - 6136 Turbidity Probe"
  )

# To view the variable labels
# A new tab opens displaying the combined dataframe.
View(OWCombined)   

# Export the tidyied datafile as a .csv file and as .rds file to working directory
# NOTE: the datalabels are lost when exporting the files as .csv but are maintained when exported as .rds file.
# This file is used for visualisation and event detection. 

# Export the single cleaned datafile as .csv to the working directory #
write.table(OW061024,"./Output_Files/OW061024C.csv",row.names=F, sep = ",")

# Export the combined cleaned datafile as .csv to the working directory #
write.table(OWCombined,"./02_Embed_Source_Data_Context/Output_Files/OW061024_051124C.csv",row.names=F, sep = ",")

# save the file as Rds
saveRDS(OW061024, file = "./Output_Files/OW061024C.RData")
saveRDS(OW061024, file = "./Output_Files/OW061024C.rds")

# save the file as RData (useful when importing into R again)
saveRDS(OWCombined, file = "./02_Embed_Source_Data_Context/Output_Files/OW061024_051124C.rds")

# Record the Session information
sessionInfo()
