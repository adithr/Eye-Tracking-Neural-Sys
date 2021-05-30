# Clear plots
if(!is.null(dev.list())) dev.off()
# Clean workspace
rm(list=ls())
# Clear console
cat("\014")

library(ggplot2)
library(ez)
library(multcomp)
library(nlme)
library(pastecs)
library(reshape)
library(WRS2)
library(plyr)

# set working directory to data file directory:
setwd("C:/Users/sijam/Documents/GitHub/Eye-Tracking-Neural-Sys/Data Files")

# load data files:
dataOriginal<-read.csv("dataset_0423.csv", header = TRUE)
data<-read.csv("results_data_subjects_V2.csv", header = TRUE)

subsetOriginal <- dataOriginal[c(8065:10080),]

###########
# PLOTS
###########
bar <- ggplot(data, aes(subject_id, delta_radius_stimulation))
bar + stat_summary(fun = mean, geom = "bar", fill = "White", colour = "Black") + stat_summary(fun.data = mean_cl_normal, geom = "pointrange") + labs(x = "subject_id", y = "delta_radius_stimulation")

line <- ggplot(data, aes(subject_id, delta_radius_stimulation))
line + stat_summary(fun = mean, geom = "line") + stat_summary(fun.data = mean_cl_boot, geom = "errorbar", width = 0.2) + labs(x = "subject_id", y = "delta_radius_stimulation", colour = "Type of Imagery") 

scatter <- ggplot(data, aes(subject_id, delta_radius_stimulation))
scatter + stat_summary(fun = mean, geom = "point") + labs(x = "subject_id", y = "delta_radius_stimulation")
scatter + geom_point() + geom_smooth() + labs(x = "subject_id", y = "delta radius")

#x = tapply(newData2$radii, newData2$subject_id + newData2$game_nr, mean) #merging data?not sure why I did this xD
#x

##############################
# REPEATED MEASURES ERROR BARS 
##############################
# Load user-defined function file 'rmMeanAdjust.R' into R's global environment:
source("C:/Users/sijam/Documents/GitHub/Eye-Tracking-Neural-Sys/Rscripts/rmMeanAdjust.R")

data$Factor = factor("Delta") # Factor with only one level: Delta

bar2 <- ggplot(subset(data,(Factor == "Delta")), aes(Factor, delta_radius_stimulation))
bar2 + 
  theme_grey(base_size = 14) + # get nice theme going
  stat_summary(fun = mean, geom = "bar", fill = "White", colour = "Black", width = 0.5) + # add the bar
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.2) + # add the error bars
  labs(x = "High noise - Low noise games", y = expression(Delta*" radius_stimulation")) + # label the axes (with greek capital Delta)
  ggtitle("bar plot with correct error bars") + # add a plot title, maybe don't add "with correct error bars" part
  theme(plot.title = element_text(hjust = 0.5, face = "italic")) + # center and italicize plot title
  scale_x_discrete(labels = "")  # remove bar label, does not really have a meaning when you have only 1 boxplot

##################
# DEPENDANT T-TEST
##################

# Clean workspace
rm(list=ls())
# Clear console
cat("\014")

# load data file:
dataOriginal<-read.csv("dataset_0423.csv", header = TRUE)
data<-read.csv("results_data_subjects_V2.csv", header = TRUE)

# Descriptives to test assumptions:
#hypothesis 1:radius in the heatmap during stimulation phase
stat.desc(data$delta_radius_stimulation, basic = FALSE, norm = TRUE) # Using the 'delta' column 
#hypothesis 2:

#hypothesis 3:


# Perform paired-samples t-test to see whether high noise perception or low noise perception leads to differences in the test variables:
#hypothesis 1: radius in the heatmap during stimulation phase
dep.t.test <- t.test(data$radius_high_stimulation,data$radius_low_stimulation, paired = TRUE)
dep.t.test
#hypothesis 2:

#hypothesis 3:



# The dependent t-test is the simplest linear model:
# It's a model with ONLY an intercept!
# That is, it simply tests whether the INTERCEPT (i.e. the mean difference) is different from zero.
#hypothesis 1: radius in the heatmap during stimulation phase
dep.t.test.lm <- lm(data$delta_radius_stimulation ~ 1)
summary(dep.t.test.lm)
confint(dep.t.test.lm)
#hypothesis 2:

#hypothesis 3:


# Pearson r is a good measure of effect size for dependent t-test:
#hypothesis 1: radius in the heatmap during stimulation phase
#not really useful in data with non-significant results, I guess.
t <- dep.t.test$statistic[[1]]
df <- dep.t.test$parameter[[1]]
r <- sqrt(t^2/(t^2+df))
round(r, 3)
#hypothesis 2:

#hypothesis 3:


# A robust method for performing dependent t-test:
#hypothesis 1: radius in the heatmap during stimulation phase
dep.t.test.yuen <- yuend(data$radius_high_stimulation, data$radius_low_stimulation)
dep.t.test.yuen
#hypothesis 2:

#hypothesis 3:
