# Code Book for Summarised Human Activity Reaction data set
Marlan Perumal  
22 November 2015  

## Data Description

The Data comes from a study using Samsung Galaxy S II smartphones to track the activity of 30 volunteers by using the phone's built in accelerometer and gyroscope. In each case the subject, activity and sensor readings were recorded over a period of time. The data is split between a training and test dta sets. More information is available at http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

The data has the following file structure:

- **features_info.txt**: contains a description of all the measured variables  
- **features.txt**: a two column data file containing an index and the descriptive names for each of the measurements in the order they appear in the data files  
- **activity_labels.txt**: a two column data file containing an index and the descriptive names for each of the activity factor levels  
- Folders **training** and **test** containing the actual data for the training and test data sets respectively. The files below contain corresponding data for each observation (where TTT is either training or test as appropriate).
    + **subject_TTT.txt**: subject ids
    + **X_TTT.txt**: measureents
    + **y_TTT.txt**: activity id

## Loading and Manipulation of Data

The data are loaded and manipulated as follows:

Fist the *dplyr* package is loaded

```r
require(dplyr)
```

If the data is not already contained in the working directory it is downloaded from the source, and unzipped.

```r
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
```

The activity and feature labels are read in from their respective files

```r
# read in activity and feature labels
activityLabels <- read.table(paste(dataFolderName,"activity_labels.txt",sep="/"),col.names = c("id","activity"))
featureLabels <- read.table(paste(dataFolderName,"features.txt",sep="/"),col.names = c("id","feature"))
```

The training and test data are read in from the 3 files containing respectively the subject id, measured data and activity.

```r
#read in training data
subject.train <- read.table(paste(dataFolderName,"train","subject_train.txt",sep="/"))
data.train <- read.table(paste(dataFolderName,"train","X_train.txt",sep="/"))
activity.train <- read.table(paste(dataFolderName,"train","y_train.txt",sep="/"))

# read in test data
subject.test <- read.table(paste(dataFolderName,"test","subject_test.txt",sep="/"))
data.test <- read.table(paste(dataFolderName,"test","X_test.txt",sep="/"))
activity.test <- read.table(paste(dataFolderName,"test","y_test.txt",sep="/"))
```

These are all compiled into a single data frame, with column headings for the measurements coming from the previously read feature labels.

```r
# compile all training data into a single data frame    
train.data <- data.frame(subject.train,activity.train,data.train)
names(train.data) <- c("subject","activity",as.character(featureLabels[,2]))

# compile all test data into a single data frame    
test.data <- data.frame(subject.test,activity.test,data.test)
names(test.data) <- c("subject","activity",as.character(featureLabels[,2]))
```

The training and test data are stacked.

```r
# join training and test data
all.data <- rbind(train.data,test.data)
```

The *grep* command is used to find all the measurements with **mean** or **std** in their names, and a new data frame is compiled with just the subject, activity and these measurement mean and standard deviations.

```r
# extract only mean and standard deviation for each measurement
all.data2 <- all.data[,c(1,2,grep("(mean|std)\\(\\)",names(all.data)))]
```

The coded activities are then replaced with the actual acitivity names

```r
# replace activity numbers with their descriptive name
all.data2$activity <- activityLabels[all.data2$activity,2]
```

The *summarise_each* function from the *dplyr* library is used to extract the means of each of the measurement columns for each subject/activity combination.

```r
# compile sumary table with averages for each column
summ.table <- summarise_each(group_by(all.data2,subject,activity),funs(mean))
```

Finally the summary table is written to file.

```r
# write summary table to file
write.table(summ.table,file="summary-table.txt",row.names=FALSE)
```

## Output file description

- The *subject* column holds the subject id's from 1 to 30.
- The *activity* column gives the current activity for each observation being one of WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING
- The remaining columns give the avearge of the mean and standard deviations of each of the measurements. A description of each measurement is given in the *features_info.txt* file in the data set and is reproduced below


The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. 

Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). 

Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals). 

These signals were used to estimate variables of the feature vector for each pattern:  
'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

tBodyAcc-XYZ  
tGravityAcc-XYZ  
tBodyAccJerk-XYZ  
tBodyGyro-XYZ  
tBodyGyroJerk-XYZ  
tBodyAccMag  
tGravityAccMag  
tBodyAccJerkMag  
tBodyGyroMag  
tBodyGyroJerkMag  
fBodyAcc-XYZ  
fBodyAccJerk-XYZ  
fBodyGyro-XYZ  
fBodyAccMag  
fBodyAccJerkMag  
fBodyGyroMag  
fBodyGyroJerkMag  

The set of variables that were estimated from these signals are: 

mean(): Mean value  
std(): Standard deviation  
mad(): Median absolute deviation  
max(): Largest value in array  
min(): Smallest value in array  
sma(): Signal magnitude area  
energy(): Energy measure. Sum of the squares divided by the number of values.  
iqr(): Interquartile range   
entropy(): Signal entropy  
arCoeff(): Autorregresion coefficients with Burg order equal to 4  
correlation(): correlation coefficient between two signals  
maxInds(): index of the frequency component with largest magnitude  
meanFreq(): Weighted average of the frequency components to obtain a mean frequency 
skewness(): skewness of the frequency domain signal  
kurtosis(): kurtosis of the frequency domain signal  
bandsEnergy(): Energy of a frequency interval within the 64 bins of the FFT of each window.  
angle(): Angle between to vectors.  

Additional vectors obtained by averaging the signals in a signal window sample. These are used on the angle() variable:

gravityMean  
tBodyAccMean  
tBodyAccJerkMean  
tBodyGyroMean  
tBodyGyroJerkMean  

The complete list of variables of each feature vector is available in 'features.txt'
