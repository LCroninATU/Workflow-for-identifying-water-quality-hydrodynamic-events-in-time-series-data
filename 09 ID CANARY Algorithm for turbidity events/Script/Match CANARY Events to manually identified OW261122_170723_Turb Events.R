# Compare the Owenmnore CANARY files to the manually identified events to determine the number of matches. 

library(dplyr)
library(here)
library(data.table)
library(tidyverse) # For renaming variable names.

## Import the data files

dat<-read.csv("08 Manually compare events to CANARY events/Output_Files_OWBED6ET0.89063/CombEventsOWBED6ET0.89063ALG1.csv", header=T, stringsAsFactors = F)
str(dat)

# Compare the Owenmnore Turb Events to CANARY algorithm to determine the number of matches. 

#Add row of 0s at start of dataframe.
dat<-rbind(0,dat)

#Add row of 0s at end of dataframe.
dat<-rbind(dat,0)

#Initial variables to 0
dat<-cbind(dat,Ver_Alarm_Len=0,Ver_Alarm_Start=0,Ver_Alarm_End=0)

#Initial variables to 0

dat<-cbind(dat,CANARYTurb_Alarm_Len=0,CANARYTurb_Alarm_Start=0,CANARYTurb_Alarm_End=0)

#Initial variables to 999
dat<-cbind(dat, FULL_MATCH=999,PARTIAL_MATCH=999,FALSE_ALARM=999,CANARY_Single_Time_Event=999)

#re-order the variables to have the 'verified' variables together and the 'CANARY' variables together which makes it easier to interpret the data.

dat<-dat[,c(1,2,3,5,6,7,4,8,9,10,11,12,13,14)]

# Count the number of events for the manually verified events i.e. the number of "1" in Ver_Alarm_Start
dat%>%count(dat$Ver_Alarm_Start==1)

#count(dat$Ver_Alarm_Start==1, wt = NULL, sort = FALSE, name = NULL)         
            
# Before doing the match, check for any na values in the dataframe, there should be none (0 rows) or the subsequent code won't run.
# if NA is present the code returns where NA occurs in the dataframe.
dat[which(rowSums(is.na(dat[,-1]))>0),]


# Any records containing na values should be checked and must be removed for the code below to run.

# The code will iterate over rows of the dataframe starting from row 2 
for (i in 2:nrow(dat)){
  
# Checks if the value in Verified_OW_Event_Alarm of the previous row (i-1) is 0 AND the current row (i) is 1.  If the condition is TRUE,
# the alarm has commenced and 1 is placed in Ver_Alarm_Start which marks the start of the transition.
  if ((dat$Verified_OW_Event_Alarm[i-1]==0) & (dat$Verified_OW_Event_Alarm[i]==1))
  {dat$Ver_Alarm_Start[i]<-1}

# Checks if the value in Verified_OW_Event_Alarm of the previous row (i-1) is 1 AND the current row (i) is 0.  If the condition is TRUE,
# the alarm has finished and 1 is placed in Ver_Alarm_End which marks the end of the transition.
  if ((dat$Verified_OW_Event_Alarm[i-1]==1) & (dat$Verified_OW_Event_Alarm[i]==0))
  {dat$Ver_Alarm_End[i-1]<-1}
  
# As above for CANARY_Contrib_Turbidity
  if ((dat$CANARY_Contrib_Turbidity[i-1]==0) & (dat$CANARY_Contrib_Turbidity[i]==1))
  {dat$CANARYTurb_Alarm_Start[i]<-1}
  
  if ((dat$CANARY_Contrib_Turbidity[i-1]==1) & (dat$CANARY_Contrib_Turbidity[i]==0))
  {dat$CANARYTurb_Alarm_End[i-1]<-1}
}


# The code will iterate over rows of the dataframe starting from row 2
for (i in 2:nrow(dat)){
 
# Calculate the cumulative length of consecutive values of 1 in Verified_OW_Event_Alarm and record in new variable Ver_Alarm_Len.
# For the else function, when the value changes from 1 to 0, Ver_Alarm_Len is set to 0 i.e. resetting the count to 0   
  if (dat$Verified_OW_Event_Alarm[i]==1) {
    dat$Ver_Alarm_Len[i]<-dat$Ver_Alarm_Len[i-1]+dat$Verified_OW_Event_Alarm[i]
  }
  else {dat$Ver_Alarm_Len[i]<-0
  }
  
  if (dat$CANARY_Contrib_Turbidity[i]==1) {
    dat$CANARYTurb_Alarm_Len[i]<-dat$CANARYTurb_Alarm_Len[i-1]+dat$CANARY_Contrib_Turbidity[i]
  }
  else {dat$CANARYTurb_Alarm_Len[i]<-0
  }
  
}

