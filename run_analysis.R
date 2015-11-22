require(dplyr)

url.src <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dataFileZipName <- "UCI-HAR-Dataset.zip"
dataFolderName <- "UCI\ HAR\ Dataset"

# download data set if it doesn't exist
if (!file.exists(dataFileZipName)) {
    download.file(url = url.src, destfile = dataFileZipName, method = "curl")
}

# unzip data if it doesn't exist
if (!file.exists(dataFolderName)){
    unzip(dataFileZipName)
}

# read in activity and feature labels
activityLabels <- read.table(paste(dataFolderName,"activity_labels.txt",sep="/"),col.names = c("id","activity"))
featureLabels <- read.table(paste(dataFolderName,"features.txt",sep="/"),col.names = c("id","feature"))

#read in training data
subject.train <- read.table(paste(dataFolderName,"train","subject_train.txt",sep="/"))
data.train <- read.table(paste(dataFolderName,"train","X_train.txt",sep="/"))
activity.train <- read.table(paste(dataFolderName,"train","y_train.txt",sep="/"))

# read in test data
subject.test <- read.table(paste(dataFolderName,"test","subject_test.txt",sep="/"))
data.test <- read.table(paste(dataFolderName,"test","X_test.txt",sep="/"))
activity.test <- read.table(paste(dataFolderName,"test","y_test.txt",sep="/"))

# compile all training data into a single data frame    
train.data <- data.frame(subject.train,activity.train,data.train)
names(train.data) <- c("subject","activity",as.character(featureLabels[,2]))

# compile all test data into a single data frame    
test.data <- data.frame(subject.test,activity.test,data.test)
names(test.data) <- c("subject","activity",as.character(featureLabels[,2]))

# join training and test data
all.data <- rbind(train.data,test.data)

# extract only mean and standard deviation for each measurement
all.data2 <- all.data[,c(1,2,grep("(mean|std)\\(\\)",names(all.data)))]

# replace activity numbers with their descriptive name
all.data2$activity <- activityLabels[all.data2$activity,2]

# compile sumary table with averages for each column
summ.table <- summarise_each(group_by(all.data2,subject,activity),funs(mean))

# write summary table to file
write.table(summ.table,file="summary-table.txt",row.names=FALSE)
