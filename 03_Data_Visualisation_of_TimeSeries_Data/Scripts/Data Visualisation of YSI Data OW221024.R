### Data Visualisation of YSI Data using ggplot2 ###


# Install libraries
library(ggplot2)
library(scales)
library(plotly)

# set the timezone
Sys.setenv(TZ='UTC')

# Check the wd
here::here()

## Load the Datasets ##

### Load the RAINFALL Data ### 

##2.0 Import Weather Data File for Rain
Rainfall_Data<-readr::read_csv(here::here("./02_Import_Rainfall_and_Discharge_Data/Output_Files/Rainfall_Data_061024_051124.csv"))
str(Rainfall_Data)


### Load the DISCHARGE DATA FOR OWENMORE AT BALLYNACARROW ###

## 2.1 Import the discharge data for the River Owenmore
OW_Discharge_Data<-readr::read_delim(here::here("./02_Import_Rainfall_and_Discharge_Data/Output_Files/OW_Discharge_061024_051124.csv"))
OW_Discharge_Data


### LOAD YSI DATA FOR RIVER OWENMORE ###

# Load the YSI Sonde Dataset for the River Owenmore at Ballynacarrow
OW061024_051124C<-readRDS('./01_ImportYSI_Data/Output_Files/OW061024_051124C.Rdata')     
str(OW061024_051124C)

# PLOT THE DATA

# 2A Plot the Turbidity data 
ggplot(OW061024_051124C,aes(DateTime, Turbidity))+geom_point(size=0.5)+
  xlab("Date")+ylab("Turbidity (NTU)")+
  scale_x_datetime(labels = date_format("%d %b %Y"))+
  theme(axis.text.x = element_text(angle = 20))
 

# Name the object Turbidity Plot for specific Data file
OW061024_051124C_Turbidity_Plot<-ggplot(OW061024_051124C,aes(DateTime, Turbidity))+geom_point(size=0.5)+
  xlab("Date")+ylab("Turbidity (NTU)")+
  scale_x_datetime(labels = date_format("%d %b %Y"))+
  theme(axis.text.x = element_text(angle = 20))
OW061024_051124C_Turbidity_Plot

# interactive plot using plotly
OW061024_051124C_IntTurbidity_Plot<-ggplotly(OW061024_051124C_Turbidity_Plot)
OW061024_051124C_IntTurbidity_Plot
                                     
# 3A Plot the SpCond data 
ggplot(OW061024_051124C,aes(DateTime, SpCond))+geom_point(size=0.5)+
  xlab("Date")+ylab("SpConductivity (uS/cm)")+
  scale_x_datetime(labels = date_format("%d %b %Y"))+
  theme(axis.text.x = element_text(angle = 20))

# Name the object SpCond for specific data file
OW061024_051124C_SpCond_Plot<-ggplot(OW061024_051124C,aes(DateTime, SpCond))+geom_point(size=0.5)+
  xlab("Date")+ylab("SpCond. (uS/cm)")+
  scale_x_datetime(labels = date_format("%d %b %Y"))+
  theme(axis.text.x = element_text(angle = 20))
OW061024_051124C_SpCond_Plot


# interactive plot using plotly
OW061024_051124C_IntSpCond_Plot<-ggplotly(OW061024_051124C_SpCond_Plot)
OW061024_051124C_IntSpCond_Plot

#4A Plot the Temp Data
OW061024_051124C_Temp_Plot<-ggplot(OW061024_051124C, aes(DateTime,Temp)) + geom_point(size=0.5)+
  xlab("Date") + ylab(bquote(Temp. ("\u00B0C")))+
  scale_x_datetime(labels = date_format("%d %b %Y"))+
  theme(axis.text.x = element_text(angle = 20))+
  ylim(0, 20)
OW061024_051124C_Temp_Plot

# interactive temperature plot using plotly (plotly won't plot with customised symbols used for units in this case for the y axis label) )
OW061024_051124C_Temp_PlotV1<-ggplot(OW061024_051124C, aes(DateTime,Temp)) + geom_point(size=0.5)+
  xlab("Date") + ylab("Temp. deg.C")+
  scale_x_datetime(labels = date_format("%d %b %Y"))+
  theme(axis.text.x = element_text(angle = 20))+
  ylim(0, 20)
