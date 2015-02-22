#Author: Phillip Blevins
# 2/20/2015
#This scripts downloads Smartphones Data
library(sqldf)
library(xlsx)


#You should create one R script called run_analysis.R that does the following. 
#1. Merges the training and the test sets to create one data set.
#2. Extracts only the measurements on the mean and standard deviation for each measurement. 
#3. Uses descriptive activity names to name the activities in the data set
#4. Appropriately labels the data set with descriptive variable names. 
#5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


#download and unzip data file 
get_data<- function() {

#download and unzip the file
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, dest = "uci.zip", mode="wb")
unzip("uci.zip")
}


##Preforms some processing to convert raw dataset to a "Tidy" data set
#Creates one output files:
# Motion.csv  This is all the Mean and Standard Devations Varibles (66 in total) pulled out of the 531 varible data set
#TidyMotion.txt  This is a smaller data set that has the average of each of the mean and stdev variable for each activity and each subject
#
run_analysis<- function() {

#STEP 1
#Read in the features. There are 531 features.These correspoind to the 
#the columns of the x_train.txt file and x_test.txt
features = read.csv("./UCI HAR Dataset/features.txt",head=FALSE, sep=" ")
activity_label = read.csv("./UCI HAR Dataset/activity_labels.txt",head=FALSE, sep=" ")
activity_label$V1 <- as.character(activity_label$V1)
col <- rep(16, 561)
col[1] <- 17


#begin loading training data
train = read.fwf("./UCI HAR Dataset/train/X_train.txt", width=col)

#label this portion of the data set as train (not actually used)
train$set <- rep("train", nrow(train))

#load training labels
y_train = read.csv("./UCI HAR Dataset/train/y_train.txt",head=FALSE)
y_train$V1 <- as.character(y_train$V1)

#add the activity labels just read into the training dataset
train$activity <-y_train$V1

#Read the subject data
sub_train = read.csv("./UCI HAR Dataset/train/subject_train.txt",head=FALSE)
sub_train$V1 <- as.character(sub_train$V1)

#add the subject just read into the training dataset
train$subject <-sub_train$V1


#begin loading test data
test = read.fwf("./UCI HAR Dataset/test/X_test.txt", width=col)

#label this portion of the data set as test(not actually used)
test$set <- rep("test", nrow(test))

#load testing labels
y_test = read.csv("./UCI HAR Dataset/test/y_test.txt",head=FALSE)
y_test$V1 <- as.character(y_test$V1)

#add the activity labels just read into the test dataset
test$activity <-y_test$V1

#Read the subject data
sub_test = read.csv("./UCI HAR Dataset/test/subject_test.txt",head=FALSE)
sub_test$V1 <- as.character(sub_test$V1)

#add the subject just read into the test dataset
test$subject <-sub_test$V1



#bind the test and training data sets
motion <- rbind(test, train)
#End Step 1 Merges the training and the test sets to create one data set.

#Step 3  Uses descriptive activity names to name the activities in the data set
#instead of using the activity number add an activity_label column with full text description
for(i in 1:nrow(motion)){
  for (j in 1:nrow(activity_label)){
    if(motion$activity[i] == activity_label$V1[j])
      motion$activity_label[i] <- as.character(activity_label$V2[j])
  }}



#Begin Step 2
#we are only interesed in the Mean and Standard devations measurements. So we pull out
#all the features with mean() and std() in the varible name
msfeatures <- sqldf("select * from features where V2 like '%Mean()%' or V2 like '%std()%'")


#we have all the varibles we are interested in  the msfeatues. They are in V2
#V1 has numbers which will correspond to the column names.
#so we create a simple sql to select all the varibles were are interested in.
x <- paste("V",msfeatures$V1[1], sep="")
for (j in 2:nrow(msfeatures)) {
      y <- paste("V",msfeatures$V1[j], sep="")
     x <- paste(x, y, sep=", ")}

#in addition to all the mean and standard devation varibles we also want to 
#bring along the subject and activity_label into our new smaller data set
sql <- paste("select", x, ", subject, activity_label from motion") 


#short motion is our new smaller data set. It is not really shorter just skinnier
shortmotion <- sqldf(sql)
#End STEP 2


#Begin Step 4
#Create Readable Headers
#this changes the abstract short column names into super long and readable coloumn names.
# t & f go to Time and Frequency respectivly
# -mean() goes to Mean
# -std() goes to Stdev
# Gyro (which makes me hungry) goes to Gyroscope
# Acc goes to Acccelorometer
#-X -Y -Z go to XAxis, YAxis, ZAxis
#Mag goes to Magnitude
Names  <- character()
for(i in 1:nrow(msfeatures)) {
  temp <- msfeatures$V2[i]
  temp  <- gsub("(\\bf)(.*)","Frequency\\2",temp )
  temp  <- gsub("(\\bt)(.*)","Time\\2",temp )
  temp  <- gsub("(.*)(-mean\\(\\))(.*)","\\1Mean\\3",temp )
  temp  <- gsub("(.*)(-std\\(\\))(.*)","\\1Stdev\\3",temp )
  temp  <- gsub("(.*)(Gyro)(.*)","\\1Gyroscope\\3",temp )
  temp  <- gsub("(.*)(Acc)(.*)","\\1Accelerometer\\3",temp )
  temp  <- gsub("(.*)(-X)(.*)","\\1XAxis\\3",temp )
  temp  <- gsub("(.*)(-Y)(.*)","\\1YAxis\\3",temp )
  temp  <- gsub("(.*)(-Z)(.*)","\\1ZAxis\\3",temp )
  temp  <- gsub("(.*)(Mag)(.*)","\\1Magnitude\\3",temp )
  Names <- c(Names,temp) 
}

#we want to popluate the shortmotoin names to the longer more understandable names
#but we also don't want to forget about subject and activity_label
Names <- c(Names,names(shortmotion)[nrow(msfeatures)+1])
Names <- c(Names,names(shortmotion)[nrow(msfeatures)+2])

#write.xlsx(Names, "names.xlsx")

#replace names withh out new nicer names.
names(shortmotion) <- Names
#End Step 4
write.csv(shortmotion, "Motion.csv")
#Begin Step 5
#create and sql that averages all the varibles and alias the new average to AvgOLDVARIBLE Name and 
#groups by subject and activity_label
x=""
for (j in 1:nrow(msfeatures)) {
  y <- paste("Avg(",Names[j],") as Avg", Names[j], sep="")
  x <- paste(x, y, sep=", ")}
sql <- paste("select subject, activity_Label", x, "from shortmotion group by  subject, activity_label") 

#get out new tidy data set
tidy <- sqldf(sql)

#Write xlsx so that it can be easily visually inspected
#write.xlsx(tidy, "tidy.xlsx")

#output the Tidy Data set TidyMotion.txt
write.table(tidy, "TidyMotion.txt",  row.name=FALSE)
#End Step 5
}