# filename
#       clean_analyse.R
#
# description
#       Given a model's predictions and truth data, construct two dataframes
#       of equal length, filling in missing prediction dates with NA's. 
#       Create comparison graph between two datasets.
#       Perform analysis on the now corresponding data. 
#
# author
#       Dylan P. Jackson
library(ggplot2)

# Compute squared error element wise
squared_error <- function(truth, preds){
    return ((truth - preds)^2) 
}

c_analyse <- function(truth, preds, model){
    # Add all of preds values to new data frame whose dates are equal to those
    # of truth, setting NA for missing entries
    dates <- truth$date
    values <- vector(length = nrow(truth))
    preds_full <- data.frame(date = dates, value = values)
    preds_full$value <- NA
    # Get indices of values from preds that have dates inside range of
    # preds_full$date
    ind_values <- preds$date %in% preds_full$date
    # Get indices of dates from preds_full that match with those from preds
    ind_dates <- preds_full$date %in% preds$date
    preds_full$value[ind_dates] <- preds$value[ind_values]

    # Save comparison graph
    start <- format(dates[1], "%b %d, %Y")
    end <- format(dates[length(dates)], "%b %d, %Y")
    title <- sprintf("%s predictions vs. actual US deaths from %s to %s",
        model, start, end)

    # Check if directory exists, if not, create it
    mainDir <- "/home/dylan/repos/covid_factors/visualizations" 
    ifelse(!dir.exists(file.path(mainDir, model)), dir.create(file.path(mainDir, model)), FALSE)

    path <- sprintf("../visualizations/%s/comp.png", model)
    png(path, width = 720, height = 720)
    plot(truth$date, truth$value, type = "l", col = "red", xlab = "Dates",
        ylab = "US Deaths (Per 10000)", main = title)
    lines(preds_full$date, preds_full$value, type = "p", col = "blue")
    legend("topleft", legend = c("Actual", model), col = c("red", "blue"),
        pch = c(1,1))
    dev.off()

    # Perform analyses
    errors <- squared_error(truth$value[ind_dates] * 10000,
        preds_full$value[ind_dates] * 10000)
    mserr <- mean(errors)
    recent_errors <- errors[(length(errors) - 7):length(errors)]
    recent_median_error <- median(recent_errors)
    recent_variance <- var(recent_errors)
    max_date <- preds_full$date[ind_dates][which.max(errors)]
    min_date <- preds_full$date[ind_dates][which.min(errors)]
    num_preds <- length(ind_values) 

    # Generate error data in same manner as predictions graph above 
    errors_full <- data.frame(date = dates, error = values)
    errors_full$error <- NA
    errors_full$error[ind_dates] <- errors[ind_values]

    # Generate bar plot of errors 
    title <- sprintf("%s prediction errors from %s to %s", model, start, end)
    path <- sprintf("../visualizations/%s/errors_bar.png", model)
    bar_plot <- ggplot(errors_full, aes(date, error)) + geom_col(aes(fill = error)) + labs(title = title) 
    ggsave(path, bar_plot) 

    # Generate distribution of errors
    title <- sprintf("Error distribution of %s predictions from %s to %s", model, start, end)
    path <- sprintf("../visualizations/%s/errors_dist.png", model)
    df_errors <- data.frame(error = errors_full$error)
    dist <- ggplot(df_errors, aes(error)) + 
            geom_histogram(color = "darkblue", fill = "lightblue") + 
            labs(title = title) + 
            theme(plot.title = element_text(size = 12))
    ggsave(path, dist)

    return (list(mserr, recent_median_error, recent_variance, max_date, 
                min_date, num_preds))
    
}
