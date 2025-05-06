# Compare the Owenmnore CANARY files to the manually identified events to identify the most suitable CANARY algorithm. 

library(dplyr)
library(here)
library(data.table)
library(tidyverse) # For renaming variable names.

# This is the last step in the workflow where the events identified are compared in order to identify the most suitable algorithm for that particular site based on the data provided to 'train' CANARY.
# This workflow used changes in the turbidity signal to identify potential water quality events at these two river stations as the turbidity values for the monitoring sites examined did not show a diurnal trend and baseline levels for turbidity at both sites was low.  

# The identification of full and partial matches was carried out by analysing the output of step 8 where the output files of CANARY for each algorithm file were combined with manually identified event file. 
# Events were classified as FULL or PARTIAL matches depending on whether the event time start timestep or time end timestep matched fully or partially.
# A description of the logic detailing how full and partial matches were classified is available in the Supplementary Material directory of the associated journal article.
# Using the classification for matches, the combined files (output for step 8) were analysed for matches by looping over each file to find where time steps either fully or partially matched for identified events.  
# This was done in a step by step fashion to allow the user to verify that this code is correctly matching events for their data.  The logic for how the files were matched is contained in the 'Code Logic for Finding Matches between manually verified events and EPA events' in the supplementary material folder.   


## 9.1 Identify the folder for processing
#' Here, enter the directory containing the folders for processing
## ----------------------------------------------------------------------------------------------------------------------
top_directory<-paste0("08 Manually compare events to CANARY events/Output_Files/",data_set_identifier)

# List directories but not sub-directories.
(directory_list<-list.dirs(top_directory,recursive=FALSE))

# Only take the directory names which include the string "Output_Files"
directory_list<-directory_list[grepl("Output_Files",directory_list)]

# Set up dataframe for output.
Algorithm_Scores<-data.frame(algorithm=character(),FULL_MATCH=integer(),PARTIAL_MATCH=integer(),TOTAL_MATCH=integer(),Total_CANARY_Events=integer(),Total_Verified_Events=integer(),Percent_CANARY_Agreement_to_TOTAL_Verified_Events=numeric(),stringsAsFactors = FALSE)

