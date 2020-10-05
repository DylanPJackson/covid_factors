# filename 
#       comp_lanl.R 
#
# description
#       Create visual comparison between LANL-GrowthRate's predictions and
#       the actual deaths over all dates recorded with actual deaths.
#
# author
#       Dylan P. Jackson

source("LANL.R")
source("us_deaths.R")

# Load in predictions and actual data
lanl_preds <- lanl_pred()
us_deaths <- us_deaths() 

# Add all of lanl_preds values to new data frame whose dates are equal to those
# of us_deaths, setting NA for missing entries
dates <- us_deaths$date
values <- vector(length = nrow(us_deaths))
preds_full <- data.frame(date = dates, value = values)
preds_full$value <- NA
# Get indices of values from lanl_preds that have dates inside range of
# us_deaths$date
ind_values <- lanl_preds$date %in% preds_full$date
# Get indices of dates from preds_full that match with those from lanl_preds 
ind_dates <- preds_full$date %in% lanl_preds$date
preds_full$value[ind_dates] <- lanl_preds$value[ind_values]

# Plot the two series and save the image
png('../visualizations/lanl_comp.png', width = 720, height = 720)
plot(us_deaths$date, us_deaths$value, type = "l", col = "red", xlab = "Dates", ylab = "US Deaths (Per 10000)", main = "Actual vs. LANL-GrowthRate predictions of US Deaths")
lines(preds_full$date, preds_full$value, type = "p", col = "blue")
legend("topleft", legend = c("Actual", "LANL Prediction"), col = c("red", "blue"), pch = c(1,1))
dev.off()
