### Identification of Significant Change Thresholds for Turbidity ###

# Load the packages
library(data.table)
library(here)
library(dplyr)
library(ggplot2)
library(ggplotlyExtra)
library(plotly)
library(tidyverse)

# Import the Data File 
here() # find your project's files, based on the current working directory

OW061024_051124C_NoOutRange<-fread("04 Summary Statistics in R & Remove Outrange data/Output_Files/OW061024_051124C_NoOutRange.csv", header=T, stringsAsFactors = F)
str(OW061024_051124C_NoOutRange)

# Visualise the Data
# Plot the turbidity data and tell ggplot to remove NA values
OW061024_051124C_NoOutRange_Turbidity_Plot <- ggplot(OW061024_051124C_NoOutRange, aes(x = DateTime, y = Turbidity)) +
  geom_point(na.rm = TRUE)+
  scale_x_datetime(date_breaks = "1 week")+
  labs(x = "Time", y = "Turbidity (NTU)") +
  theme_minimal()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
OW061024_051124C_NoOutRange_Turbidity_Plot

## Save the OW061024_051124C_NoOutRange_Turbidity_Plot to a pdf document
pdf("05 SCT and highlight areas on plot for events/Output_Files/OW061024_051124C_NoOutRange_Turbidity_Plot.pdf")
print(OW061024_051124C_NoOutRange_Turbidity_Plot)
dev.off()

# Plot interactive turbidity plot.  Can be used to zoom in on areas of interest using zoom function above the plot when examining potential water quality events.
OW061024_051124C_NoOutRange_INT_Turbidity_Plot <- ggplotly(OW061024_051124C_NoOutRange_Turbidity_Plot)
OW061024_051124C_NoOutRange_INT_Turbidity_Plot


# Significant Change Threshold & Highlight potential water quality events on turbidity plots 

#Identify significant change threshold based on the Tukey Fences test for outliers.

# Significant Change Threshold & Highlight potential water quality events on turbidity plots

# This may be helpful for those unfamiliar with viewing time series plots.
# A statistical test, Tukey Fences test for outliers is used to identify
# potential turbidity outliers in the data, especically those high
# turbidity values occuring at the upper range of the data as these can
# indicate possible water quality events.
# The identified outliers will be highlighted in red on the plot and an interactive plot of
# turbidity values is plotted. This allows the analyst to manually verify possible
# turbidity events which can be used for the initial CANARY configuration (training).

# 5.3.1 Tukey Fences test for outliers
#### compute the Inter Quartile Range of the turbidity data. 
quantile(OW061024_051124C_NoOutRange$Turbidity, 0.25)
Q1<-quantile(OW061024_051124C_NoOutRange$Turbidity, 0.25)

quantile(OW061024_051124C_NoOutRange$Turbidity, 0.75)
Q3<- quantile(OW061024_051124C_NoOutRange$Turbidity, 0.75)

IQR<-Q3-Q1
print(IQR)
multiplier <- 1.5

# The upper bound and lower bound are the values of interest in terms of turbidity outliers.
# Calculate the Lower bound turbidity value

Q1-(IQR * multiplier) # Lower bound turbidity value
lower_bound<-Q1-(IQR * multiplier)

# Calculate the upper bound turbidity value
Q3 + (IQR*multiplier) # Upper bound 
upper_bound<-Q3 + (IQR*multiplier) # # These are the values of interest in terms of turbidity outliers.

# Identify where the turbidity is likely to be an outlier.
# An outlier is >/= upper bound in Tukey Fences.  Create a new variable (column) called 'Alarm Classify' where values are categorised as 1 (True) i.e. \>/= upper bound or 0 (False) i.e. \</= upper bound.

# Identify where Turbidity \>/= upper bound (Turbidity Threshold Value) and in a new variable (column) called Event Alarm, classify as 1 (true) or 0 (false)
OW061024_051124C_NoOutRange_TurbEvent<-OW061024_051124C_NoOutRange %>% mutate(Possible_Owenmore_Event_Alarm = if_else(
  Turbidity > upper_bound, true = 1, false = 0))

head(OW061024_051124C_NoOutRange_TurbEvent, 10)
str(OW061024_051124C_NoOutRange_TurbEvent)

# Count the number of observations where the turbidity \>/= upper bound and express as a percentage of the total number of turbidity values in the data frame.
# Count the number of True (1) values i.e. where turbidity >/= upper bound
print(Number_True_values<-length(which(OW061024_051124C_TurbEvent $Possible_Owenmore_Event_Alarm==1)))

# No of observations (i.e. number of values for each parameter in the data frame.  This is also the number of rows in the dataframe.)
print(Number_observations<-nrow(OW061024_051124C_NoOutRange))

