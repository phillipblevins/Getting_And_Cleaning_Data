

The run_analysis.R contains two functions:

**get_data() -** This function downloads the data from [https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) and unzip it into the working directory into the folder ./UCI HAR Dataset/  

**run_anlysis()** This function process the data downloaded by get__data(), creates a tidy dataset, and saves that tidy dataset as TidyMotion.txt.  This dataset is made up of the mean and standard deviation measurement variables  from the raw dataset that have been averaged for each test subject and test subjects activity. Please see the Code Book for a completed list and description of the variables. 



   



