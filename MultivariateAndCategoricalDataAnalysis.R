#' ---
#' title: "Multivariate And Categorical Data Analysis"
#' author: "Ritesh Kumar (218211529)"
#' date: "8/8/2018"
#' output:
#'   word_document: default
#'   pdf_document: default
#'   html_document: default
#' ---
#' 
## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

#' 
## ----claenup workspace, message=FALSE, warning=FALSE, include=FALSE------
rm(list=ls())
gc()

#' 
## ----load Library, message=FALSE, warning=FALSE, include=FALSE-----------
library(dplyr)
library(ggplot2)
library(MASS)
library(vegan)
library(kernlab)

#' 
#' # Assignment - 1
#' Bike sharing dataset (BikeShare)
#' This dataset gives the count of bikes rented between 11am - 12pm on different days and locations through the Capital Bikeshare System (operating in US cities) between 2011 and 2012. The variables include the following (9 variables):
#' 
#' Season: Categorical: 1 = Spring, 2 = Summer, 3 = Autumn (fall), 4 = Winter
#' 
#' Working day: 0 = Weekend, 1 = Workday.
#' 
#' Weather: Categorical variable
#' 
#'   1: Clear, Few clouds, Partly cloudy, Partly cloudy
#'   
#'   2: Mist + Cloudy, Mist + Broken clouds, Mist + Few clouds, Mist
#'   
#'   3: Light Snow, Light Rain + Thunderstorm + Scattered clouds, Light Rain + Scattered cloud 
#'   
#'   4: Heavy Rain + Ice Pallets + Thunderstorm Mist, Snow + Fog
#'   
#' Temperature: Temperature in Celsius.
#' 
#' `Feeling' Temperature: `Feels like' temperature, reported in Celsius.
#' 
#' Humidity: Humidity (given as a percentage).
#' 
#' Windspeed: Windspeed (measured in km/h).
#' 
#' Casual users: Count of casual users that used a bike at that time.
#' 
#' Registered users: Count of registered users that used a bike at that time.
#' 
#' ### Question-1
#' Download the txt file “BikeShareTabSep.txt” and save it to your R working directory.
#' 
#' • Assign the data to a matrix, e.g. using the.data<-as.matrix(read.table("BikeShareTabSep.txt"))
#' 
#' • Generate a sample of 400 data using the following: my.data <- the.data [sample(1:727,400),c(1:9)]
#' 
#' Save “my.data” to a text file titled “name-StudentID-BikeShareMyData.txt" using the following R code (NOTE: you must upload this text file with your submission).
#' 
#' write.table(my.data,"name-StudentID-BikeShareMyData.txt")
#' Use the sampled data (“my.data”) to answer the following questions.
#' 
## ----Q1------------------------------------------------------------------
the.data<-as.matrix(read.table("data/BikeShareTabSep.txt"))
#nrow(the.data)
my.data <- the.data [sample(1:727,400),c(1:9)]
write.table(my.data,"data/ritesh-218211529-BikeShareMyData.txt")


#' 
#' #### 1.1) Draw histograms for ‘Registered users’ and ‘Temperature’ values, and comment on them. [3 Marks]
#' 
## ----Q1.1----------------------------------------------------------------
# Column Names
col.names <- 
  c("Season", "WorkingDay", "Weather", "Temperature", "FeelingTemperature", 
    "Humidity", "Windspeed", "CasualUsers", "RegisteredUsers")
# Set the column names
colnames(my.data) <- col.names
my.data.df <- as.data.frame(my.data)

# Convert columns to categorical type
my.data.df$Season <-as.factor(my.data.df$Season)
my.data.df$WorkingDay <-as.factor(my.data.df$WorkingDay)
my.data.df$Weather <-as.factor(my.data.df$Weather)

# Data Summary
summary(my.data.df)
#View(my.data.df)

