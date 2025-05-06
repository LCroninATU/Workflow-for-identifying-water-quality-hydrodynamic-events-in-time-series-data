### Embed Source Data Context into Dataframe ###

# Load libraries (they may need to be installed first)

library(scales)
library(tidyverse)
library(here)


# set the timezone
Sys.setenv(TZ='UTC')

# Check the wd
here::here()

# Data Integrity

# Embed source data context for data integrity by adding variable labels.
# To ensure the integrity of the data persists once imported into R, it is
# very useful to embed the source data context in the datafile.  Embed the
# source data context by adding variable labels to the sensor data. 
# In this case the site name and sensor details are embedded.

# If only a single file imported - Embed the source data context in a single datafile by adding variable labels.

OW061024<-OW061024|>
  labelled::set_variable_labels(
    DateTime = "Measurement Date and Time (GMT) of River Owenmore ",
    Temp = "Temperature (degC) YSI6600EDSV2_2 6560 Conductivity_Temperature Probe",
    SpCond = "Specific Conductance uScm-1 YSI6600EDSV2-2 6560 Conductivity_Temperature Probe",
    Turbidity = "Turbidity (NTU) - YSI_6600_EDS_V2-2 - 6136 Turbidity Probe"
  )

# To view the variable labels
View(OW061024)

#  For combined files - Embed the source data context in a combined datafile by adding variable labels
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
write.table(OW061024,"./02_Embed_Source_Data_Context/Output_Files/OW061024C.csv",row.names=F, sep = ",")

# Export the combined cleaned datafile as .csv to the working directory #
write.table(OWCombined,"./02_Embed_Source_Data_Context/Output_Files/OW061024_051124C.csv",row.names=F, sep = ",")

# save the single file as Rds
saveRDS(OW061024, file = "./02_Embed_Source_Data_Context/Output_Files/OW061024C.RData")
saveRDS(OW061024, file = "./02_Embed_Source_Data_Context/Output_Files/OW061024C.rds")

# save the combined file as .rds
saveRDS(OWCombined, file = "./02_Embed_Source_Data_Context/Output_Files/OW061024_051124C.rds")

# Record the Session information
sessionInfo()

