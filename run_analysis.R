library(dplyr)
features_names <- read.table("UCI HAR Dataset/features.txt")
activities <- read.table("UCI HAR Dataset/activity_labels.txt",col.names=c("activity_id","activity"))
mean_std_rows <- grep("(mean|std)\\(",features_names[,2])

subject_test <- read.table("UCI HAR Dataset//test/subject_test.txt",col.names=c("subject_id"))
x_test <- read.table("UCI HAR Dataset//test/X_test.txt", col.names=features_names[,2])
x_test <- x_test[,mean_std_rows]      #subset of columns
y_test <- read.table("UCI HAR Dataset//test/y_test.txt",col.names=c("activity_id"))
testData <- cbind(subject_test,x_test,y_test)

subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt",col.names=c("subject_id"))
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names=features_names[,2])
x_train <- x_train[,mean_std_rows]
y_train <- read.table("UCI HAR Dataset/train/y_train.txt",col.names=c("activity_id"))
trainData <- cbind(subject_train,x_train,y_train)

dataset <- rbind(trainData,testData)
dataset <- dataset[complete.cases(dataset),]  #only complete columns
dataset <- merge(dataset,activities,by="activity_id")

# remove unused
dataset$activity_id <- NULL

# creates a second, independent tidy data set with the average of each variable for each activity and each subject.
aggragated_dataset <- aggregate(select(dataset,-(activity),-(subject_id)),list(dataset$activity,dataset$subject_id),mean)
