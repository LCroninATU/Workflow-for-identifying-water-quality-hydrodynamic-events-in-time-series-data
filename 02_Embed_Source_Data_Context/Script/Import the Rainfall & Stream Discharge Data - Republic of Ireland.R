### Import the Rainfall & Stream Discharge Data - Republic of Ireland ###

# Install libraries

library(scales)
library(tidyverse)
library(here)


# set the timezone
Sys.setenv(TZ='UTC')

# Check the wd
here::here()

# Data Integrity

## Embed source data context for data integrity by adding variable labels.
To ensure the integrity of the data persists once imported into R, it is
very useful to embed the source data context in the datafile.  Embed the
source data context by adding variable labels to the sensor data. 
In this case the site name and sensor details are embedded.

```{r}
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
```

## Export the tidyied datafile as a .csv file and as .rds file to the working directory
This file is used for visualisation and event detection. 
```{r}
# Export the cleaned datafile as .csv to the working directory #
write.table(OWCombined,"./02_Embed_Source_Data_Context/Output_Files/OW061024_051124C.csv",row.names=F, sep = ",")

# save the file as RData (useful if importing into R again)
saveRDS(OWCombined, file = "./02_Embed_Source_Data_Context/Output_Files/OW061024_051124C.rds")

```

# Record the Session information
sessionInfo()
