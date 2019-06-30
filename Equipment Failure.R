#Load Libraries
library(tidyverse)
library(dplyr)
library(anomalize)
library(tibbletime)
library(AnomalyDetection)
library(devtools)
library(ggplot2)
library(reshape2)
library(car)
library(caret)
library(e1071)
library(rpart)
library(forecast)
library(TTR)

#load datasets
#Vibration sensor data data
VS1 <- read.delim("~/MSDS_692 Data Science Practicum I/Hydraulic Systems Data Set/VS1.txt", header=FALSE)

#Volume flow sensor data
FS1 <- read.delim("~/MSDS_692 Data Science Practicum I/Hydraulic Systems Data Set/FS1.txt", header=FALSE)
FS2 <- read.delim("~/MSDS_692 Data Science Practicum I/Hydraulic Systems Data Set/FS2.txt", header=FALSE)


#Efficiency facotor
SE <- read.delim("~/MSDS_692 Data Science Practicum I/Hydraulic Systems Data Set/SE.txt", header=FALSE)

#Temperature sensor data
TS1 <- read.delim("~/MSDS_692 Data Science Practicum I/Hydraulic Systems Data Set/TS1.txt", header=FALSE)
TS2 <- read.delim("~/MSDS_692 Data Science Practicum I/Hydraulic Systems Data Set/TS2.txt", header=FALSE)
TS3 <- read.delim("~/MSDS_692 Data Science Practicum I/Hydraulic Systems Data Set/TS3.txt", header=FALSE)
TS4 <- read.delim("~/MSDS_692 Data Science Practicum I/Hydraulic Systems Data Set/TS4.txt", header=FALSE)

#Vibration Sensor data
VS1 <- read.delim("~/MSDS_692 Data Science Practicum I/Hydraulic Systems Data Set/VS1.txt", header=FALSE)

#Virtual cooling efficiency sensor data
CE <- read.delim("~/MSDS_692 Data Science Practicum I/Hydraulic Systems Data Set/CE.txt", header=FALSE)

#Virtual Cooling Power Sensor data
CP <- read.delim("~/MSDS_692 Data Science Practicum I/Hydraulic Systems Data Set/CP.txt", header=FALSE)

#Pressure sensors
PS1 <- read.delim("~/MSDS_692 Data Science Practicum I/Hydraulic Systems Data Set/PS1.txt", header=FALSE)
PS2 <- read.delim("~/MSDS_692 Data Science Practicum I/Hydraulic Systems Data Set/PS2.txt", header=FALSE)
PS3 <- read.delim("~/MSDS_692 Data Science Practicum I/Hydraulic Systems Data Set/PS3.txt", header=FALSE)
PS4 <- read.delim("~/MSDS_692 Data Science Practicum I/Hydraulic Systems Data Set/PS4.txt", header=FALSE)
PS5 <- read.delim("~/MSDS_692 Data Science Practicum I/Hydraulic Systems Data Set/PS5.txt", header=FALSE)
PS6 <- read.delim("~/MSDS_692 Data Science Practicum I/Hydraulic Systems Data Set/PS6.txt", header=FALSE)

#Motor power sensor data
EPS1 <- read.delim("~/MSDS_692 Data Science Practicum I/Hydraulic Systems Data Set/EPS1.txt", header=FALSE)

#Profile data for sensors
profile <- read.delim("~/MSDS_692 Data Science Practicum I/Hydraulic Systems Data Set/profile.txt", header=FALSE)
#add column names
colnames(profile)<-c("Cooler","Valve","Leakage","Bar","Stable flag")

#create mean for datasets
CE_DF<-as.data.frame(rowMeans(CE))
CP_DF=as.data.frame(rowMeans(CP))
EPS1_DF=as.data.frame(rowMeans(EPS1))
FS1_DF=as.data.frame(rowMeans(FS1))
FS2_DF=as.data.frame(rowMeans(FS2))
PS1_DF=as.data.frame(rowMeans(PS1))
PS2_DF=as.data.frame(rowMeans(PS2))
PS3_DF=as.data.frame(rowMeans(PS3))
PS4_DF=as.data.frame(rowMeans(PS4))
PS5_DF=as.data.frame(rowMeans(PS5))
PS6_DF=as.data.frame(rowMeans(PS6))
SE_DF=as.data.frame(rowMeans(SE))
TS1_DF=as.data.frame(rowMeans(TS1))
TS2_DF=as.data.frame(rowMeans(TS2))
TS3_DF=as.data.frame(rowMeans(TS3))
TS4_DF=as.data.frame(rowMeans(TS4))
VS1_DF=as.data.frame(rowMeans(VS1))

