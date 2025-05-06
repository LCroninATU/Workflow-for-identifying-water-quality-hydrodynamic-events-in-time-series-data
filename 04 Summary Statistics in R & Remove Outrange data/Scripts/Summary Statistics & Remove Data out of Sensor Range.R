#### SUMMARY STATISTICS ####

# You may need to install packagages before loading them.

# Load packages
library(dplyr)
library(tidyr)
library(here)
library(ggplot2)
library(data.table)
library(here)
library(naniar) # for manipulating missing data
library(stargazer) # for summary statistics


# Current working directory
here()

# Import datasets into R
OW061024_051124C<-readRDS("./02_Embed_Source_Data_Context/Output_Files/OW061024_051124C.rds")


# Check for any missing values as it interferes with computing summary statistics and further analysis.
# Check for any missing values
colSums(is.na(OW061024_051124C))

# Find and count any missing values
# number of missing values
which(is.na(OW061024_051124C$Turbidity))
which(is.na(OW061024_051124C$SpCond))
which(is.na(OW061024_051124C$Temp))

# location of missing values (if any)
print("Position of missing values ")
which(is.na(OW061024_051124C))

# Screen for datapoints outside the measurement range of the sensors. The measurement range varies from sensor to sensor so it's important to refer to the measurement range for the particular sensors used.

## Specific Conductance
# Identify where SpCond <0 uS/cm
OW061024_051124C_SpCond_lo<-OW061024_051124C$SpCond<0 
#count the number of TRUE, FALSE, and NA values in vector turbidity <0.  If count of all observations is FALSE then there are no values of SpCond<0.
summary(OW061024_051124C_SpCond_lo)

# Identify where SpCond>100000 uS/cm
OW061024_051124C_SpCond_hi<-OW061024_051124C$SpCond>100000
#count TRUE, FALSE, and NA values in vector turbidity >1000
summary(OW061024_051124C_SpCond_hi)

# Export SpCond_OutRange Values to pdf file   
####FIND OUT HOW TO PUT THIS FILE IN oUTPUT_fILES FOLDER ###
pdf("04 Summary Statistics in R & Remove Outrange data/Output_Files/OW061024_051124C_SpCond_OutRange.pdf")
summary(OW061024_051124C_SpCond_lo)
summary(OW061024_051124C_SpCond_hi)
dev.off


## Turbidity - YSI 6136 Turbidity Sensor Range 0 to 1000 NTU
# Identify where turbidity <0 NTU
identify_rows_turbidity_lo<-OW061024_051124C$Turbidity<0 
#count TRUE, FALSE, and NA values in vector turbidity <0
summary(identify_rows_turbidity_lo)

# Identify where turbidity >1000NTU
identify_rows_turbidity_hi<-OW061024_051124C$Turbidity>1000
#count TRUE, FALSE, and NA values in vector turbidity >1000
summary(identify_rows_turbidity_hi)
# If turbidity in the file is >1000NTU create a subset dataframe with these values.
subset(OW061024_051124C, Turbidity>1000 )

## In new dataframe, replace All Data Points outside the Measuring Range of Sensor with NA ##
# Replace all turbidity values greater than sensor measuring range (>1000 NTU) with NA and create new dataframe


OW061024_051124C_NoOutRange<- replace_with_na_at(OW061024_051124C, "Turbidity", ~ .x > 1000)

# Replace all turbidity values less than the measuring range (<0 NTU) with NA
OW061024_051124C_NoOutRange<- replace_with_na_at(OW061024_051124C_NoOutRange, "Turbidity", ~ .x < 0)

# Check datapoints have been replaced (both greater than and less than the measuring range)
identify_rows_turbidity_hi<-OW061024_051124C_NoOutRange$Turbidity>1000
summary(identify_rows_turbidity_hi)
identify_rows_turbidity_lo<-OW061024_051124C_NoOutRange$Turbidity<0 
summary(identify_rows_turbidity_lo)

# Save the edited dataframe to the working directory as .csv file
here::here()
write.csv(OW061024_051124C_NoOutRange, "04 Summary Statistics in R & Remove Outrange data/Output_Files/OW061024_051124C_NoOutRange.csv", row.names = FALSE)
saveRDS(OW061024_051124C_NoOutRange, "04 Summary Statistics in R & Remove Outrange data/Output_Files/OW061024_051124C_NoOutRange.rds")


## SUMMARY STATISTICS ##

df1<-as.data.frame(OW061024_051124C_NoOutRange)
data_summary<-stargazer(df1, type="text", title="River Owenmore, Sligo  06/10/24 to 05/11/24 (non-continuous) ", digits = 1, 
                        covariate.labels = c("Temperature (deg.C)", "Specific Conductance (uS/cm)", "Turbidity (NTU)"),
                        summary.stat=c("n","mean", "sd","min", "median","max"),
                        style="ajps",
                        out="04 Summary Statistics in R & Remove Outrange data/Output_Files/SummaryStats_OW061024_051124C.txt")


## Count the number of days when monitoring was carried out ##
n_distinct(OW061024_051124C_NoOutRange$`      Date`)
CountDays<-n_distinct(OW061024_051124C_NoOutRange$`      Date`)
CountDays


# Count no. of observations
NumberRowsOW061024_051124C<-nrow(OW061024_051124C_NoOutRange)
NumberRowsOW061024_051124C

# Record number of days and number of observations to file 
sink("04 Summary Statistics in R & Remove Outrange data/Output_Files/OW061024_051124C_countDays+Observations.txt", append = T)
CountDays
NumberRowsOW061024_051124C
sink()

# Session information
sessionInfo()
