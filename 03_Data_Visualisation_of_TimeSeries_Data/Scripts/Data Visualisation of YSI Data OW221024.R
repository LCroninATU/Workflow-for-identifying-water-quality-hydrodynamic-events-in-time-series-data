### Data Visualisation of YSI Data using ggplot2 ###


# Load libraries - you may need to install them first. 
library(ggplot2)
library(scales)
library(plotly)
library(cowplot)
library (gridExtra)
library(grid)

# set the timezone
Sys.setenv(TZ='UTC')

# Check the wd
here::here()

## Load the Datasets ##

### LOAD YSI DATA FOR RIVER OWENMORE ###

# Load the YSI Sonde Dataset for the River Owenmore at Ballynacarrow
OW061024_051124C<-readRDS('./02_Embed_Source_Data_context/Output_Files/OW061024_051124C.rds')     
str(OW061024_051124C)

## 3.2 Visualise the Data using ggplot2 and ggplotly
# Data is visualised which aids in understanding the data.  There are two type of plots created:
# 1. Static plots which appear as an image can be viewed in the Plots tab and 
# 2. Interactive plots where can be viewed in the viewer tab. With interactive plots, you can hover over specific data points and the value will be displayed, you can zoom in on an area of a plot by click and drag with the mouse, and zoom out completely by double clicking.  Video resources are available online for ggplotly if you want to learn more. 
 

# PLOT THE DATA

# Plot the turbidity data
ggplot(OW061024_051124C,aes(DateTime, Turbidity))+
  geom_point(size=0.5)+
  xlab("Date")+
  ylab("Turbidity (NTU)")+
  scale_x_datetime(
    labels = date_format("%d %b %Y"),
    breaks = date_breaks("2 days"))+
  theme(axis.text.x = element_text(angle = 20))

## Name the object Turbidity Plot for specific Data file
OW061024_051124C_Turbidity_Plot<-ggplot(OW061024_051124C,aes(DateTime, Turbidity))+
  geom_point(size=0.5)+
  xlab("Date")+
  ylab("Turbidity (NTU)")+
  scale_x_datetime(
    labels = date_format("%d %b %Y"),
    breaks = date_breaks("2 days"))+
  theme(axis.text.x = element_text(angle = 20))

OW061024_051124C_Turbidity_Plot

# interactive plot using plotly
OW061024_051124C_IntTurbidity_Plot<-ggplotly(OW061024_051124C_Turbidity_Plot)
OW061024_051124C_IntTurbidity_Plot
  

# Plot the Specific Conductance data                                
# Plot the SpCond data 
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


# interactive plot for specific conductance using plotly
OW061024_051124C_IntSpCond_Plot<-ggplotly(OW061024_051124C_SpCond_Plot)
OW061024_051124C_IntSpCond_Plot

# Plot the Temperature Data
# Plot the Temp Data
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


# Plot the water quality data together in one plot
# You can zoom in on a plot using zoom in the Plots tab.
# Arrange all plots in one column and align by x-axis

Comb_OW061024_051124C<-plot_grid(OW061024_051124C_Turbidity_Plot, 
                                 OW061024_051124C_Temp_Plot, OW061024_051124C_SpCond_Plot, ncol=1, align = "v")

Comb_OW061024_051124C



# To include a title on the plot 
Comb_OW061024_051124CV1<-grid.arrange(OW061024_051124C_Turbidity_Plot, 
                                      OW061024_051124C_Temp_Plot, OW061024_051124C_SpCond_Plot, ncol=1, bottom=textGrob("Figure 1: River Owenmore at Ballynacarrow", gp=gpar(fontsize=14, font=3) ))

 
# Save the Combined Plots
ggsave(here("./03_Data_Visualisation_of_TimeSeries_Data/Output_Files", "Comb_OW061024_051124C_Plot.jpg"), Comb_OW061024_051124C)
