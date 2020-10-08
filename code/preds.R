# filename
#       preds.R
#
# description
#       Given a model name, return all predictions
#
# author
#       Dylan P. Jackson
library(readr)
library(dplyr)

preds <- function(model_name){
    # Read in all prediction files
    path <- sprintf("/home/dylan/repos/covid19-forecast-hub/data-processed/%s", model_name)
    files <- list.files(path = path, pattern = "*.csv", full.names = T)
    tbl <- lapply(files, read.csv)
    
    # Get number of predictions
    size <- length(tbl)
    
    # Create empty predictions dataframe of dates and predictions 
    dates <- 1:size
    class(dates) <- "Date"
    predictions <- data.frame(date = dates, value = numeric(size))

    # Populate table with predicted U.S. cumulative deaths per week 
    for (table_num in 1:size){
        # Get target date for this dataset 
        date <- tbl[[table_num]]$target_end_date[1]
        value <- 0
        # Get cumulative for US if already in table
        value <- tbl[[table_num]]$value[tbl[[table_num]]$target ==
            "1 wk ahead cum death" & tbl[[table_num]]$type == "point"
            & tbl[[table_num]]$location == "US"]
        # Calculate the sum of all individual state's predictions otherwise
        if (length(value) == ){
            value <- sum(tbl[[table_num]]$value[tbl[[table_num]]$target ==
                "1 wk ahead cum death" & tbl[[table_num]]$type == "point"])
        }
        predictions$date[table_num] <- date
        predictions$value[table_num] <- value
    }

    # Remove duplicate date entries through averaging
    by_date <- predictions %>% group_by(date)
    mean_by_date <- by_date %>% summarise(date = date, value = mean(value))
    predictions <- distinct(mean_by_date)

    return (predictions)
}
