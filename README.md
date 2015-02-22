

The run_analysis.R contains two functions:

**get_data() -** This function downloads the data from [https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) and unzip it into the working directory into the folder ./UCI HAR Dataset/  

**run_anlysis()** This function process the data downloaded by get__data(), creates a tidy dataset, and saves that tidy dataset as TidyMotion.txt. it Does several things to accomplish this.
1.  It combines X_test.txt, y_test.txt and subject_test into a single flat test data set

2.  It combines X_traint.txt, y_train.txt and subject_train into a single flat train data set

3.  it combines the train and test dataset into a single dataset

4.  From the combined dataset it pulls out the mean and standard deviations observation columns to create a new thinner dataset

5.  Renames most of the variable header names to human readable variable names.

6.  Creates an average for each variable for each Subject Activity combination and creates a new "Tidy" data set with this data.


   



