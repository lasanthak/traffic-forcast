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

#title: "Data Analysis for Vrbo Traffic Prediction Model"
#author: "Lasantha Kularatne"
#date: "02/10/2021"

library(dplyr)
library(ggplot2)

# Load data
# Columns: year,month,week,value
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
cat('Working directory:', getwd())
data = read.csv("./sample-data.csv")

# Assign continuous week number to w
data$w = c(1:nrow(data))

# Remove data with null value (those are only used for predictions)
past_data = data %>% filter(!is.na(value))

# Basic plot
plot(past_data$value~past_data$w, type='b', cex=0.3, col='Red')

# Histogram
hist(past_data$value)

# Split data yearly
data2019 = past_data %>% filter(year==2019)
data2020 = past_data %>% filter(year==2020)

# Monthly variation
#ggplot(data2019, group=month, aes(x=month, y=value)) + geom_boxplot(aes(color = factor(month)))

ggplot(data2019, group=month, aes(x=month, y=value)) +
  ggtitle('2019') +
  geom_boxplot(aes(color = factor(month))) +
  ylim(15000, 65000) +
  scale_x_continuous(breaks=seq(1, 12, 1))

ggplot(data2020, group=month, aes(x=month, y=value)) +
  ggtitle('2020') +
  geom_boxplot(aes(color = factor(month))) +
  ylim(15000, 65000) +
  scale_x_continuous(breaks=seq(1, 12, 1))