OW061024_051124C_Temp_PlotV1

OW061024_051124C_IntTemp_Plot<-ggplotly(OW061024_051124C_Temp_PlotV1)
OW061024_051124C_IntTemp_Plot


# Plot the Discharge Data
max(OW_Discharge_Data$Owenmore_Ballynacarrow_Discharge) # Helps to determine the range for the y-axis

ggplot(OW_Discharge_Data,aes(DateTime, Owenmore_Ballynacarrow_Discharge))+geom_point(size=0.5)+
  xlab("Date")+ylab(bquote(Discharge (m^3/s)))+
  scale_x_datetime(labels = date_format("%d %b %Y"))+
  theme(axis.text.x = element_text(angle = 20))+
  ylim(0, 40) # determines the scale range for the y-axis
  
# Name the object Discharge Plot for specific data file
OW061024_051124C_Discharge_Plot<-ggplot(OW_Discharge_Data,aes(DateTime, Owenmore_Ballynacarrow_Discharge))+geom_point(size=0.5)+
  xlab("Date")+ylab(bquote(Discharge (m^3/s)))+
  scale_x_datetime(labels = date_format("%d %b %Y"))+
  theme(axis.text.x = element_text(angle = 20))+
  ylim(0, 40)
OW061024_051124C_Discharge_Plot

##Plot the Rainfall Data ##
max(Rainfall_Data$rain) # Helps to determine the range for the y-axis

ggplot(Rainfall_Data,aes(DateTime, rain))+geom_line()+
  xlab("Date")+ylab("Rainfall (mm)")+
  scale_x_datetime(labels = date_format("%d %b %Y"))+
  ylim(0, 7)+
  theme(axis.text.x = element_text(angle = 20))
  
# Name the object Rainfall Plot for specific data file
OW061024_051124C_Rainfall_Plot<-ggplot(Rainfall_Data,aes(DateTime, rain))+geom_line()+
  xlab("Date")+ylab("Rainfall (mm)")+
  scale_x_datetime(labels = date_format("%d %b %Y"))+
  ylim(0, 7)+
  theme(axis.text.x = element_text(angle = 20))
OW061024_051124C_Rainfall_Plot

# Reverse plot the rainfall data - a traditional way of presenting rainfall data
OW061024_051124C_Rainfall_Plot_Rev<-ggplot(Rainfall_Data,aes(DateTime, rain))+geom_line()+scale_y_reverse()+
  xlab("Date")+ylab("Rainfall (mm)")
   
OW061024_051124C_Rainfall_Plot_Rev


### Plot the YSI Data alongside rainfall and discharge data ###

# Arrange all plots in one column and align by x-axis
library(cowplot)

Combination_OW061024_051124C_Plot<-plot_grid(OW061024_051124C_Rainfall_Plot, OW061024_051124C_Turbidity_Plot, 
                                     OW061024_051124C_Temp_Plot, OW061024_051124C_SpCond_Plot, OW061024_051124C_Discharge_Plot, ncol=1, align = "v")

Combination_OW061024_051124C_Plot



# To include a title on the plot 
library(gridExtra)
Comb_OW061024_051124C_PlotV1<-grid.arrange(OW061024_051124C_Rainfall_Plot_Rev, OW061024_051124C_Turbidity_Plot, 
                                 OW061024_051124C_Temp_Plot, OW061024_051124C_SpCond_Plot, OW061024_051124C_Discharge_Plot, 
                                ncol=1, bottom=textGrob("Figure 1: River Owenmore at Ballynacarrow", gp=gpar(fontsize=14, font=3) ))

### Save the Combined Plots ###
# Check the wd
here::here()

library(here)
ggsave(here("./02_Import_Rainfall_and_Discharge_Data/Output_Files", "Comb_OW061024_051124C_Plot.jpg"), Combination_OW061024_051124C_Plot)