#' 
## ----Registered User Histogram-------------------------------------------
# Registered User Histogram
ggplot(
  data = my.data.df,
  aes(my.data.df$RegisteredUsers)) +
    geom_histogram(
      breaks = seq(0, 500, by = 20),
      col = "red",
      fill = "green",
      alpha = .2) +
    labs(title = "Histogram for Registered Users") +
    labs(x = "Registered Users", y="Count") + 
    xlim(c(0,500)) + 
    ylim(c(0,60))

#' 
## ----Temperature Histogram-----------------------------------------------
# Temperature Histogram
ggplot(
  data = my.data.df,
  aes(my.data.df$Temperature)) +
    geom_histogram(
      breaks = seq(0, 50, by = 2),
      col = "red",
      fill = "green",
      alpha = .2) +
    labs(title = "Histogram for Temperatures") +
    labs(x = "Temperature", y="Count") + 
    xlim(c(0,50)) + 
    ylim(c(0,50))

#' 
#' ####  1.2) Give the five number summary and the mean value for the ‘Casual users’ and the ‘Registered users’ separately. [3 Marks]
#' 
## ----Q1.2----------------------------------------------------------------
message("Five Number Summary for 'Casual Users': ")
message(sprintf(
  "Minimum value  = %s\nLower Quartile = %s\nMedian = %s\nHiger Quartile = %s\nMaximum Value = %s\n", 
  min(my.data.df$CasualUsers), 
  quantile(my.data.df$CasualUsers, 0.25),
  median(my.data.df$CasualUsers),
  quantile(my.data.df$CasualUsers, 0.75),
  max(my.data.df$CasualUsers)))

message("Mean for 'Casual Users': = ", mean(my.data.df$CasualUsers))

message("\nFive Number Summary for 'Registered users': ")
message(sprintf(
  "Minimum value  = %s\nLower Quartile = %s\nMedian = %s\nHiger Quartile = %s\nMaximum Value = %s\n", 
  min(my.data.df$RegisteredUsers), 
  quantile(my.data.df$RegisteredUsers, 0.25),
  median(my.data.df$RegisteredUsers),
  quantile(my.data.df$RegisteredUsers, 0.75),
  max(my.data.df$RegisteredUsers)))

message("Mean for 'Registered users' = ", mean(my.data.df$RegisteredUsers))


#' 
#' ####  1.3) Draw a parallel Box plot using the two variables; ‘Casual users’ and the ‘Registered users’. Use the answers to Q1.2 and the Boxplots to compare and comment on them. [3 Marks]
#' 
## ----Q1.3----------------------------------------------------------------

boxplot(
  my.data.df[c("CasualUsers", "RegisteredUsers")], 
  main="Distribution of Users",
  xlab="Types of User", 
  ylab="User Count",
  col = c("red","sienna"),
  at = c(1,2), 
  #par(mar = c(12, 5, 4, 2) + 0.1),
  names = c("CasualUsers", "RegisteredUsers"))



#' 
#' ####  1.4) Draw a scatterplot of ‘Temperature’ and ‘Casual users’ for the first 200 data vectors selected from the “my.data” (name the axes) and comment on them [2 Marks]
#' 
## ----Q1.4----------------------------------------------------------------
ggplot(head(my.data.df,200), aes(x=Temperature, y=CasualUsers)) + 
  geom_point()
  
#scatter.smooth(x=head(my.data.df,200)$Temperature, y=head(my.data.df,200)$CasualUsers, main="CasualUsers ~ Temperature")

#' 
#' 
#' ### 1.5) Fit a linear regression model to the ‘temperature’ (as x) and the ‘casual users’ (as y) using the first 200 data vectors selected from the “my.data”. Write down the linear regression equation. Plot the line on the same scatter plot. Compute the correlation coefficient and the coefficient of Determination. Explain what these results reveal. [5 Marks]
#' 
## ----Q1.5----------------------------------------------------------------
cor(my.data.df$Temperature, my.data.df$CasualUsers) 