#' 
#' ## 9.2 Loop over all the directories for processing.
## ----------------------------------------------------------------------------------------------------------------------
for (k in 1:length(directory_list)){
  
  # List all files in each parent directory, in turn.
  # Only consider filenames that have the string 'alg' in them.
  
  (files_list<-list.files(directory_list[k],pattern='alg'))
  
  # Loop over all the files in the current directory.
  for (j in 1:length(files_list)){
    
    # Put together the directory path and filename for the current file to be processed.
    input_filename_string<-paste0(directory_list[k],'/',files_list[j])
    
    dat<-read.csv(input_filename_string, header=T, stringsAsFactors = F) # loading it the 96 .csv files for CANARY algorithms
    
    
    # Compare the Owenmore Turb Events to CANARY algorithm to determine the number of matches. 
    
    # The method requires an extra row at the top and bottom of the dataframe.
    # Add row of 0s at start of dataframe.
    dat<-rbind(0,dat)
    
    # Add row of 0s at end of dataframe.
    dat<-rbind(dat,0)
    
    #Initialise variables to 0
    dat<-cbind(dat,Ver_Alarm_Start=0,Ver_Alarm_End=0)
    
    #Initialise variables to 0
    dat<-cbind(dat,CANARYTurb_Alarm_Start=0,CANARYTurb_Alarm_End=0)
    
    #Initialise variables to 999
    dat<-cbind(dat, FULL_MATCH=999,PARTIAL_MATCH=999)
    
    
    
    
    # Before doing the match, check for any na values in the dataframe, there       #  should be none (0 rows) or the subsequent code won't run.
    # if NA is present the code returns where NA occurs in the dataframe.
    dat[which(rowSums(is.na(dat[,-1]))>0),]
    
    
    ## Also, ensure that there is a least 1 alarm present in the ##"Verified_OW_Event_Alarm" Column.
    
    contains_one<-any(dat$Verified_OW_Event_Alarm==1)
    if(!contains_one){
      stop("There are no Verified Alarms in the data, nothing to do!")
      
    }
    
    
    # Any records containing NA values should be checked and must be removed for the code below to run.
    
    # The code will iterate over rows of the dataframe starting from row 2 
    # This loop locates the start and end point for each Verified alarm and labels these as '1' in the Ver_Alarm_Start/End columns
    # Also, this loop locates the start and end point for each CANARY alarm and labels these as '1' in the CANARYTurb_Alarm_Start/End columns
    
    for (i in 2:nrow(dat)){
      
      # Checks if the value in Verified_OW_Event_Alarm of the previous row (i-1) is 0 AND the current row (i) is 1.  If the condition is TRUE,
      # the alarm has commenced and 1 is placed in Ver_Alarm_Start which marks the start of the transition.
      if ((dat$Verified_OW_Event_Alarm[i-1]==0) & (dat$Verified_OW_Event_Alarm[i]==1))
      {dat$Ver_Alarm_Start[i]<-1}
      
      # Checks if the value in Verified_OW_Event_Alarm of the previous row (i-1) is 1 AND the current row (i) is 0.  If the condition is TRUE,
      # the alarm has finished and 1 is placed in Ver_Alarm_End which marks the end of the transition.
      if ((dat$Verified_OW_Event_Alarm[i-1]==1) & (dat$Verified_OW_Event_Alarm[i]==0))
      {dat$Ver_Alarm_End[i-1]<-1}
      
      # As above for P_Event
      #if ((dat$P_Event[i-1]==0.00000) & (dat$P_Event[i]==1.000000))
      #{dat$CANARYTurb_Alarm_Start[i]<-1}
      if ((dat$P_Event[i-1]<1) & (dat$P_Event[i]==1.000000))
      {dat$CANARYTurb_Alarm_Start[i]<-1}
      
      if ((dat$P_Event[i-1]==1) & (dat$P_Event[i]<1))
      {dat$CANARYTurb_Alarm_End[i-1]<-1}
      
    }
    
    
    
    # locate the indices for the start and end points of each CANARY Alarm
    CANARYTurb_Alarm_Start_Indices<-grep(1,dat$CANARYTurb_Alarm_Start) 
    CANARYTurb_Alarm_End_Indices<-grep(1,dat$CANARYTurb_Alarm_End) 
    
    # locate the indices for the start and points of each Verified Alarm
    Ver_Alarm_Start_Indices<-grep(1,dat$Ver_Alarm_Start) 
    Ver_Alarm_End_Indices<-grep(1,dat$Ver_Alarm_End) 
    
    # ALL CASES 
    # This only runs if "CANARY" has found at least one alarm.
    if(length(CANARYTurb_Alarm_Start_Indices)>0){ # checks for any start indices in the CANARYTurb_Alarm_Start_Indices vector
      for (m in 1:length(Ver_Alarm_Start_Indices)){  # This loop iterates over each start index in Ver_Alarm_Start_Indices.
        Ver_Alarm_Chunk_Length<-(Ver_Alarm_End_Indices[m]-Ver_Alarm_Start_Indices[m])+1  # calculates the length of the current alarm chunk by subtracting the start index from the end index and adding 1 (to include both endpoints)
        CANARY_TEST_Chunk1<-dat$P_Event[(Ver_Alarm_Start_Indices[m]):(Ver_Alarm_End_Indices[m])] # extract a subset of data from 'dat' dataframe based on the start and end indices
        
        CANARY_Alarm_ON_Chunk1_Length<-sum(CANARY_TEST_Chunk1)
        
        if (Ver_Alarm_Chunk_Length==CANARY_Alarm_ON_Chunk1_Length)
        {
          # Now extend the CANARY test Chunk by 1 step above and below. 
          # If FULL_MATCH, then sum(CANARY test chunk) will not change.
          CANARY_TEST_Chunk2<-dat$P_Event[(Ver_Alarm_Start_Indices[m]-1):(Ver_Alarm_End_Indices[m]+1)]
          CANARY_Alarm_ON_Chunk2_Length<-sum(CANARY_TEST_Chunk2)
          
          if (CANARY_Alarm_ON_Chunk1_Length==CANARY_Alarm_ON_Chunk2_Length)
          {dat$FULL_MATCH[Ver_Alarm_End_Indices[m]]<-"TRUE"}
          
          else
          {dat$PARTIAL_MATCH[Ver_Alarm_End_Indices[m]]<-"TRUE"}
        }
        
        
        else if (CANARY_Alarm_ON_Chunk1_Length>=1){
          dat$PARTIAL_MATCH[Ver_Alarm_End_Indices[m]]<-"TRUE"
        }
        
      }
    }
    
    (count_FULL_MATCH <- length(which(dat$FULL_MATCH == "TRUE")))
    (count_PARTIAL_MATCH <- length(which(dat$PARTIAL_MATCH == "TRUE")))
    (count_TOTAL_MATCH<-count_FULL_MATCH+count_PARTIAL_MATCH)
    
    # Count the number of actual alarms.
    
    Num_Ver_Alarms<-sum(dat$Ver_Alarm_Start==1)
    
    # Count the number of CANARY alarms.
    
    Num_CANARY_Alarms<-sum(dat$CANARYTurb_Alarm_Start==1)
    
    # Calculate the % Agreement between CANARY and Ver Alarms  
    Percent_CANARY_Agreement_to_TOTAL_Verified_Events<-round((count_TOTAL_MATCH/Num_Ver_Alarms)*100,2)
    
    current_row_for_output<-list(files_list[j], count_FULL_MATCH, count_PARTIAL_MATCH, count_TOTAL_MATCH, Num_CANARY_Alarms, Num_Ver_Alarms, Percent_CANARY_Agreement_to_TOTAL_Verified_Events)
    
    Algorithm_Scores[nrow(Algorithm_Scores) + 1,] <- current_row_for_output
    
    # Ensure that a folder is available to receive the output data/ 
    # "data_set_identifer" will be used as the folder name.
    
    if (!dir.exists(paste0('09 ID CANARY Algorithm for turbidity events/Output_Files/',data_set_identifier)))           {dir.create(paste0('09 ID CANARY Algorithm for turbidity events/Output_Files/',data_set_identifier), recursive = TRUE)}
    
    
    dat_out_directory<-paste0('09 ID CANARY Algorithm for turbidity events/Output_Files/',data_set_identifier,'Dat_Files')
    
    # Save Current dat to file, for troubleshoot or testing as required.
    if (!dir.exists(dat_out_directory)) dir.create(dat_out_directory, recursive = FALSE)
    
    write.csv(dat,(paste0(dat_out_directory,'/Dat_For_',files_list[j])), row.names=FALSE)
    if (j==1){
      # Only print this message once per processed directory.
      cat("Writing data to file:\n",(paste0(dat_out_directory,'/Dat_For_',files_list[j])),"\n")}
    
  }
}

