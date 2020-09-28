# filename
#       LANL.R
#
# description
#       Grab all LANL-GrowthRate's predictions, reformat the data so that
#       it is represented as cumulative deaths, then plot the predicted
#       cumulative deaths.
# author
#       Dylan P. Jackson
library(readr)
library(dplyr)

# Read in all of LANL's predictions into a list
lanl_pred <- function(){
    model_name <- "LANL-GrowthRate"
    path <- sprintf("/home/dylan/repos/covid_factors/data/%s", model_name)
    files <- list.files(path = path, pattern = "*.csv", full.names = T)
    tbl <- lapply(files, read_csv)

    # Get the size of the list, because for whatever reason it's NULL atm
    size <- 0
    for (file in files){
        size <- size + 1
    }

    # Create empty predictions dataframe with blank dates and values
    dates <- 1:size
    class(dates) <- "Date"
    predictions <- data.frame(date = dates, value = numeric(size))

    # Populate the table with predicted U.S. cumulative deaths per day
    for (table_num in 1:size){
        # Get the target date for this dataset
        date <- tbl[[table_num]]$target_end_date[1]
        # Calculate the sum of all individual state's predictions
        value <- sum(tbl[[table_num]]$value[tbl[[table_num]]$target ==
            "1 wk ahead cum death" & tbl[[table_num]]$type == "point"])
        predictions$date[table_num] <- date
        predictions$value[table_num] <- value
    }

    # Remove duplicate date entries through averaging
    by_date <- predictions %>% group_by(date)
    mean_by_date <- by_date %>% summarise(date = date,value  = mean(value))
    predictions <- distinct(mean_by_date)

    # Save the plot to a .png file
    png('../visualizations/LANL_1week.png', width = 720, height = 720)
    start <- format(predictions$date[1], format = "%b %d, %Y")
    end <- format(predictions$date[nrow(predictions)], format = "%b %d, %Y")
    title <- sprintf("LANL 1 week out US predictions from %s to %s", start, end)
    predictions$value <- predictions$value / 10000
    plot(predictions, main = title, type = "b", xlab = "Dates", ylab = "Total US Deaths (Per 10000)")
    dev.off()
    return (predictions)
}
