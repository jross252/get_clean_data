library(plyr)
download.data = function() {
"Checks for data directory and creates one if it doesn't exist"
if (!file.exists("data")) {
message("Creating data directory")
dir.create("data")
}
if (!file.exists("data/UCI HAR Dataset")) {

fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipfile="data/UCI_HAR_data.zip"
message("Downloading data")
download.file(fileURL, destfile=zipfile, method="curl")
unzip(zipfile, exdir="data")
}
}

run.analysis <- function(){
setwd('UCI HAR Dataset/')

## Load id->feature label data
feature.vector.labels.data <- read.table('features.txt', col.names = c('id','label'))

## Select only the measurements on the mean and standard deviation for each measurement.
selected.features <- subset(feature.vector.labels.data, grepl('-(mean|std)\\(', feature.vector.labels.data$label))

activity.labels <- read.table('activity_labels.txt', col.names = c('id', 'label'))

## Read train and test data sets
sprint("Read and process training dataset")
train.df <- load.dataset('train', selected.features, activity.labels)
print("Read and process test dataset")
test.df <- load.dataset('test', selected.features, activity.labels)

## Merged train and test sets
print("Merge train and test sets")
merged.df <- rbind(train.df, test.df)
print("Finished dataset loading and merging")

## Convert to data.table for making it easier and faster
merged.dt <- data.table(merged.df)

## Calculate the average of each variable for each activity and each subject.
tidy.dt <- merged.dt[, lapply(.SD, mean), by=list(label,subject)]

## Tidy variable names
tidy.dt.names <- names(tidy.dt)
tidy.dt.names <- gsub('-mean', 'Mean', tidy.dt.names)
tidy.dt.names <- gsub('-std', 'Std', tidy.dt.names)
tidy.dt.names <- gsub('[()-]', '', tidy.dt.names)
tidy.dt.names <- gsub('BodyBody', 'Body', tidy.dt.names)
setnames(tidy.dt, tidy.dt.names)

## Save datasets
setwd('..')
write.csv(merged.dt, file = 'uci-har-raw-data.csv', row.names = FALSE)
write.csv(tidy.dt,
file = 'uci-har-tidy-data.csv',
row.names = FALSE, quote = FALSE, sep = ";")
print("Finished processing. Tidy dataset is written to uci-har-tidy-data.csv")
}