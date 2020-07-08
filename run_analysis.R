############################################
#__________Getting and Cleaning Data.____
#_________Assignment 4:Course project.____
#________Alejandro Rubiano.______________
#############################################
rm(list = ls())

#You should create one R script called run_analysis.R that does the following.

#1. Merges the training and the test sets to create one data set.
#2. Extracts only the measurements on the mean and standard deviation for each measurement.
#3. Uses descriptive activity names to name the activities in the data set
#4. Appropriately labels the data set with descriptive variable names.
#5. From the data set in step 4, creates a second, independent tidy data set with the average 
#   of each variable for each activity and each subject.


#############
     #First, we need to load the packages, and set the working directory
##############

library(data.table);library(reshape2);library(dplyr);library(magrittr)
#getwd()
setwd("C:/Users/aleja/Documents/Cursos/Coursera R pratices")

#############
     # Downloading and saving the ZIP file, which contains the archives
     # we need.
#############

url_1<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(url_1, file.path(getwd(), "UCI HAR Dataset.zip"))
unzip(zipfile = "UCI HAR Dataset.zip")

###########
     # look all the archives downloaded
###########

list.files(file.path(getwd(),"UCI HAR Dataset" ), recursive = T)

###############
     # We need to import all the label names and the train/test archives
     # Then, we need to merge the different train/test archives
###############

fread(file.path(getwd(), "UCI HAR Dataset/activity_labels.txt"))->UCI_labels
colnames(UCI_labels)<-c("code activity","description activity")

fread(file.path(getwd(), "UCI HAR Dataset/features.txt"))->f
colnames(f)<-c("index", "Names")


features2 <- grep("(mean|std)\\(\\)", f[,Names])
features <- f[features2, Names]
features <- gsub('[()]', '', features)

###########

fread(file.path(getwd(), "UCI HAR Dataset/train/X_train.txt"))[, features2, with = FALSE]->train_data 
setnames(train_data, colnames(train_data), features)

fread(file.path(getwd(), "UCI HAR Dataset/train/Y_train.txt"))->train_activity
colnames(train_activity)<-"activities"

fread(file.path(getwd(), "UCI HAR Dataset/train/subject_train.txt"))->train_subjects
colnames(train_subjects)<-"subjects"

train <- cbind(train_subjects, train_activity, train_data);head(train)


###############
fread(file.path(getwd(), "UCI HAR Dataset/test/X_test.txt"))[, features2, with = F]->test_data
setnames(test_data, colnames(test_data), features)

fread(file.path(getwd(), "UCI HAR Dataset/test/Y_test.txt"))->test_activity
colnames(test_activity)<-"activities"

fread(file.path(getwd(), "UCI HAR Dataset/test/subject_test.txt"))->test_subject
colnames(test_subject)<-"subjects"

test <- cbind(test_subject, test_activity, test_data);head(test)


#########
     #Create a new data.table, with the train and test files combined
     #Then, we set descriptive varaibles names
##########

UCI_complete_data<-rbind(train, test)
head(UCI_complete_data)

gsub("^t", "time", names(UCI_complete_data))->names(UCI_complete_data)
gsub("^f", "frequency", names(UCI_complete_data))->names(UCI_complete_data)
gsub("Acc", "Accelerometer", names(UCI_complete_data))->names(UCI_complete_data)
gsub("Gyro", "Gyroscope", names(UCI_complete_data))->names(UCI_complete_data)
gsub("Mag", "Magnitude", names(UCI_complete_data))->names(UCI_complete_data)
gsub("BodyBody", "Body", names(UCI_complete_data))->names(UCI_complete_data)

head(names(UCI_complete_data));tail(names(UCI_complete_data))



factor(UCI_complete_data[, activities], 
       levels = UCI_labels[["code activity"]], 
       labels = UCI_labels[["description activity"]])->UCI_complete_data[,2]
head(UCI_complete_data[1:20,1:10], n = 20)


melt(data = UCI_complete_data, id = c("subjects", "activities"))->UCI_complete_data2
UCI_complete_data2 <- reshape2::dcast(data = UCI_complete_data2, subjects + activities ~ variable, fun.aggregate = mean)

write.table(UCI_complete_data2, file = "tidy_UCI_HAR_Dataset.txt",row.name=FALSE)

