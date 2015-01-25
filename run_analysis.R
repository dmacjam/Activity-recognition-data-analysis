## Coursera Getting and Cleaning Data Course Project

# download data if it is not in directory
if (!file.info("UCI HAR Dataset")$isdir) {
  message("Downloading files...")
  dataFile <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(dataFile, "UCI-HAR-dataset.zip", method="curl")
  unzip("UCI-HAR-dataset.zip")
}

# load libraries
library(dplyr)


features_names <- read.table("UCI HAR Dataset/features.txt")
activities <- read.table("UCI HAR Dataset/activity_labels.txt",col.names=c("activity_id","activity"))
# Extract only the measurements on the mean and standard deviation for each measurement.
mean_std_rows <- grepl("(mean|std)\\(",features_names[,2])

# Appropriately label the data set with descriptive activity names.
colNames <- as.character(features_names[,2])
for (i in 1:length(colNames)) 
{
  colNames[i] = gsub("\\()","",colNames[i])
  colNames[i] = gsub("-std$","StdDev",colNames[i])
  colNames[i] = gsub("-mean","Mean",colNames[i])
  colNames[i] = gsub("^(t)","time",colNames[i])
  colNames[i] = gsub("^(f)","freq",colNames[i])
  colNames[i] = gsub("([Gg]ravity)","Gravity",colNames[i])
  colNames[i] = gsub("([Bb]ody[Bb]ody|[Bb]ody)","Body",colNames[i])
  colNames[i] = gsub("[Gg]yro","Gyro",colNames[i])
  colNames[i] = gsub("AccMag","AccMagnitude",colNames[i])
  colNames[i] = gsub("([Bb]odyaccjerkmag)","BodyAccJerkMagnitude",colNames[i])
  colNames[i] = gsub("JerkMag","JerkMagnitude",colNames[i])
  colNames[i] = gsub("GyroMag","GyroMagnitude",colNames[i])
};
features_names <- colNames

# read test data
subject_test <- read.table("UCI HAR Dataset//test/subject_test.txt",col.names=c("subject_id"))
x_test <- read.table("UCI HAR Dataset//test/X_test.txt", col.names=features_names)  #[,2]
x_test <- x_test[,mean_std_rows]      #subset of columns
y_test <- read.table("UCI HAR Dataset//test/y_test.txt",col.names=c("activity_id"))
testData <- cbind(subject_test,x_test,y_test)

# read train data
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt",col.names=c("subject_id"))
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names=features_names)
x_train <- x_train[,mean_std_rows]
y_train <- read.table("UCI HAR Dataset/train/y_train.txt",col.names=c("activity_id"))
trainData <- cbind(subject_train,x_train,y_train)

# create one dataset
dataset <- rbind(trainData,testData)
dataset <- dataset[complete.cases(dataset),]  #only complete columns
dataset <- merge(dataset,activities,by="activity_id")

# remove unused
dataset$activity_id <- NULL

# creates a second, independent tidy data set with the average of each variable for each activity and each subject.
aggregated_dataset <- aggregate(select(dataset,-(activity),-(subject_id)),list(activity = dataset$activity,subject_id = dataset$subject_id),mean)
write.table(aggregated_dataset,file="aggregated_dataset.txt",row.names=FALSE, sep="\t")
