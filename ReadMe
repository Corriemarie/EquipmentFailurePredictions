# Equipment Failure Predictions
The purpose of this project is to use the data retrieved from UCI Machine Learning Repository, which consist of readings from sensors used for condition monitoring of a hydraulic system, to predict when the equipment will fail. 


## Data Collection
The dataset used in the project was retrieved from UCI Machine Learning Repository (https://archive.ics.uci.edu/ml/datasets/Condition+monitoring+of+hydraulic+systems# ) and consists of readings from sensors used for condition monitoring of a hydraulic system including pressure, volume flow and temperatures along with the condition of the hydraulic components (cooler, valve, pump, and accumulator).

## The Data
The following information regarding the dataset provides was supplied from UCI Machine Learning Repository for the Condition monitoring of hydraulic systems data set.

The data set was experimentally obtained with a hydraulic test rig. This test rig consists of a primary working and a secondary cooling-filtration circuit which are connected via the oil tank [1], [2]. The system cyclically repeats constant load cycles (duration 60 seconds) and measures process values such as pressures, volume flows and temperatures while the condition of four hydraulic components (cooler, valve, pump and accumulator) is quantitatively varied.


Attribute Information:

The data set was experimentally obtained with a hydraulic test rig. This test rig consists of a primary working and a secondary cooling-filtration circuit which are connected via the oil tank [1], [2]. The system cyclically repeats constant load cycles (duration 60 seconds) and measures process values such as pressures, volume flows and temperatures while the condition of four hydraulic components (cooler, valve, pump and accumulator) is quantitatively varied. 

Attribute Information: 
The data set contains raw process sensor data (i.e. without feature extraction) which are structured as matrices (tab-delimited) with the rows representing the cycles and the columns the data points within a cycle. The sensors involved are: 
Sensor	Physical quantity	Unit	Sampling rate 
PS1	Pressure	bar	100 Hz 
PS2	Pressure	bar	100 Hz 
PS3	Pressure	bar	100 Hz 
PS4	Pressure	bar	100 Hz 
PS5	Pressure	bar	100 Hz 
PS6	Pressure	bar	100 Hz 
EPS1	Motor power	W	100 Hz 
FS1	Volume flow	l/min	10 Hz 
FS2	Volume flow	l/min	10 Hz 
TS1	Temperature	Â°C	1 Hz 
TS2	Temperature	Â°C	1 Hz 
TS3	Temperature	Â°C	1 Hz 
TS4	Temperature	Â°C	1 Hz 
VS1	Vibration	mm/s	1 Hz 
CE	Cooling efficiency (virtual)	%	1 Hz 
CP	Cooling power (virtual)	kW	1 Hz 
SE	Efficiency factor	%	1 Hz 

The target condition values are cycle-wise annotated in â€˜profile.txtâ€˜ (tab-delimited). As before, the row number represents the cycle number. The columns are 

1: Cooler condition / %: 
3: close to total failure 
20: reduced effifiency 
100: full efficiency 

2: Valve condition / %: 
100: optimal switching behavior 
90: small lag 
80: severe lag 
73: close to total failure 

3: Internal pump leakage: 
0: no leakage 
1: weak leakage 
2: severe leakage 

4: Hydraulic accumulator / bar: 
130: optimal pressure 
115: slightly reduced pressure 
100: severely reduced pressure 
90: close to total failure 

5: stable flag: 
0: conditions were stable 
1: static conditions might not have been reached yet

Reference:
(Nikolai Helwig, Eliseo Pignanelli, Andreas SchÃ¼tze, â€˜Condition Monitoring of a Complex Hydraulic System Using Multivariate Statisticsâ€™, in Proc. I2MTC-2015 - 2015 IEEE International Instrumentation and Measurement Technology Conference, paper PPS1-39, Pisa, Italy, May 11-14, 2015, doi: 10.1109/I2MTC.2015.7151267.)

## Data Preparation
There was minimal data preparation necessary for this data set since there were no missing values and all values were numeric. Each individual dataset was uploaded and a mean value for each variable was created and combined into one dataframe. Throughout the analysis, time readings were added to the data frame, the melt function was used for initial visualizations and the data frame was converted to tibble format to be able to perform anomaly detection.

## EDA (Exploratory Data Analysis)
The summary function was used to provide an overall view of the dataset. This provides the minimum, 1st quartile, meadian, mean, 3rd quartile and maximum values for each of the sensor variables. This was done prior to normalizing the data and with the values having a wide range between the different sensors, it shows the need to normalize the data before progressing on with the project. 

Histograms were created for the variables based on frequency and can be used to see how data is distributed. 

Scatter and line plots were created to see the readings during the time that the data was collected. 
After normalizing the data and using the melt function to create a new data frame, a line plot and boxplot with all of the sensor readings were created. We can see in the line plot that there’s a lot of activity at the beginning of the time series. This also coincides with the cooler condition reported at near total failure. The boxplot also shows the condition ratings and we can quickly see which variables have outliers, such as the EPS1, FS1, PS1, PS2, PS3, PS4, SE, and VS1 variables.

By creating a correlationheat matrix, we can determine the correlation between variables. The closer the correlation coefficient is to 1, the stronger the relationship is. Those in red show the highest correlation with a value of 1, so we can quickly see that the cooler condition is highly correlated with the PS6, CP and CE variables and to a slightly lesser extent, the PS6, PS4, and PS3 variables. 

Using the tsdisplay function, we can visualize the auto-correlation function (ACF) with lag values and partial auto-correlation (PACF) with lag. ACF takes trend, seasonality, cyclic, and residuals into consideration where PACF finds correlation of the residuals. This was done for the condition variables used to determine the state of the equipment.



## Anomaly Detection
In order to see anomalies within the data for the sensor variables, the data frame had been converted to tibble time series format and the anomalize package was applied. I prefer to use the anomozlize package for anomaly detection because it’s easy to apply with visuals showing the anomalies in red. 
The anomalize package was used to determine anomolies within the data and consists of three main functions:
  - The time_decompose function seperates the data into seasonal, trent and remainder     components. 
  - The anomalize function applies anomaly detection methods to the remainder component and produces three new columns: "remainder_l1" (lower limit), "remainder_l2" (upper limit), and "anomaly" (Yes/No flag). 
  - The time_recompose function is used to calculate limits that seperate the "normal" data from anomalies. 
  
Using the decompose function, we are able to see the breakout for observed, season, trend and remainder with each anomaly highlighted. Using the recompose, we are able to see the upper and upper bounds. The STL method, which uses seasonal decomposition with a Loess Smoother and the IQR method, which is a fast and relatively accurate method for detecting anomalies, was applied to variables within the data set. The default parameters of 0.05 alpha and 0.2 max anomalies were also used. 

Since the decompose function breaks out the observed, season, trend and remainder, it was easiest to apply this to each variable individually. I also chose to do the same for the lower and upper bounds. Here are some examples of the visuals as a result of applying the anomalize functions for anomaly detection. 

We can see that there’s a common timeframe that most of the anomalies occur, which is early on in the timeframe when it was reported that the equipment was close to total failure for cooler condition but also follows the change in state for the other condition variables. 

## Failure Prediction
To predict failure on the equipment, machine learning techniques were applied. After creating training and test data sets with a 75/25 ratio, I first started by applying the support vector method to the condition variables for the hydraulic system.
For each variable I changed the target to a factor, trained the SVM model, checked the result of the model, created predictions using the predict function based on the model, used the ConfusionMatrix function to determine accuracy and plotted the predictions.
When the SVM model was applied to the Valve variable, the confusionMatrix shows that the accuracy of this model was 80%. For the Cooler variable, the accuracy was 100%; for the internal pump leakage variable, the accuracy was 99.6%; and for the hyraulic accumulator/bar variable, the accuracy was 95.3%. 

## Forecasting
ETS and ARIMA methods were applied for forecasting the condition variables of the hydraulic equipment. ETS is a simple exponential smoothing model that uses a weighted average of past observations. ARIMA is an auto-regressive integrated moving average model. Both models use a three-character or digit code on the model for the error type, trend type and season type. 
For both methods, the model was created, model results were viewed, residuals were checked, the forecast function was applied and the results of the forecast viewed and plotted. Both methods had similar results for forecasting the condition variables, however the ARIMA model had better accuracy ratings. 


## Summary
In summary, this was a large data set that contained a lot of information that can be used to provide insight on the equipment and its status. Using anomaly detection, we can see points in which sensor readings are outside the normal bounds providing early detection that something is wrong with the equipment. 
Applying the SVM model to the equipment condition variables, we received a high accuracy rating indicating that this model could be used to predict failures with the equipment,
Using the ARIMA or ETS method, we could forecast future readings on the equipment. 
Using this information, a company could begin transforming maintenance on their equipment from a break/fix or preventive maintenance model to a predictive maintenance model leading to more accurate planning and budgeting as well as cost savings. 

## References