# Searches for 1's in Ver_Alarm_Start and returns the indices where 1 is found, and then assigns those indices to the Ver_Alarm_Start_Indices.
# These indices are available in the Environment under 'values'.
Ver_Alarm_Start_Indices<-grep(1,dat$Ver_Alarm_Start)
CANARYTurb_Alarm_Start_Indices<-grep(1,dat$CANARYTurb_Alarm_Start) 

  
# To find the full matches
# The code will iterate over rows of the dataframe starting from row 2 
for (i in 2:nrow(dat)){
  
# For full match
  if((dat$Verified_OW_Event_Alarm[i]==1) & (dat$CANARYTurb_Alarm_Len[i]==dat$Ver_Alarm_Len[i])
     & (dat$Ver_Alarm_End[i]==1) & (dat$CANARYTurb_Alarm_End[i]==1))
  {dat$FULL_MATCH[i]<-"TRUE"}


  
}
# Count number of FULL_MATCH
(count_FULL_MATCH <- length(which(dat$FULL_MATCH == "TRUE")))
# To display indices where FULL_MATCH is TRUE
which(dat$FULL_MATCH == "TRUE", arr.ind = TRUE)


# To find the single timestep events (these can often be due to sensor error or air spikes due to air in the water)
if((dat$Ver_Alarm_Start[i]==1) & (dat$Ver_Alarm_End[i]==1))
{dat$OWVer_Single_Time_Event[i]<-"TRUE"}

(count_Omore_Single_Alarm <- length(which(dat$Omore_Single_Time_Event == "TRUE")))


# CIAN FOR PARTIAL MATCHES I SENT YOU EMAIL OF THE LOGIC JONATHAN USED FOR THE PARTIAL MATCHES (HE DID IT IN ACCESS).  
# COULD YOU CHECK THE PARTIAL MATCH CODE TO SEE IT MATCHES JONATHAN'S LOGIC  (IN EMAIL i SENT PREVIOSULY) SO WE KNOW WE'RE CAPTURING THE SAME MATCHES THEY DID?
# I think we need to create function 'is_within_event' to identify instances of where the start or end of CANARY alarm is within any Verified_OW_Event_Alarm.  Let me know what you think.
# AGAIN WE NEED TO DO THIS ACROSS ALL 6 FOLDERS X 16 ALGORITHMS AND USE THE ANALYSES TO IDENTIFY THE ALGORITHIM PARAMETERS THAT BEST MATCHES THE MANUALY IDENTIFIED EVENTS FILE.
  

if((dat$Verified_OW_Event_Alarm[i]==1) & (dat$Ver_Alarm_End[i]==1)
   & (dat$Ver_Alarm_Len[i] != dat$CANARYTurb_Alarm_Len[i] ) & (any(between(CANARYTurb_Alarm_Start_Indices, i-dat$Ver_Alarm_Len[i],i))))
{dat$PARTIAL_MATCH[i]<-"TRUE"}

# For partial match of events
  for (i in seq_along(dat$CANARYTurb_Alarm_Start) { 
  if ((CANARYTurb_Alarm_Start_Indices[i] >= dat$CANARYTurb_Alarm_Start[i] & Ver_Alarm_Start_Indices[i]<= dat$CANARYTurb_Alarm_End))
    {dat$PARTIAL_MATCH[dat$CANARYTurb_Alarm_End]<-TRUE}
    

 
(count_PARTIAL_MATCH <- length(which(dat$PARTIAL_MATCH == "TRUE")))



# Export this data table to Output_Files
dat$TIME_STEP<-format(dat$TIME_STEP) # this prevents 00:00:00 being removed from Timestamps
write.csv(dat, ('./Output_Files/datOwALG1.csv'), row.names=FALSE)

# To find the index of the FULL_MATCH = TRUE in the Dataframe
grep("TRUE", dat$FULL_MATCH)

# To find the index of the PARTIAL_MATCH = TRUE in the Dataframe
grep("TRUE", dat$PARTIAL_MATCH)

# Count the number of verified events based on changes from 0 to 1 in the Ver_Alarm_Len

dat1 <- dat %>%
  mutate(
    # Detect the change from 0 to 1 in Event_Alarm
    Event_Change = c(0, diff(Ver_Alarm_Len))  # Calculate the difference between consecutive values
  ) %>%
  mutate(
    # Count events where Event_Change equals 1 (indicating 0 to 1 transition)
    Event_Count = if_else(Ver_Alarm_Len == 1, 1, 0)
  ) %>%
  summarise(
    Total_Events = sum(Event_Count)  # Total number of transitions from 0 to 1
  )

# View the total number of events
dat1$Total_Events