#Combine dataframes into one
df<-cbind(CE_DF,CP_DF,EPS1_DF,FS1_DF,FS2_DF,PS1_DF,PS2_DF,PS3_DF,PS4_DF,PS5_DF,
          PS6_DF,SE_DF,TS1_DF,TS2_DF,TS3_DF,TS4_DF,VS1_DF)

#rename columns in dataframe
colnames(df)<-c('CE','CP','EPS1','FS1','FS2','PS1','PS2','PS3','PS4','PS5',
                'PS6','SE','TS1','TS2','TS3','TS4','VS1')

##################  Exploratory Data Analysis ########################
#summary of readings data frame
summary(df)

#boxplot of readings df
#this shows that a handful of the readings
#have outliers: EPS1, FS1, PS1, PS2, PS3, PS4, SE, VS1
boxplot(df, main = "Sensor Readings")

#combine profile data frame to all of the readings
df2<-cbind(df,profile)
head(df2)

##add column for time of cycle for readings
##each cycle runs for 60 seconds so time is in minute increments
##Note: Random Date was selected since timeframe was not provided
df2$Time<-seq(ISOdatetime(2019,2,3,0,0,0), ISOdatetime(2019,2,4,12,44,0), 
              by=(60*1))

#histograms of the readings by frequency
hist(df2$CE, main = "Cooling Efficiency Sensor", xlab = "Sensor Reading", c="blue")
hist(df2$CP, main = "Cooling Power Sensor", xlab = "Sensor Reading", c="blue")
hist(df2$EPS1, main = "EPS1/Motor Power Sensor", xlab = "Sensor Reading", c="blue")
hist(df2$FS1, main = "FS1/Volume Flow Sensor", xlab = "Sensor Reading", c="blue")
hist(df2$FS2, main = "FS2/Volume Flow Sensor", xlab = "Sensor Reading", c="blue")
hist(df2$PS1, main = "PS1/Pressure Sensor", xlab = "Sensor Reading", c="blue")
hist(df2$PS2, main = "PS2/Pressure Sensor", xlab = "Sensor Reading", c="blue")
hist(df2$PS3, main = "PS3/Pressure Sensor", xlab = "Sensor Reading", c="blue")
hist(df2$PS4, main = "PS4/Pressure Sensor", xlab = "Sensor Reading", c="blue")
hist(df2$PS5, main = "PS5/Pressure Sensor", xlab = "Sensor Reading", c="blue")
hist(df2$PS6, main = "PS6/Pressure Sensor", xlab = "Sensor Reading", c="blue")
hist(df2$SE, main = "SE/Efficiency Factor", xlab = "Sensor Reading", c="blue")
hist(df2$TS1, main = "TS1/Temperature Sensor", xlab = "Sensor Reading", c="blue")
hist(df2$TS2, main = "TS2/Temperature Sensor", xlab = "Sensor Reading", c="blue")
hist(df2$TS3, main = "TS3/Temperature Sensor", xlab = "Sensor Reading", c="blue")
hist(df2$TS4, main = "TS4/Temperature Sensor", xlab = "Sensor Reading", c="blue")
hist(df2$VS1, main = "VS1/Vibration Sensor", xlab = "Sensor Reading", c="blue")
hist(df2$Cooler, main = "Cooler Condition", xlab = "Condition", c="blue")
hist(df2$Valve, main = "Valve Condition", xlab = "Condition", c="blue")
hist(df2$Leakage, main = "Internal Pump Leakage", xlab = "Condition", c="blue")
hist(df2$Bar, main = "Hydraulic Accumulator/Bar Condition", xlab = "Condition", c="blue")
hist(df2$`Stable flag`, main = "Stability Flag", xlab = "Rating", c="blue")

