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
library(ggstatsplot)

# set working directory to data file directory:
setwd("C:/Users/sijam/Documents/GitHub/Eye-Tracking-Neural-Sys/Data Files")

# load data files:
dataOriginal<-read.csv("dataset_0423.csv", header = TRUE)
data<-read.csv("results_data_subjects_V2.csv", header = TRUE)

data$velocity_low <- sapply(data$velocity_low, as.numeric)
data$velocity_high <- sapply(data$velocity_high, as.numeric)
data$delta_velocity <- sapply(data$delta_velocity, as.numeric)

#subsetOriginal <- dataOriginal[c(8065:10080),]

###########
# PLOTS
###########
#hypothesis 1: radius in the heatmap during stimulation phase
#subj_id vs delta radius
bar <- ggplot(data, aes(subject_id, delta_radius_stimulation))
bar + stat_summary(fun = mean, geom = "bar", fill = "White", colour = "Black") + stat_summary(fun.data = mean_cl_normal, geom = "pointrange") + labs(x = "subject_id", y = "delta_radius_stimulation")

line <- ggplot(data, aes(subject_id, delta_radius_stimulation))
line + stat_summary(fun = mean, geom = "line") + stat_summary(fun.data = mean_cl_boot, geom = "errorbar", width = 0.2) + labs(x = "subject_id", y = "delta_radius_stimulation", colour = "Type of Imagery") 

scatter <- ggplot(data, aes(subject_id, delta_radius_stimulation))
scatter + stat_summary(fun = mean, geom = "point") + labs(x = "subject_id", y = "delta_radius_stimulation")
scatter + geom_point() + geom_smooth() + labs(x = "subject_id", y = "delta radius")

#high noise radius vs low noise radius
#fancy line plots
line2 <- ggplot(data, aes(radius_high_stimulation, radius_low_stimulation))
line2 +   theme_grey(base_size = 16) + # get nice theme going
  stat_summary(fun = mean, geom = "line", size = 1, aes(group=1), colour = "#FF0000") + # Add red lines to connect the group means
  stat_summary(fun.data = mean_cl_boot, geom = "errorbar", width = 0.2, size = 0.5, colour = "#FF0000") + # Add bootstrapped CI error bars
  stat_summary(fun = mean, geom = "point", size = 4, colour = "#FF0000") + # Add large red dots to show mean radius for low noise for each radius for high noise level
  stat_summary(fun = mean, geom = "point", size = 2, colour = "#FFFFFF") + # Add smaller white dots to fill the larger red dots
  scale_x_discrete(labels=c("Placebo", "Low", "High")) + # add x tick labels
  labs(x = "radius_high_stimulation", y = "radius_low_stimulation") + # add axis labels
  ggtitle("low noise (means with bootstrapped 95% CIs) at different high doses") + # add a plot title
  theme(plot.title = element_text(hjust = 0.5, face = "italic")) # center and italicize plot title

scatter2 <- ggplot(data, aes(radius_high_stimulation, radius_low_stimulation))
scatter2 + stat_summary(fun = mean, geom = "point") + labs(x = "subject_id", y = "delta_radius_stimulation")
scatter2 + geom_point() + geom_smooth() + labs(x = "subject_id", y = "delta radius")
#there seems to be a linear correlation between low noise and high noise stimulation phase :P

#finally an useful plot, distinguishing between low_noise and high_noise
#create new df with all radii in one column and their levels on the other column
noise <- gl(2, 35, labels = c("high", "low"))
radius <- c(data$radius_high_stimulation, data$radius_low_stimulation)
dataRadius <-data.frame(noise, radius)
names(dataRadius) <- c("noise","radius")

boxplot <- ggplot(dataRadius, aes(noise, radius))
boxplot + geom_boxplot() + labs(x = "noise", y ="radius")

#hypothesis 2: velocity vs noise
noise <- gl(2, 35, labels = c("high", "low"))
velocity <- c(data$velocity_high, data$velocity_low)
dataVelocity <-data.frame(noise, velocity)

boxplot <- ggplot(dataVelocity, aes(noise, velocity))
boxplot + geom_boxplot() + labs(x = "noise", y ="velocity") #outliers!!!!

#tag outliers
boxplot(dataVelocity)$out
ggbetweenstats(dataVelocity, noise, velocity, outlier.tagging = TRUE)

