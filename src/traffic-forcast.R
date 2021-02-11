# Copyright [2021] [Lasantha Kularatne]
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#title: "Vrbo Traffic Prediction Model"
#author: "Lasantha Kularatne"
#date: "02/10/2021"

library(dplyr)
mainTitle = 'Traffic Forecast'

# ------ Functions ------
# Calculate Mean Absolute Error
calcMAE = function(actual, predicted) {
  return(mean(abs(actual - predicted)))
}

# ------ Load data ------
# Columns: year,month,week,value
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
cat('Working directory:', getwd())
data = read.csv("./sample-data.csv")

# ------ Format source data ------
# Assign continuous week number to w
data$w = c(1:nrow(data))

# Calculating the continuous variable t with a cycle of 52 weeks (1 year).
# Here, a 52-week cycle represents a full circle for sin/cos functions.
# (ie: an angle of 2pi)
data$t = (2 * pi * data$w) / 52

# ------ Setup training data ------
# Remove data with null value (those are only used for predictions)
past_data = data %>% filter(!is.na(value))

# Remove data for Covid shutdown period (Mar, Apr, May, and Jun in 2020)
filtered_data = past_data %>% filter(year!=2020 | month<3 | month>5)

# Split data 80:20 for training and testing
set.seed(186)
train_ids = sort(sample(nrow(filtered_data), ceiling(0.8*nrow(filtered_data))))
train = filtered_data[train_ids,]
test = filtered_data[-train_ids,]

# ------ Calculate trend line ------
train.trend_spl = smooth.spline(train$value~train$t, spar=1.0)
data$trend = predict(train.trend_spl, data$t)$y
train$trend = predict(train.trend_spl, train$t)$y
test$trend = predict(train.trend_spl, test$t)$y

# ------ Train linear regression model ------
lm.fit = lm(value~trend+t+
              I(cos(t))+I(sin(t))+
              I(cos(2*t))+I(sin(2*t))+
              I(cos(3*t))+I(sin(3*t))+
              I(cos(4*t))+I(sin(4*t))+
              I(cos(5*t))+I(sin(5*t))+
              I(cos(6*t))+I(sin(6*t))+
              I(cos(7*t))+I(sin(7*t)),
            data=train)
#anova(lm.fit)
#plot(lm.fit)
summary(lm.fit)

# ------ Predict ------
data$predicted = predict(lm.fit, data)
test$predicted = predict(lm.fit, test)
cat('Total Error:', calcMAE(test$value,test$predicted))

# ------ Plot data ------
plot(data$value~data$w, ylim=c(15000,70000), col='deeppink', type='p', cex=0.1,
     main=mainTitle, ylab='Traffic', xlab='Week', family="Courier")
# Exclusion range (Covid)
rect(82.5, 0, 96.5, 80000, border=NA, col='gray94')
#Trend line
points(data$trend~data$w, col='gray60', type='l', lwd=2)
# Actual
points(data$value~data$w, col='deeppink', type='l', lwd=1)
points(data$value~data$w, col='deeppink', cex=0.7, type='p', pch=16)
# Fitted
points(data$predicted~data$w, col='dodgerblue', type='l', lwd=2)
points(data$predicted~data$w, col='dodgerblue', cex=0.7, type='p', pch=16)
# Predicted
pdata = data %>% filter(is.na(value))
points(pdata$predicted~pdata$w, col='darkorchid2', type='l', lwd=2)
points(pdata$predicted~pdata$w, col='darkorchid2', cex=0.7, type='p', pch=16)

text(-3, 71000, col='deeppink', '- Training Data', adj=0, family="Courier")
text(-3, 69250, col='dodgerblue', '- Fitted Curve', adj=0, family="Courier")
text(-3, 67500, col='darkorchid2', '- Predictions', adj=0, family="Courier")
text(-3, 65750, col='gray50', '- Trend Line', adj=0, family="Courier")

abline(lty=3, col='gray', h=65000)
abline(lty=3, col='gray', h=60000)
abline(lty=3, col='gray', h=55000)
abline(lty=3, col='gray', h=50000)
abline(lty=3, col='gray', h=45000)
abline(lty=3, col='gray', h=40000)
abline(lty=3, col='gray', h=35000)
abline(lty=3, col='gray', h=30000)
abline(lty=3, col='gray', h=25000)
abline(lty=3, col='gray', h=20000)
abline(lty=3, col='gray', h=15000)
abline(lty=3, col='gray', h=10000)

abline(lty=3, col='gray', v=10)
abline(lty=3, col='gray50', v=23) #2019
abline(lty=3, col='gray', v=36)
abline(lty=3, col='gray', v=49)
abline(lty=3, col='gray', v=62)
abline(lty=3, col='gray50', v=75) #2020
abline(lty=3, col='gray', v=88)
abline(lty=3, col='gray', v=101)
abline(lty=3, col='gray', v=114)
abline(lty=3, col='gray50', v=127) #2021
abline(lty=3, col='gray', v=140)
abline(lty=3, col='gray', v=153)

text(10, 13500, cex=0.8, col='gray30', 'Oct', adj=0, family="Courier")
text(23, 14500, cex=0.8, col='gray30', '2019', adj=0, family="Courier")
text(23, 13500, cex=0.8, col='gray30', 'Jan', adj=0, family="Courier")
text(36, 13500, cex=0.8, col='gray30', 'Apr', adj=0, family="Courier")
text(49, 13500, cex=0.8, col='gray30', 'Jul', adj=0, family="Courier")
text(62, 13500, cex=0.8, col='gray30', 'Oct', adj=0, family="Courier")
text(75, 14500, cex=0.8, col='gray30', '2020', adj=0, family="Courier")
text(75, 13500, cex=0.8, col='gray30', 'Jan', adj=0, family="Courier")
text(88, 13500, cex=0.8, col='gray30', 'Apr', adj=0, family="Courier")
text(101, 13500, cex=0.8, col='gray30', 'Jul', adj=0, family="Courier")
text(114, 13500, cex=0.8, col='gray30', 'Oct', adj=0, family="Courier")
text(127, 14500, cex=0.8, col='gray30', '2021', adj=0, family="Courier")
text(127, 13500, cex=0.8, col='gray30', 'Jan', adj=0, family="Courier")
text(140, 13500, cex=0.8, col='gray30', 'Apr', adj=0, family="Courier")
text(153, 13500, cex=0.8, col='gray30', 'Jul', adj=0, family="Courier")

cat('Total Error:', calcMAE(test$value,test$predicted))