#View sensor/readings over time
ggplot(df2, aes(x=Time, y=Cooler)) + geom_point() +ggtitle("Cooler Condition Over Time")
ggplot(df2, aes(x = Time, y =  Valve)) + geom_point() +ggtitle("Valve Condition Over Time")
ggplot(df2, aes(x = Time, y =  `Stable flag`)) + geom_point() +ggtitle("Stability Flag Over Time")
ggplot(df2, aes(x = Time, y = Leakage)) + geom_point() +ggtitle("Internal Pump Leakage Over Time")
ggplot(df2, aes(x = Time, y =  Bar)) + geom_point() +ggtitle("Hydraulic Accumulator/Bar Condition Over Time")
ggplot(df2, aes(x = Time, y = CE)) + geom_line() +ggtitle("Cooling Efficiency Sensor Over Time")
ggplot(df2, aes(x = Time, y = CP)) + geom_line() +ggtitle("Cooling Power Sensor Over Time")
ggplot(df2, aes(x = Time, y = EPS1)) + geom_line() +ggtitle("EPS1/Motor Power Sensor Over Time")
ggplot(df2, aes(x = Time, y = FS1)) + geom_line() +ggtitle("FS1/Volume Flow Sensor Over Time")
ggplot(df2, aes(x = Time, y = FS2)) + geom_line() +ggtitle("FS2/Volume Flow Sensor Over Time")
ggplot(df2, aes(x = Time, y = PS1)) + geom_line() +ggtitle("PS1/Pressure Sensor Over Time")
ggplot(df2, aes(x = Time, y = PS2)) + geom_line() +ggtitle("PS2/Pressure Sensor Over Time")
ggplot(df2, aes(x = Time, y = PS3)) + geom_line() +ggtitle("PS3/Pressure Sensor Over Time")
ggplot(df2, aes(x = Time, y = PS4)) + geom_line() +ggtitle("PS4/Pressure Sensor Over Time")
ggplot(df2, aes(x = Time, y = PS5)) + geom_line() +ggtitle("PS5/Pressure Sensor Over Time")
ggplot(df2, aes(x = Time, y = PS6)) + geom_line() +ggtitle("PS6/Pressure Sensor Over Time")
ggplot(df2, aes(x = Time, y = SE)) + geom_line() +ggtitle("SE/Efficiency Factor Over Time")
ggplot(df2, aes(x = Time, y = TS1)) + geom_line() +ggtitle("TS1/Temperature Sensor Over Time")
ggplot(df2, aes(x = Time, y = TS2)) + geom_line() +ggtitle("TS2/Temperature Sensor Over Time")
ggplot(df2, aes(x = Time, y = TS3)) + geom_line() +ggtitle("TS3/Temperature Sensor Over Time")
ggplot(df2, aes(x = Time, y = TS4)) + geom_line() +ggtitle("TS4/Temperature Sensor Over Time")
ggplot(df2, aes(x = Time, y = VS1)) + geom_line() +ggtitle("VS1/Vibration Sensor Over Time")


#melt df 
meltdf<-melt(df2, id = "Time")
ggplot(meltdf, aes(x = Time, y=value, colour = variable, group= variable))+geom_line()+ggtitle("Sensor Data")
ggplot(meltdf, aes(x=variable, y=value, group=variable))+geom_boxplot()+ggtitle("Sensor Data")
#the results of this indicate that we need to normalize the data

######Normalize data 
##Create normalize function based on min max
normalize<-function(x){return((x-min(x)) / (max(x)))}
#create new df with only the sensor readings with normalized data
dfNorm<-as.data.frame(lapply(df, normalize))
#add in time for sensor readings
dfNorm$Time<-seq(ISOdatetime(2019,2,3,0,0,0), ISOdatetime(2019,2,4,12,44,0), 
                 by=(60*1))
#Create a new df using Melt function based on time
meltdf<-melt(dfNorm, id = "Time")
ggplot(meltdf, aes(x=Time, y=value, colour=variable, group=variable))+geom_line()+ggtitle("All Readings Over Time - Normalized")
ggplot(meltdf, aes(x=variable, y=value, group=variable))+geom_point()+ggtitle("All Data - Normalized")
ggplot(meltdf, aes(x=Time, y=value, colour = variable, group=variable))+geom_point()

######## Add in profile data 
#create new df with all data with normalized data including equipment condition
dfNorm2<-as.data.frame(lapply(df2, normalize))
#add in time for sensor readings
dfNorm2$Time<-seq(ISOdatetime(2019,2,3,0,0,0), ISOdatetime(2019,2,4,12,44,0), 
                  by=(60*1))
