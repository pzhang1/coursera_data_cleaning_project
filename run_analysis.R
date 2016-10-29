library(reshape2)

# Name the downloaded data sets 
f <- "dataset.zip"

## Download the datasets
if (!file.exists(f)){
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(url, f, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(f) 
}

# Load the labels from activity as well as the features
aLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
aLabels[,2] <- as.character(aLabels[,2])
fea <- read.table("UCI HAR Dataset/features.txt")
fea[,2] <- as.character(fea[,2])

# Get only the mean and standard deviation
feaWan <- grep(".*mean.*|.*std.*", fea[,2])
feaWan.names <- fea[feaWan,2]
feaWan.names = gsub('-mean', 'Mean', feaWan.names)
feaWan.names = gsub('-std', 'Std', feaWan.names)
feaWan.names <- gsub('[-()]', '', feaWan.names)


# Load the training and testing datasets
tra <- read.table("UCI HAR Dataset/train/X_train.txt")[feaWan]
traAct <- read.table("UCI HAR Dataset/train/Y_train.txt")
traSub <- read.table("UCI HAR Dataset/train/subject_train.txt")
tra <- cbind(traSub, traAct, tra)

tes <- read.table("UCI HAR Dataset/test/X_test.txt")[feaWan]
tesAct <- read.table("UCI HAR Dataset/test/Y_test.txt")
tesSub <- read.table("UCI HAR Dataset/test/subject_test.txt")
tes <- cbind(tesSub, tesAct, tes)

# merge the train and test data sets and add labels
all <- rbind(tra, tes)
colnames(all) <- c("subject", "activity", feaWan.names)

# put the activity and subject into factor
all$activity <- factor(all$activity, levels = aLabels[,1], labels = aLabels[,2])
all$subject <- as.factor(all$subject)

all.mel <- melt(all, id = c("subject", "activity"))
all.mean <- dcast(all.mel, subject + activity ~ variable, mean)

write.table(all.mean, "tidy_data_sets.txt", row.names = FALSE, quote = FALSE)