#remove outliers
qLow <- quantile(data$velocity_low, probs=c(.25, .75), na.rm = TRUE)
qHigh <- quantile(data$velocity_high, probs=c(.25, .75), na.rm = TRUE)
iqrLow <- IQR(data$velocity_low, na.rm = TRUE)
iqrHigh <- IQR(data$velocity_high, na.rm = TRUE)
upLow <-  qLow[2]+1.5*iqrLow # Upper Range  
lowLow<- qLow[1]-1.5*iqrLow # Lower Range
upHigh <-  qHigh[2]+1.5*iqrHigh # Upper Range  
lowHigh<- qHigh[1]-1.5*iqrHigh # Lower Range
velocity_low_withoutOut <- subset(data, data$velocity_low > (qLow[1] - 1.5*iqrLow) & data$velocity_low < (qLow[2]+1.5*iqrLow))
#velocity_low_withoutOut <- subset(data, data$velocity_low > (qLow[1] - 1.5*iqrLow) & data$velocity_low < 0.003406)
velocity_high_withoutOut <- subset(data, data$velocity_high > (qHigh[1] - 1.5*iqrHigh) & data$velocity_high < (qHigh[2]+1.5*iqrHigh))
#velocity_high_withoutOut <- subset(data, data$velocity_high > (qHigh[1] - 1.5*iqrHigh) & data$velocity_high < 0.004438)
data_withoutOut <- subset(velocity_low_withoutOut, velocity_low_withoutOut$velocity_high > (qHigh[1] - 1.5*iqrHigh) & velocity_low_withoutOut$velocity_high < (qHigh[2]+1.5*iqrHigh))

#new data & new boxplot
noise <- c("high","high","high","high","high","high","high","high","high","high",
          "high","high","high","high","high","high","high","high","high","high",
          "high","high","high","high","high","high", "high","high",
          "low","low","low","low","low","low","low","low","low","low","low",
          "low","low","low","low","low","low","low","low","low","low",
          "low","low","low")
noise <-factor(noise, levels = c("high", "low"))
velocity <- c(velocity_high_withoutOut$velocity_high, velocity_low_withoutOut$velocity_low)
dataVelocity <-data.frame(noise, velocity)

boxplot <- ggplot(dataVelocity, aes(noise, velocity))
boxplot + geom_boxplot(outlier.shape=NA) + labs(x = "noise", y ="velocity")+
  scale_y_continuous(limits = c(0,0.0025))


boxplot(dataVelocity, outline=F)$out
ggbetweenstats(dataVelocity, noise, velocity, outlier.tagging = TRUE, outline=F)

##############################
# REPEATED MEASURES ERROR BARS 
##############################
# Load user-defined function file 'rmMeanAdjust.R' into R's global environment:
source("C:/Users/sijam/Documents/GitHub/Eye-Tracking-Neural-Sys/Rscripts/rmMeanAdjust.R")

#plot our bar graphs with RM error bars:
spiderBar <- ggplot(dataRadius, aes(noise, radius)) # create plot of anxiety in the two levels of our factor
spiderBar + 
  theme_grey(base_size = 14) + # get nice theme going
  stat_summary(fun = mean, geom = "bar", fill = "White", colour = "Black") + # add the bars
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.2) + # add the error bars
  labs(x = "Type of Noise", y = "Radius") + # label the axes
  ggtitle("Data with correct error bars") + # add a plot title
  theme(plot.title = element_text(hjust = 0.5, face = "italic")) + # center and italicize plot title
  scale_x_discrete(labels=c("high noise", "low noise")) + # add bar labels
  scale_y_continuous(limits = c(0, 20), breaks = seq(from = 0, to = 20, by = 10)) # adapt y-scale 

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
stat.desc(data$delta_velocity, basic = FALSE, norm = TRUE) # Using the 'delta' column 
#hypothesis 3:


# Perform paired-samples t-test to see whether high noise perception or low noise perception leads to differences in the test variables:
#hypothesis 1: radius in the heatmap during stimulation phase
dep.t.test <- t.test(data$radius_high_stimulation,data$radius_low_stimulation, paired = TRUE)
dep.t.test
#hypothesis 2:
dep.t.test <- t.test(data$velocity_low,data$velocity_high, paired = TRUE)
dep.t.test
#without outliers:
dep.t.test <- t.test(data_withoutOut$velocity_low, data_withoutOut$velocity_high, paired = TRUE)
dep.t.test
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