#visuals to include profile info
meltdf2<-melt(dfNorm2, id = "Time")
ggplot(meltdf2, aes(x=variable, y=value, group=variable))+geom_point()+ggtitle("All Data - Normalized")
ggplot(meltdf2, aes(x=variable, y=value, group=variable))+geom_boxplot()+ggtitle("All Data - Normalized")


############### Correlation between varibales ###########################
library(ggplot2)
install.packages('GGally')
library(GGally)

#Determine correlation between sensor information and equipment condition
#The closer the correlation coefficient is to 1, the stronger the relationship

#correlation heat matrix all variables
ggcorr(df2, palette = "RdGy", label = TRUE)+ggtitle("Correlation Matrix")


#################### Time Series Format #######################

#change to tibble format
ts<-as_tbl_time(df2, index = Time)

#verify class and view first few rows
class(ts)
head(ts)

#################### Time Series EDA ##########################
################### ACF/PACF for Variables ###################
### View ACF/PACF For Valve condition variable
tsdisplay(ts$Valve, main = "Valve Condition Overview")

### View ACF/PACF For Cooler condition variable
tsdisplay(ts$Cooler, main = "Cooler Condition Overview")

### View ACF/PACF For Leakage condition variable
tsdisplay(ts$Leakage, main = "Internal Pump Leakage Condition Overview")

### View ACF/PACF For Bar condition variable
tsdisplay(ts$Bar, main = "Hydraulic Accumulator/Bar Condition Overview")

### View ACF/PACF For Valve condition variable
tsdisplay(ts$PS1, main = "Valve Condition Overview")


################## Anomaly Detection ################################
############### Anomaly Detection of Remainder on Decomposed Data ###
##STL uses seasonal decomposition using a Loess Smoother
##IQR is a fast and relatively accurate method to detect anomalies
##Default parameters for alpha  = 0.05 and max_anoms = 0.2

############### Decomposition Visualization on Sensors ################
###########   Observed, Season, Trend and Remainder   ################

##### CE SENSOR
ts %>%
  time_decompose(CE, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  #visualization
  plot_anomaly_decomposition() +
  ggtitle("Cooling Efficiency Sensor Anomaly Decomposition")

##### CP SENSOR
ts %>%
  time_decompose(CP, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  #visualization
  plot_anomaly_decomposition() +
  ggtitle("Cooling Power Sensor Anomaly Decomposition")

##### EPS1 SENSOR
ts %>%
  time_decompose(EPS1, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  #visualization
  plot_anomaly_decomposition() +
  ggtitle("EPS1/Motor Power Sensor Anomaly Decomposition")

##### FS1 SENSOR
ts %>%
  time_decompose(FS1, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  #visualization
  plot_anomaly_decomposition() +
  ggtitle("FS1/Volume Flow Sensor Anomaly Decomposition")

##### FS2 SENSOR
ts %>%
  time_decompose(FS2, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  #visualization
  plot_anomaly_decomposition() +
  ggtitle("FS2/Volume Flow Sensor Anomaly Decomposition")

##### PS1 SENSOR
ts %>%
  time_decompose(PS1, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  #visualization
  plot_anomaly_decomposition() +
  ggtitle("PS1/Pressure Sensor Anomaly Decomposition")

##### PS2 SENSOR
ts %>%
  time_decompose(PS2, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  #visualization
  plot_anomaly_decomposition() +
  ggtitle("PS2/Pressure Sensor Anomaly Decomposition")

##### PS3 SENSOR
ts %>%
  time_decompose(PS3, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  #visualization
  plot_anomaly_decomposition() +
  ggtitle("PS3/Pressure Sensor Anomaly Decomposition")

##### PS4 SENSOR
ts %>%
  time_decompose(PS4, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  #visualization
  plot_anomaly_decomposition() +
  ggtitle("PS4/Pressure Sensor Anomaly Decomposition")

##### PF5 SENSOR
ts %>%
  time_decompose(PS5, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  #visualization
  plot_anomaly_decomposition() +
  ggtitle("PS5/Pressure Sensor Anomaly Decomposition")

##### PS6 SENSOR
ts %>%
  time_decompose(PS6, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  #visualization
  plot_anomaly_decomposition() +
  ggtitle("PS6/Pressure Sensor Anomaly Decomposition")


##### SE SENSOR
ts %>%
  time_decompose(SE, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  #visualization
  plot_anomaly_decomposition() +
  ggtitle("SE/Efficiency Factor Anomaly Decomposition")

##### TS1 SENSOR
ts %>%
  time_decompose(TS1, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  #visualization
  plot_anomaly_decomposition() +
  ggtitle("TS1/Temperature Sensor Anomaly Decomposition")

##### TS2 SENSOR
ts %>%
  time_decompose(TS2, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  #visualization
  plot_anomaly_decomposition() +
  ggtitle("TS2/Temperature Sensor Anomaly Decomposition")

##### TS3 SENSOR
ts %>%
  time_decompose(TS3, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  #visualization
  plot_anomaly_decomposition() +
  ggtitle("TS3/Temperature Sensor Anomaly Decomposition")

##### TS4 SENSOR
ts %>%
  time_decompose(TS4, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  #visualization
  plot_anomaly_decomposition() +
  ggtitle("TS4/Temperature Sensor Anomaly Decomposition")


##### VS1 SENSOR
ts %>%
  time_decompose(VS1, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  #visualization
  plot_anomaly_decomposition() +
  ggtitle("VS1/Vibration Sensor Anomaly Decomposition")


##### COOLER CONDITION
ts %>%
  time_decompose(Cooler, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  #visualization
  plot_anomaly_decomposition() +
  ggtitle("Cooler Condition Anomaly Decomposition")

##### Valve Condition
ts %>%
  time_decompose(Valve, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  #visualization
  plot_anomaly_decomposition() +
  ggtitle("Valve Condition Anomaly Decomposition")

##### Leakage
ts %>%
  time_decompose(Leakage, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  #visualization
  plot_anomaly_decomposition() +
  ggtitle("Internal Pump Leakage Anomaly Decomposition")

##### Bar
ts %>%
  time_decompose(Bar, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  #visualization
  plot_anomaly_decomposition() +
  ggtitle("Hydraulic Accumulator/Bar Anomaly Decomposition")



#################  Anomaly Visualizations on Sensors ###############
#################  Lower and upper bounds shown      ###############

######  CE Sensor
ts %>%
  time_decompose(CE, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  time_recompose() %>%
  #visualize
  plot_anomalies(time_recomposed = TRUE) + 
  ggtitle("Cooling Efficiency Sensor Anomalies - Lower & Upper Bounds") 

######  CP Sensor
ts %>%
  time_decompose(CP, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  time_recompose() %>%
  #visualize
  plot_anomalies(time_recomposed = TRUE) + 
  ggtitle("Cooling Power Sensor Anomalies - Lower & Upper Bounds")


######  EPS1 Sensor
ts %>%
  time_decompose(EPS1, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  time_recompose() %>%
  #visualize
  plot_anomalies(time_recomposed = TRUE) + 
  ggtitle("EPS1/Motor Power Sensor Anomalies - Lower & Upper Bounds")


######  FS1 Sensor
ts %>%
  time_decompose(FS1, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  time_recompose() %>%
  #visualize
  plot_anomalies(time_recomposed = TRUE) + 
  ggtitle("FS1/Volume Flow Sensor Anomalies - Lower & Upper Bounds")


######  FS2 Sensor
ts %>%
  time_decompose(FS2, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  time_recompose() %>%
  #visualize
  plot_anomalies(time_recomposed = TRUE) + 
  ggtitle("FS2/Volume Flow Sensor Anomalies - Lower & Upper Bounds")


######  PS1 Sensor
ts %>%
  time_decompose(PS1, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  time_recompose() %>%
  #visualize
  plot_anomalies(time_recomposed = TRUE) + 
  ggtitle("PS1/Pressure Sensor Anomalies - Lower & Upper Bounds")


######  PS2 Sensor
ts %>%
  time_decompose(PS2, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  time_recompose() %>%
  #visualize
  plot_anomalies(time_recomposed = TRUE) + 
  ggtitle("PS2/Pressure Sensor Anomalies - Lower & Upper Bounds")


######  PS3 Sensor
ts %>%
  time_decompose(PS3, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  time_recompose() %>%
  #visualize
  plot_anomalies(time_recomposed = TRUE) + 
  ggtitle("PS3/Pressure Sensor Anomalies - Lower & Upper Bounds")


######  PS4 Sensor
ts %>%
  time_decompose(PS4, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  time_recompose() %>%
  #visualize
  plot_anomalies(time_recomposed = TRUE) + 
  ggtitle("PS4/Pressure Sensor Anomalies - Lower & Upper Bounds")


######  PS5 Sensor
ts %>%
  time_decompose(PS5, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  time_recompose() %>%
  #visualize
  plot_anomalies(time_recomposed = TRUE) + 
  ggtitle("PS5/Pressure Sensor Anomalies - Lower & Upper Bounds")

######  PS6 Sensor
ts %>%
  time_decompose(PS6, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  time_recompose() %>%
  #visualize
  plot_anomalies(time_recomposed = TRUE) + 
  ggtitle("PS6/Pressure Sensor Anomalies - Lower & Upper Bounds")

######  SE Sensor
ts %>%
  time_decompose(SE, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  time_recompose() %>%
  #visualize
  plot_anomalies(time_recomposed = TRUE) + 
  ggtitle("SE/Efficiency Factor Anomalies - Lower & Upper Bounds")

######  TS1 Sensor
ts %>%
  time_decompose(TS1, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  time_recompose() %>%
  #visualize
  plot_anomalies(time_recomposed = TRUE) + 
  ggtitle("TS1/Temperature Sensor Anomalies - Lower & Upper Bounds")

######  TS2 Sensor
ts %>%
  time_decompose(TS2, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  time_recompose() %>%
  #visualize
  plot_anomalies(time_recomposed = TRUE) + 
  ggtitle("TS2/Temperature Sensor Anomalies - Lower & Upper Bounds")

######  TS3 Sensor
ts %>%
  time_decompose(TS3, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  time_recompose() %>%
  #visualize
  plot_anomalies(time_recomposed = TRUE) + 
  ggtitle("TS3/Temperature Sensor Anomalies - Lower & Upper Bounds")

######  TS4 Sensor
ts %>%
  time_decompose(TS4, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  time_recompose() %>%
  #visualize
  plot_anomalies(time_recomposed = TRUE) + 
  ggtitle("TS4/Temperature Sensor Anomalies - Lower & Upper Bounds")

######  VS1 Sensor
ts %>%
  time_decompose(VS1, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  time_recompose() %>%
  #visualize
  plot_anomalies(time_recomposed = TRUE) + 
  ggtitle("VS1/Vibration Sensor Anomalies - Lower & Upper Bounds")

######  COOLER CONDITION
ts %>%
  time_decompose(Cooler, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  time_recompose() %>%
  #visualize
  plot_anomalies(time_recomposed = TRUE) + 
  ggtitle("Cooler Condition Anomalies - Lower & Upper Bounds")

######  Valve Condition 
ts %>%
  time_decompose(Valve, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  time_recompose() %>%
  #visualize
  plot_anomalies(time_recomposed = TRUE) + 
  ggtitle("Valve Condition Anomalies - Lower & Upper Bounds")

######  Leakage
ts %>%
  time_decompose(Leakage, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  time_recompose() %>%
  #visualize
  plot_anomalies(time_recomposed = TRUE) + 
  ggtitle("Internal Pump Leakage Anomalies - Lower & Upper Bounds")

######  Bar Condition
ts %>%
  time_decompose(Bar, method = "stl",
                 frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr", alpha = 0.05,
            max_anoms = 0.2) %>%
  time_recompose() %>%
  #visualize
  plot_anomalies(time_recomposed = TRUE) + 
  ggtitle(" Hydraulic Accumulator/Bar Condition Anomalies - Lower & Upper Bounds")

################### Training and Test Datasets #####################
####################################################################

library(ISLR)
smp_siz = floor(0.75*nrow(df2)) #create value for dividing data into train and test sets
smp_siz #view sample size

set.seed(1234) #set seed to be able to reproduce
train_ind = sample(seq_len(nrow(df2)),size=smp_siz) #randomly identify the rows = to sample size
train=df2[train_ind,] #create training dataset with row #s from train_ind
test=df2[-train_ind,] #create test dataset excluding row numbers in train_ind



################### Equipment Condition Predictions #############
##############  SVM Model to predict Valve condition ###########

#create new df of train and test dataset
#based on previously created train/test dataset
svm_train<-train
svm_test<-test

#change target variable (valve) to factor
svm_train[["Valve"]] = factor(svm_train[["Valve"]])
svm_test[["Valve"]] = factor(svm_test[["Valve"]])

#train svm model
trctrl<-trainControl(method = "repeatedcv", number = 10, repeats = 3)
set.seed(3233)
svm_linear<-train(Valve ~., data = svm_train, method = "svmLinear",
                  trControl=trctrl,
                  preProcess=c("center", "scale"),
                  tuneLength = 10)
#check model result
svm_linear

#predict classes in test set
svm_test_pred<-predict(svm_linear, newdata = svm_test)

#view predictions
svm_test_pred

#confusion matrix to determine accuracy
confusionMatrix(svm_test_pred, svm_test$Valve)

#plot predictions
plot(x=svm_test$Time, y=svm_test$Valve, pch=19, 
     main = "Valve Condition Predictions - SVM Method",
     xlab = "Time", ylab = "Valve Condition")
#identify accuracy of test dataset and predictions
points(svm_test$Time, svm_test_pred, pch=15, col="red" )


###############SVM Model to predict cooler condition ###############
#change target variable (cooler) to factor
svm_train[["Cooler"]] = factor(svm_train[["Cooler"]])
svm_test[["Cooler"]] = factor(svm_test[["Cooler"]])

#Train model
svm_linear_c<-train(Cooler ~., data = svm_train, method = "svmLinear",
                    trControl=trctrl,
                    preProcess=c("center", "scale"),
                    tuneLength = 10)
#check model result
svm_linear_c

#predict classes in test set
svm_test_pred_c<-predict(svm_linear_c, newdata = svm_test)
#view predictions
svm_test_pred_c

#confusion matrix to determine accuracy
confusionMatrix(svm_test_pred_c, svm_test$Cooler)

#visualize results
plot(x=svm_test$Time, y=svm_test$Cooler, pch=19, 
     main = "Cooler Condition Predictions - SVM Method",
     xlab = "Time", ylab = "Cooler Condition")
points(svm_test$Time, svm_test_pred_c, pch=15, col="red" )

###############SVM Model to predict pump leakage ###############
#change target variable (Leakage) to factor
svm_train[["Leakage"]] = factor(svm_train[["Leakage"]])
svm_test[["Leakage"]] = factor(svm_test[["Leakage"]])

#train svm model
svm_linear_l<-train(Leakage ~., data = svm_train, method = "svmLinear",
                    trControl=trctrl,
                    preProcess=c("center", "scale"),
                    tuneLength = 10)
#check model result
svm_linear_l

#predict classes in test set
svm_test_pred_l<-predict(svm_linear_l, newdata = svm_test)
#view predictions
svm_test_pred_l

#confusion matrix to determine accuracy
confusionMatrix(svm_test_pred_l, svm_test$Leakage)

#visualize results
plot(x=svm_test$Time, y=svm_test$Leakage, pch=19, 
     main = "Internal Pump Leakage Predictions - SVM Method",
     xlab = "Time", ylab = "Internal Pump Leakage")
points(svm_test$Time, svm_test_pred_l, pch=15, col="red" )


###############SVM Model to predict Hydraulic Accumulator/Bar condition ###############
#change target variable (Bar) to factor
svm_train[["Bar"]] = factor(svm_train[["Bar"]])
svm_test[["Bar"]] = factor(svm_test[["Bar"]])
#train svm model
svm_linear_b<-train(Bar ~., data = svm_train, method = "svmLinear",
                    trControl=trctrl,
                    preProcess=c("center", "scale"),
                    tuneLength = 10)
#check model result
svm_linear_b

#predict classes in test set
svm_test_pred_b<-predict(svm_linear_b, newdata = svm_test)
#view predictions
svm_test_pred_b


#confusion matrix to determine accuracy
confusionMatrix(svm_test_pred_b, svm_test$Bar)

#visualize results
plot(x=svm_test$Time, y=svm_test$Bar, pch=19, 
     main = "Hydraulic Accumulator/Bar Predictions - SVM Method",
     xlab = "Time", ylab = "Hydraulic Accumulator/Bar Condition")
points(svm_test$Time, svm_test_pred_b, pch=15, col="red" )




##################### ETS Model and Forecast ###############################
############################################################################

###### Cooler ETS function/forecast
#use ets function to auto choose a model by default
cooler_fit_ets<-ets(ts$Cooler)
cooler_fit_ets #view results
#Check residuals
checkresiduals(cooler_fit_ets)
#accuracy function is used to see the predictive accuracy
accuracy(cooler_fit_ets)
#forecast for the next 500 cycles
cooler_pred_ets<-forecast(cooler_fit_ets, h=500)
#view forecast results
cooler_pred_ets
plot(cooler_pred_ets, main = "Cooler Condition Forecast = ETS Method",
     xlab = "Interval", ylab = "Cooler Condition")

###### Pump Leakage ETS function/forecast
#use ets function to auto choose a model by default
leakage_fit_ets<-ets(ts$Leakage)
leakage_fit_ets #view results
#check residuals
checkresiduals(leakage_fit_ets)

#accuracy function is used to see the predictive accuracy - lower the better
accuracy(leakage_fit_ets)

#forecast for the next 500 cycles
leakage_pred_ets<-forecast(leakage_fit_ets, h=500)
plot(leakage_pred_ets, 
     main = "Internal Pump Leakage Forecast = ETS Method",
     xlab = "Interval", ylab = "Internal Pump Leakage Condition")

###### Valve ETS function/forecast
#use ets function to auto choose a model by default
valve_fit_ets<-ets(ts$Valve)
valve_fit_ets #view results
#check residuals
checkresiduals(valve_fit_ets)

#accuracy function is used to see the predictive accuracy - lower the better
accuracy(valve_fit_ets)

#forecast for the next 500 cycles
valve_pred_ets<-forecast(valve_fit_ets, h=500)
plot(valve_pred_ets,
     main = "Valve Condition Forecast = ETS Method",
     xlab = "Interval", ylab = "Valve Condition")

###### Hydraulic Accumulator/Bar ETS function/forecast
#use ets function to auto choose a model by default
bar_fit_ets<-ets(ts$Bar)
bar_fit_ets #view results
#check residuals
checkresiduals(bar_fit_ets)

#accuracy function is used to see the predictive accuracy - lower the better
accuracy(bar_fit_ets)

#forecast for the next 500 cycles
bar_pred_ets<-forecast(bar_fit_ets, h=500)
plot(bar_pred_ets,
     main = "Hyraulic Accumulator/Bar Condition Forecast = ETS Method",
     xlab = "Interval", ylab = "Hydraulic Accumulator/Bar Condition")




##################### Auto Arima Model and Forecast ########################
############################################################################

####### Cooler Condition
#create model with auto.arima function
cooler_arima<-auto.arima(ts$Cooler)
#view results
cooler_arima 
#check residuals
checkresiduals(cooler_arima)
#View accuracy
accuracy(cooler_arima)
#create forecast
cooler_arima_forecast<-forecast(cooler_arima, h=500)
#view forecast results
cooler_arima_forecast
#plot results
plot(cooler_arima_forecast,
     main = "Cooler Condition Forecast - ARIMA 0,1,0")


####### Valve Condition
#create model with auto.arima function
valve_arima<-auto.arima(ts$Valve)
#view results
valve_arima 
#check residuals
checkresiduals(valve_arima)
#check accuracy
accuracy(valve_arima)
#create forecast
valve_arima_forecast<-forecast(valve_arima, h=500)
#view forecast results
valve_arima_forecast
#plot results
plot(valve_arima_forecast,
     main = "Valve Condition Forecast - ARIMA 0,1,0")


####### Internal Pump Leakage
#create model with auto.arima function
leakage_arima<-auto.arima(ts$Leakage)
#view results
leakage_arima
#check residuals
checkresiduals(leakage_arima)
#view accuracy
accuracy(leakage_arima)
#create forecast
leakage_arima_forecast<-forecast(leakage_arima, h=500)
#view forecast results
leakage_arima_forecast
#plot results
plot(leakage_arima_forecast, 
     main = "Internal Pump Leakage Forecast - ARIMA 1,0,0 with Non-Zero Mean")


####### Hydraulic Accumulator / Bar
#create model with auto.arima function
bar_arima<-auto.arima(ts$Bar)
#view results
bar_arima 
#check residuals
checkresiduals(bar_arima)
#View accuracy
accuracy(bar_arima)
#create forecast
bar_arima_forecast<-forecast(bar_arima, h=500)
#view forecast results
bar_arima_forecast
#plot results
plot(bar_arima_forecast,
     main = "Hydraulic Accumulator / Bar Forecast - ARIMA 0,1,0")



