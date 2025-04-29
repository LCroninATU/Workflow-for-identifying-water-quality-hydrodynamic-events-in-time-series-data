# Compare manually identified Owenmore turbidity events to positive CANARY events #

# Load packages
library(here)
library(data.table) 
library(dplyr)

# Compare the manually identified events file ('OW061024_051124C_NoOutRange_ManVer_TurbEvent.csv') to each of the 16 algorithms tested for each BED window and event time out (ETO) in CANARY i.e total of 96 files

## Load the manually identified events file ('OW061024_051124C_NoOutRange_ManVer_TurbEvent.csv')

#cIAN - THIS WON'T LOAD AND I CAN'T FIGURE OUT WHY! IT's GIVING ME  AN ERROR THAT IT CAN'T FIND THE COLUMN NAMES.  
#SO I PUT THE FILE IN THE WORKING DIRECTORY AS A TEMPORARY WORKAROUND (WHICH CAN IMPORT NO PROBLEM!) THAT I CAN EDIT LATER ONCE I FIGURE OUT THE ISSUE
OW061024_051124C_ManVer_TurbEvent<-fread("06 Manually Identify Potential Water Quality Events/OW061024_051124C_NoOutRange_ManVer_TurbEvent.csv",header=T, 
                                         stringsAsFactors = F, select = c("DateTime","Turbidity","Verified_OW_Event_Alarm"))

#OW061024_051124C_ManVer_TurbEvent<-fread("OW061024_051124C_NoOutRange_ManVer_TurbEvent.csv",header=T, 
 #                                        stringsAsFactors = F, select = c("DateTime","Turbidity","Verified_OW_Event_Alarm"))
str(OW061024_051124C_ManVer_TurbEvent)
#Change DateTime from chr to Date 
OW061024_051124C_ManVer_TurbEvent$DateTime<-as.POSIXct(OW061024_051124C_ManVer_TurbEvent$DateTime, format = "%d/%m/%Y %H:%M", tz="UTC")
str(OW061024_051124C_ManVer_TurbEvent)
# and rename to TIME_STEP to match the Owenmore CANARY File
library(tidyverse)
OW061024_051124C_ManVer_TurbEvent<- OW061024_051124C_ManVer_TurbEvent%>% rename(TIME_STEP = DateTime)




## Load the Owenmore CANARY file From 07 EPA CANARY Event Detection Folder

CANARYOwenmoreBED6ET0.89063Alg1<-fread("07 EPA CANARY Event Detection/Owenmore_LPCF_BED6_ET0.89063/Owenmore_LPCF_Var_HWV01.OW061024_051124C_ET0.89063-details-alg_1.csv", header=T, stringsAsFactors = F,
                          select = c("TIME_STEP","Contrib_{Turbidity}"))
 
str(CANARYOwenmoreBED6ET0.89063Alg1)

#Change TIME_STEP from chr to Date 
CANARYOwenmoreBED6ET0.89063Alg1$TIME_STEP<-as.POSIXct(CANARYOwenmoreBED6ET0.89063Alg1$TIME_STEP, format = "%d/%m/%Y %H:%M", tz="UTC")
# rename column
CANARYOwenmoreBED6ET0.89063Alg1<- CANARYOwenmoreBED6ET0.89063Alg1%>% rename(CANARY_Contrib_Turbidity = "Contrib_{Turbidity}")
str(CANARYOwenmoreBED6ET0.89063Alg1)


# Change any negative values in CANARYOwenmoreAlg1 Contrib_{Turbidity} to absolute values to facilitate matching query
CANARYOwenmoreBED6ET0.89063Alg1$`CANARY_Contrib_Turbidity`<-abs(CANARYOwenmoreBED6ET0.89063Alg1$`CANARY_Contrib_Turbidity`)

# The number of timesteps in the Manually identified turbidity file must not be longer than the CANARY file or NA will be inserted.
# Show the last timestamp in the CANARY File
last_timestep_CANARY<-max(CANARYOwenmoreBED6ET0.89063Alg1$TIME_STEP)


# Join the two events data tables (left join) with the end timestep determined by last timestep in the Manually identified turbidity file.
CombEventsOwBED6ET0.89063ALG1<-OW061024_051124C_ManVer_TurbEvent%>%
  filter(TIME_STEP<=last_timestep_CANARY) %>% # this filters the manually identified turbidity file based on the last TIME_STEP in the CANARY file
  left_join(CANARYOwenmoreBED6ET0.89063Alg1, by="TIME_STEP") # left-join the CANARY file to the manually identified events file

# View the first few rows and the structure of the combined dataframe
head(CombEventsOwBED6ET0.89063ALG1)
str(CombEventsOwBED6ET0.89063ALG1)

# Export this data table as.csv file
here() # indicates the working directory
CombEventsOwBED6ET0.89063ALG1$TIME_STEP<-format(CombEventsOwBED6ET0.89063ALG1$TIME_STEP) # this prevents 00:00:00 being removed from Timestamps

write.csv(CombEventsOwBED6ET0.89063ALG1, "08 Manually compare events to CANARY events/Output_Files_OWBED6ET0.89063/CombEventsOWBED6ET0.89063ALG1.csv", row.names=FALSE)

# Load the other 15 algorithm files from 07 EPA CANARY Event Detection/Owenmore_LPCF_BED6_ET0.89063