linearMod <- lm(CasualUsers ~ Temperature, data=my.data.df)
summary(linearMod)

{plot(CasualUsers ~ Temperature, data=head(my.data.df,200)) 
abline(lm(CasualUsers ~ Temperature, data=head(my.data.df,200)))}


#' 
#' ### Question-6 - Dimensionality Reduction: [19 Marks]
#' Use the “BikeShare” data for this question. Use the following code to load randomly selected 200 (or 100) data points. Note that only features from 4 to 9 are used here.
#' 
#'   the.data <- as.matrix(read.table("BikeShareTabSep.txt"))
#'   selData <- the.data [sample(1:727,200),c(4:9)]
#' 
#' Save “selData” to a text file titled “name-StudentID-PCASelData.txt" using the following R code (NOTE you must upload this text file with your submission).
#'   write.table(selData,"name-StudentID-PCASelData.txt")
#'   
## ----Q6------------------------------------------------------------------
data.pca <- read.table("data/BikeShareTabSep.txt")
colnames(data.pca) <- col.names
the.data.pca <- as.matrix(data.pca)
selData <- the.data.pca [sample(1:727,100),c(4:9)]

write.table(selData,"data/ritesh-218211529-PCASelData.txt")

#' 
#' ### 6.1) Conduct a principal component analysis (PCA) on this data (selData). Use the below mentioned “biplot” code (in R) to produce a scatterplot using the first two principal components. Comment on the plot. [4 Marks]
#' 
## ----Q6.1----------------------------------------------------------------

pZ <- prcomp(selData, tol = 0.01, scale = TRUE)
pZ
summary(pZ)
cor(selData)
biplot(pZ)


#' 
#' ### 6.2) Draw a graph of variance verses the principal components, and explain how this can be used to determine the correct number of principal components. [ 3 Marks]
#' 
## ----Q6.2----------------------------------------------------------------
#par(mfrow=c(3,1))
#x <- paste("PC", (seq(1,6,1)))
plot(prcomp(selData))
plot(pZ)
plot((pZ$sdev)^2, type = "b", xlab = "Principal Component", ylab = "Variance", axes = FALSE)
axis(1, at=1:6, labels=paste("PC", (seq(1,6,1))))
axis(2)
mtext(side=3, "Variance vs Principal Components")

#' 
#' ### 6.3) For the same data above (selData), compute the Euclidean distance matrix. Use the distance matrix to perform a classical multidimensional scaling (classical MDS or Metric MDS). You can use the following command.
#' 
#'   mds <- cmdscale(selData.dist) # here ‘selData.dist’ is the distance matrix
#'   
#'   Plot the results and comment on them [4 Marks]
#' 
## ----Q6.3----------------------------------------------------------------

selData.dist <- dist(selData)
mds <- cmdscale(selData.dist) 
plot(mds)


#' 
#' ### 6.4) For the same data above (selData), perform a non-metric MDS, called ‘isoMDS’ in R using number of dimensions k set to 2. Use the following command to do this:
#'   
#'   library(MASS)
#'   
#'   fit<-isoMDS(selData.dist, k=2)
#'   
#'   Plot the results of this isoMDS [2 Marks]
#' 
## ----Q6.4----------------------------------------------------------------
#library(MASS)
selData.x <- as.matrix(selData[,-1])
fit<-isoMDS(selData.dist, k=2)
plot(fit$points, type = "n", xlab="X",ylab="Y")
text(fit$points, labels = as.character(1:nrow(selData.x)))

#' 
#' ### 6.5) Draw the Shepard plot for this isoMDS results and comment on them [3 Marks]
#' 
## ----Q6.5----------------------------------------------------------------
selData.dist<-dist(selData.x)
selData.dist.mds.2 <- isoMDS(selData.dist, k=2)
selData.dist.mds.3 <- isoMDS(selData.dist, k=3)
selData.dist.mds.4 <- isoMDS(selData.dist, k=4)

