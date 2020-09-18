plot_preds <- function(){
    library(readr)
    files <- list.files(path = "/home/dylan/repos/covid_factors/data/LANL-GrowthRate",
        pattern = "*.csv", full.names = T)
    tbl <- lapply(files, read_csv)

    size <- 0
    for (file in files){
        size <- size + 1
    }

    dates <- 1:size
    class(dates) <- "Date"
    predictions <- data.frame(date = dates, value = numeric(size))

    for (table_num in 1:size){
        date <- tbl[[table_num]]$target_end_date[1]
        value <- sum(tbl[[table_num]]$value[tbl[[table_num]]$target ==
            "1 wk ahead cum death" & tbl[[table_num]]$type == "point"])
        predictions$date[table_num] <- date
        predictions$value[table_num] <- value
    }
    plot(predictions)
}