CANARYOwenmoreBED6ET0.89063Alg2<- fread("07 EPA CANARY Event Detection/Owenmore_LPCF_BED6_ET0.89063/Owenmore_LPCF_Var_HWV01.OW061024_051124C_ET0.89063-details-alg_2.csv", 
               select = c("TIME_STEP","Contrib_{Turbidity}"))[, 
               TIME_STEP := as.POSIXct(TIME_STEP, format = "%d/%m/%Y %H:%M", tz = "UTC")]

CANARYOwenmoreBED6ET0.89063Alg3<- fread("07 EPA CANARY Event Detection/Owenmore_LPCF_BED6_ET0.89063/Owenmore_LPCF_Var_HWV01.OW061024_051124C_ET0.89063-details-alg_2.csv", 
               select = c("TIME_STEP","Contrib_{Turbidity}"))[, 
               TIME_STEP := as.POSIXct(TIME_STEP, format = "%d/%m/%Y %H:%M", tz = "UTC")]


#CIAN - THIS NEEDS TO BE REPEATED FOR THE OTHER 15 x .csv files IN FOLDER '07 EPA CANARY Event Detection/Owenmore_LPCF_BED6_ET0.89063' WITH THE OUTPUT NAME ALG1, ALG2 etc UPDATED for
# THE RELEVANT CANARYOwenmoreBED6ET0.89063Alg FILE.
# IS THE BEST  APPROACH BY LOOPING THIS THROUGH THE FILES OR BETTER TO CREATE A FUNCTION AND APPLY THE FUNCTION TO EACH FILE?  IF YOU CAN ADVISE THE BEST APPROACH THEN I CAN APPLY
# IT TO THE OTHER 5 FOLDERS OF ALGORITHMS, 96 IN TOTAL.

# Create a list of Dataframes so the Owenmore CANARY files can be formatted and joined to OW061024_051124C_ManVer_TurbEvent
BED6ET0.89063Alg1_16<-list(CANARYOwenmoreBED6ET0.89063Alg2, CANARYOwenmoreBED6ET0.89063Alg3)


# Create a function to format the Owenmore CANARY files and join them to OW061024_051124C_ManVer_TurbEvent

Join_OWCANARY_To_ManVer_TurbEvent<-function(df){
# rename column
df<df%>%
    rename(CANARY_Contrib_Turbidity = "Contrib_{Turbidity}")%>%
# Change any negative values in CANARYOwenmoreAlg1 Contrib_{Turbidity} to absolute values to facilitate matching query
    mutate(`CANARY_Contrib_Turbidity`= abs(`CANARY_Contrib_Turbidity`))%>%
# Join the two events data tables (left join)
    left_join(OW061024_051124C_ManVer_TurbEvent, by="TIME_STEP")
# Convert TIME_STEP to chr
    mutate(TIME_STEP = as.character(TIME_STEP)) # this prevents 00:00:00 being removed from Timestamps
}

#  Apply the function to the list of dataframes, BED6ET0.89063Alg1_16 and export the new dataframes to Output_Files_OWBED6ET0.89063
for (i in seq_along(BED6ET0.89063Alg1_16)) {
  # Process the dataframe
  new_df<-Join_OWCANARY_To_ManVer_TurbEvent(BED6ET0.89063Alg1_16[[i]])
  # A new dataframe name is created based on the index i
  new_df_name<-paste0("CombEventsOWBED6ET0.89063ALG", i)
  # Assign the processed dataframe to an object
  assign(new_df_name, new_df)
  # The output file name
  output_file<-paste0("08 Manually compare events to CANARY events/Output_Files_OWBED6ET0.89063/",new_df_name, ".csv")
  
  # Write to csv
  write.csv(Join_OWCANARY_To_ManVer_TurbEvent, file="08 Manually compare events to CANARY events/Output_Files_OWBED6ET0.89063", row.names=FALSE)
}
 

#CIAN - I'VE TRIED CREATING A FUNCTION FOR THIS, IT MAY NOT BE THE BEST APPROACH AND I'M GETTING AN ERROR 
# ' Error in Ops.data.frame(df, df %>% rename(CANARY_Contrib_Turbidity = "Contrib_{Turbidity}") %>%  : 
#‘<’ only defined for equally-sized data frames

#NOT SURE WHAT I'M DOING WRONG BUT OW061024_051124C_ManVer_TurbEvent IS THE MASTER DATAFILE AS SUCH. THE CANARY SOFTWARE INSERTS DATES & TIMES IF THE TIME SERIES IS NOT CONTINUOUS
# THE SENSORS NEED TO BE REMOVED FROM THE RIVER AND CALIBRATED, SERVICED REGULARLY SO THERE IS A MISMATCH IN 
# THE NUMBER OF OBSERVATIONS BETWEEN THE DATAFRAMES SO I NEED TO LEFT JOIN TO THIS SMALLER DATAFRAME AS IT IS THE MASTER ONE AND EXCLUDE THE DATES& TIMES canary INSERTS.  
# IT DOESN'T SEEM TO BE AN ISSUE FOR LINE 40 OF THE CODE ABOVE WHEN DONE INDIVIDUALLY BUT LOOKS LIKE IT MAY BE AN ISSUE FOR FUNCTIONS OR I COULD BE READING THAT WRONG SO
# ANY ADVICE YOU HAVE WOULD BE GREAT TO TROUBLESHOOT THIS.



