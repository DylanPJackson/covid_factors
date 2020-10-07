# filename
#       summary.R
#
# description
#       Create table summary and graphs of all models
#
# author
#       Dylan P. Jackson

source("comp_LANL.R")
library(gridExtra)
library(grid)
library("Metrics")

# Compute squared error element wise
squared_error <- function(truth, pred){
    return ((truth - pred)^2)
}

mserr <- mse(us_deaths$value[ind_dates] * 10000, preds_full$value[ind_dates] * 10000)
errors <- squared_error(us_deaths$value[ind_dates] * 10000, 
            preds_full$value[ind_dates] * 10000) 
max_date <- preds_full$date[ind_dates][which.max(errors)]
min_date <- preds_full$date[ind_dates][which.min(errors)]

summ <- data.frame(model = c("LANL-GrowthRate"),
                   mse = c(mserr),
                   max_error_date = c(max_date),
                   min_error_date = c(min_date))

png("../visualizations/summ.png", height = 720, width = 720)
grid.table(summ, rows = NULL)
dev.off()