# Percentage of values in dataframe where turbidity >/= upper bound
print(Percentage_turb_upperbound<-(Number_True_values/Number_observations)*100)


# Export as .csv file the observations where Turbidity \>/= upper bound.  This file contains the observations suspected of being a possible turbidity water quality event.
# Export OW061024_051124C_NoOutRange_TurbEvent as a .csv file
OW061024_051124C_NoOutRange_TurbEvent$DateTime<-format(OW061024_051124C_NoOutRange_TurbEvent$DateTime) # this prevents 00:00:00 being removed from Timestamps
write.csv(OW061024_051124C_NoOutRange_TurbEvent, '05 SCT and highlight areas on plot for events/Output_Files/OW061024_051124C_NoOutRange_TurbEvent.csv', row.names=FALSE)


# Significant Change Threshold & Highlight potential events on turbidity plots 


# Visualise the data where turbidity >/= upper bound

# Citation for the following code: Edward(2024) Highlight areas in a time series when y is greater than a threshold value and a range of values. 
# StackOverflow https://stackoverflow.com/questions/78469527/highlight-area-in-a-time-series-when-y-is-greater-than-a-threshold-value-and-a-r

# To help with visualising the turbidity values \>/= upper bound (\>/= Turbidity Threshold) on a plot, these values are highlighted on the plot as red lines.

Owenmore_Turbidity_Threshold_Plot<- ggplot(OW061024_051124C_NoOutRange, aes(x = DateTime, y = Turbidity)) +
  geom_point(na.rm = TRUE)+
  geom_rect(data = subset(OW061024_051124C_NoOutRange, Turbidity >=upper_bound),
            aes(xmin = DateTime-450, xmax = DateTime+450, ymin = -Inf, ymax = Inf),
            fill = "red", alpha = 0.3) +
  labs(x = "Time", y = "Turbidity (NTU)") +
  theme_minimal()
Owenmore_Turbidity_Threshold_Plot


# Interactive plot with highlighted areas on plot where turbidity is greater than the turbidity threshold value.
# Interactive plots are very useful for interrogating data and this interactive plot may aid in the identification of probable turbidity events for users unfamiliar with time series datasets.
# Use magnifying glass icon above the plot to open the plot full screen and click and drag the mouse to zoom in on an area, double click to zoom back out.  

# The code for this section is edited for this dataframe.  Citation for the following code: Kat(2024) Highlight areas of interactive time series plotly plot where y is greater than defined threshold and annotate them.
# StackOverflow https://stackoverflow.com/questions/78761758/highlight-areas-of-interactive-time-series-plotly-plot-where-y-is-greater-than-d


# Plot an interactive plot for turbidity with turbidity values \>/= upper bound (\>/= Turbidity Threshold) highlighted on the plot as red lines.

fixer <- function(plt) {  
  plt <- plotly_build(plt)              # make sure entire plot built
  lapply(1:length(plt$x$data), \(k) {   # go through each trace (layer) 
    plt$x$data[[k]]$x <<- as.POSIXct(plt$x$data[[k]]$x) # update x-axis data type
  })
  plt
}
tSpan <- function(gplt) {  # gplt: ggplot graph to be made into a ggplotly 
  #  - assuming one x-axis within gplt
  #  - assuming geom_rect called 2nd in gplt
  
  # 2 here, because geom_rect was called 2nd            --- get data from plot
  dta <- data.frame(ggplot_build(gplt)$data[[2]][c("xmin", "xmax", "fill", "alpha")]) %>% 
    mutate(xmin = as.POSIXct(xmin), xmax = as.POSIXct(xmax))
  
  shps <- map(1:nrow(dta), \(k) {    # create data used in geom_rect
    list(type = "rect", xref = "x", yref = "paper",  # define shape, use x axis, not y axis
         x0 = dta$xmin[k], x1 = dta$xmax[k],         # where on x
         y0 = 0, y1 = 1,                             # where on plot (versus y)
         # update aesthetics
         fillcolor = dta$fill[1], opacity = dta$alpha[1], line = list(width = 0))
  })
  
  ggplotly(gplt) %>%              # pre xaxis for dates
    layout(xaxis = list(tickmode = "auto", type = "date", autorange = T),
           shapes = NA) %>%            # remove migration garbage
    fixer() %>%                        # fix dates - make them dates again
    layout(shapes = shps)              # add new shapes
}
tSpan(Owenmore_Turbidity_Threshold_Plot)

# Save the plot
ggsave(here("05 SCT and highlight areas on plot for events/Output_Files", "Owenmore_Turbidity_Threshold_Plot.jpg"), Owenmore_Turbidity_Threshold_Plot)

# Session Information
sessionInfo()