selData.sh.2<- Shepard(selData.dist, selData.dist.mds.2$points)
selData.sh.3<- Shepard(selData.dist, selData.dist.mds.3$points)
selData.sh.4<- Shepard(selData.dist, selData.dist.mds.4$points)
plot(selData.sh.2, pch= ".")
lines(selData.sh.2$x, selData.sh$yf, type = "S", col="red")
plot(selData.sh.3, pch= ".")
lines(selData.sh.3$x, selData.sh$yf, type = "S", col="red")
plot(selData.sh.4, pch= ".")
lines(selData.sh.4$x, selData.sh$yf, type = "S", col="red")

#' 
#' 
#' ### 6.6) For the same data above (selData), perform a non-metric MDS, called ‘isoMDS’ in R using the number of dimensions k set to 4.
#' 
#'   library(MASS)
#' 
#'   fit<-isoMDS(selData.dist, k=4) Draw the Shepard plot for this isoMDS results and compare the plot obtained for k=2 in Q6.6 above. 
#'   
#'   Comment on them [3 Marks]
#' 
## ----Q6.6----------------------------------------------------------------
fit<-isoMDS(selData.dist, k=4)
plot(fit$points, type = "n", xlab="X",ylab="Y")
text(fit$points, labels = as.character(1:nrow(selData.x)))

#' 
#' ### Question-7 - Clustering: [14 marks]
#' 
#' ### 7.1) K-Means clustering: Use the data file “SITdata2018.txt” provided in CloudDeakin for this question. Load the file “SITdata2018.txt” using the following:
#' 
#' zz<-read.table("SITdata2018.txt")
#' 
#' zz<-as.matrix(zz)
#' 
## ----Q7.1----------------------------------------------------------------

zz<-read.table("data/SITdata2018.txt")
zz<-as.matrix(zz)
# zz

#' 
## ----7.1.a---------------------------------------------------------------
# a) Draw a scatter plot of the data. [1 mark].
plot(zz)

#' 
## ----7.1.b---------------------------------------------------------------
# b) State the number of classes/clusters that can be found in the “SITdata2018” (zz) [1 marks].

#' 
## ----7.1.c---------------------------------------------------------------
# c) Use the above number of classes as the k value and perform the k-means clustering on that data. Show the results using a scatterplot. Comment on the clusters obtained. [4 Marks]
cl <-kmeans(zz, 4, nstart= 25)
plot(zz, col = cl$cluster)
points(cl$centers, col = 1:5, pch= 8)

#' 
## ----7.1.d---------------------------------------------------------------
# d) Vary the number of clusters (k value) from 2 to 20 in increments of 1 and perform the k-means clustering for the above data. Record the total within sum of squares (TOTWSS) value for each k, and plot a graph of TOTWSS verses k. Explain how you can use this graph to find the correct number of classes/clusters in the data. [3 marks]
totwss <- array(,c(20,1))
for (i in 2:20)
{
print(i)
totwss[i,1]=(kmeans(zz,centers=i))$tot.withinss
print(totwss[i])
}
plot(totwss, main="total within sum of squres(totWSS) with different K value")
totwss

#' 
#' ### 7.2) Spectral Clustering: Use the same dataset (zz) and run a spectral clustering (use the number of clusters/centers as 4) on it. Show the results on a scatter plot (with colour coding). Compare these clusters with the clusters obtained using the k-means above and comment on the results. [5 Marks]
#' 
## ----7.2-----------------------------------------------------------------

#data(zz)
zz.spectral<-read.table("data/SITdata2018.txt")
zz.spectral<-as.matrix(zz.spectral)
sc.spectral<-specc(zz.spectral, centers=5)
sc.spectral
centers(sc.spectral)
size(sc.spectral)
withinss(sc.spectral)
plot(zz.spectral, col=sc.spectral)

#' 
#' Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
