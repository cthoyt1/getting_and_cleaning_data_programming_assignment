#Load the package reshape2.
library(reshape2)

#Establish a filename for data download location.
filename <- "sensor_data.zip"

#Check if the data filename already exists; if not, download the sensor data.
if (!file.exists(filename)) {
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL,filename)
}

if (!file.exists("UCI HAR Dataset")) {
  unzip(filename)
}

#Download activity labels data and convert second column to a character variable (initially numeric, oddly).
activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])

#Download features data and convert second column to a character variable.
features <- read.table("./UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

#Create a features dataset that is limited to features that contain the mean or standard deviation variables.
featuresWanted <- grep(".*mean.*|.*std.*",features[,2])
featuresWanted.names <- features[featuresWanted,2]


#Make features prettier.
featuresWanted.names = gsub('-mean','Mean',featuresWanted.names)
featuresWanted.names = gsub('-std','Std',featuresWanted.names)
featuresWanted.names = gsub('[-()]','',featuresWanted.names)

#Download test datasets.
train <- read.table("./UCI HAR Dataset/train/X_train.txt")[featuresWanted]
trainActivities <- read.table("./UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("./UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects,trainActivities,train)

#Download training datasets.
test <- read.table("./UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testActivities <- read.table("./UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("./UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects,testActivities,test)

#Combine test and train datasets, rename columns.
completedata <- rbind(train, test)
colnames(completedata) <- c("subject","activity",featuresWanted.names)

#Turns activities and subjects in factors.
completedata$activity <- factor(completedata$activity,levels = activityLabels[,1],labels = activityLabels[,2])
completedata$subject <- as.factor(completedata$subject)

#Melt and cast data, write tidy.txt data!
completedata.melted <- melt(completedata, id = c("subject","activity"))
completedata.mean <- dcast(completedata.melted, subject + activity ~ variable,mean)
write.table(completedata.mean,"tidy.txt",row.names = FALSE, quote = FALSE)