dat$TIME_STEP<-format(dat$TIME_STEP) # this prevents 00:00:00 being removed from Timestamps

Location_and_Date_Range_ID_String<-paste0(sub("\\_L.*","",files_list[1]),"_")
Filename_and_path_for_algorithm_scores<-paste0("09 ID CANARY Algorithm for turbidity events/Output_Files/",data_set_identifier,Location_and_Date_Range_ID_String,"Algo_scores.csv")
write.csv(Algorithm_Scores,Filename_and_path_for_algorithm_scores, row.names=FALSE)


#' ### 9.3 Output files for comparing the CANARY files to the manually identified events and identify the most suitable CANARY algorithm.
#' 
#' The output for step 9 identifying the best CANARY algorithm for turbidity events is saved in 09 ID CANARY Algorithm for turbidity events/Output_Files.  It consists of two outputs, a Dat_Files directory containing 96 files and an 'Algo_scores files.  
#' 
#' #### 9.3.1 The Dat_Files directory
#' The Dat_Files directory contains each of the CANARY alorithm output files matched to the manually verified events file.  In addition, for the sample data provided with this workflow, an example of how matching could be verified by the user is included in the file 'Match_highlighted_for_Dat_For_OW061024_051124C_LPCF_BED6_ET0.89063alg_1' in the supplementary material folder.
## ----------------------------------------------------------------------------------------------------------------------
head(dat)

#' 
#' #### 9.3.2 Algo scores file
#' The algo scores file summarises the number of full and partial matches for each CANARY algorithm and assigns a percent agreement to the total number of verified events.  This can be used to identify the most suitable algorithm for the particular monitoring station based on the data provided to 'train' CANARY.  It should be noted that adequate data covering a range of events over a time period is required to train CANARY and identify the most suitable algorithm.  The optimum time period will depend on the frequency of events and the variability in event profiles for each monitoring station.
#' For this short dataset all algorithms show 100% identification of events i.e. they all identified the 4 manually identified events so more data would be required to distinguish the most suitable algorithm for this monitoring location. 
#' 
## ----------------------------------------------------------------------------------------------------------------------
head(Algorithm_Scores)

#' 
#' 
