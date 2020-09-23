library(readr)
model_name <- "LANL-GrowthRate"
path <- sprintf("/home/dylan/repos/covid_factors/data/%s", model_name)
files <- list.files(path = path, pattern = "*.csv", full.names = T)
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
png('../visualizations/LANL_1week.png', width = 720, height = 720)
start <- format(predictions$date[1], format = "%b %d, %Y")
end <- format(predictions$date[size], format = "%b %d, %Y")
title <- sprintf("LANL 1 week out US predictions from %s to %s", start, end)
predictions$value <- predictions$value / 10000
plot(predictions, main = title, type = "b", xlab = "Dates", ylab = "Total US Deaths (Per 10000)")
dev.off()