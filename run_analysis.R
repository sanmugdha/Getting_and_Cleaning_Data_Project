## First load all data we will need. This includes the test and train data sets (all the hard data),
## the y_test and y_train (activity codes for the data), and subject_test and subject_train (the 
## subject codes for the data)
test_data <- read.table("UCI HAR Dataset/test/X_test.txt", header = FALSE)
subject_test <- scan("UCI HAR Dataset/test/subject_test.txt")
y_test <- scan("UCI HAR Dataset/test/y_test.txt")
train_data <- read.table("UCI HAR Dataset/train/X_train.txt", header = FALSE)
subject_train <- scan("UCI HAR Dataset/train/subject_train.txt")
y_train <- scan("UCI HAR Dataset/train/y_train.txt")

## Also extract the header for the data from th header file.
my_header <- scan("UCI HAR Dataset/features.txt", what = character())
## Take out all odd entry's of the header vector as these are 1, 2, 3,... and aren't what we want
my_header <- my_header[c(FALSE, TRUE)]
## Make the variable names a little more pretty
my_header <- gsub('-mean', 'Mean', my_header)
my_header <- gsub('-std', 'StD', my_header)
my_header <- gsub('[()-]', '', my_header)

## Add the headers to your data
colnames(test_data) <- my_header
colnames(train_data) <- my_header

## Find which columns deal with mean or standard deviation (you want to keep)
mean_vec <- grep('Mean', my_header)
std_vec <- grep('StD', my_header)
cols_we_want <- c(mean_vec, std_vec)
cols_we_want <- sort(cols_we_want)

## Only keep the data in the columns you want to keep
test_data <- test_data[, cols_we_want]
train_data <- train_data[, cols_we_want]

## Now add the subject and activity columns to your data
test_data["Subjects"] <- subject_test
train_data["Subjects"] <- subject_train
test_data["Activity"] <- y_test
train_data["Activity"] <- y_train

library(dplyr)
## Combine your two data sets, and put the activity and subject columns at the front
tot_data <- bind_rows(train_data, test_data)
tot_data <- tot_data[,c(87,88,1:86)]

## Give the activity meaningful names in place of their numbers
activity.code <- c(Walking = 1, 'Walking Upstairs' = 2, 'Walking Downstairs' = 3, Sitting = 4, Standing = 5, Laying = 6)
tot_data$Activity <- names(activity.code)[match(tot_data$Activity, activity.code)]

## Find average for each subject and activity for each variable
avg_data <- tot_data %>% group_by(Subjects, Activity) %>% summarise_each(funs(mean))

write.table(avg_data, "avg_data.txt", row.names = FALSE)