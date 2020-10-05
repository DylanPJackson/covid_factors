# filename 
#       us_deaths.R
# 
# description 
#       Grab current US death data and plot cumulative deaths
#
# author
#       Dylan P. Jackson
#

us_deaths <- function(){
    # Read in the data
    usd_unf <- read.csv("../data/us_deaths_09_17_20.csv")

    # Trivial reformatting
    cum_d <- usd_unf$location == "US"
    usd_f <- usd_unf[cum_d,]
    usd_f$date <- as.Date(usd_f$date)
    usd_f$value <- usd_f$value / 10000

    # Plot and save 
    png('../visualizations/us_deaths.png', width = 720, height = 720)
    plot(x = usd_f$date, y = usd_f$value, xlab = "Dates",
        ylab = "U.S. Cumulative Deaths (Per 10000)", 
        main = "U.S. Cumulative Deaths from Feb 29,2020 - Sep 16,2020",
        type = "l", col = "red")
    dev.off()
    return (usd_f)
}
