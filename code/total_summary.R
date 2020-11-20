# filename
#       total_summary.R
#
# description
#       Given a list of model names, perform analysis on each, plot each 
#       model against truth data, produce summary table.
#
# author
#       Dylan P. Jackson

library(gridExtra)
library(grid)
library(gtable)
library(ggplot2)
library(reshape)
source("preds.R")
source("us_deaths.R")
source("clean_analyse.R")

analyse <- function(models= c("LANL-GrowthRate", "MOBS-GLEAM_COVID",
                    "UMass-MechBayes", "YYG-ParamSearch",
                    "UCLA-SuEIR", 
                    "JHU_IDD-CovidSP")){ 
# MITCovAlliance-SIR
# COVIDhub-ensemble
# IHME-CurveFit
# UT-Mobility
# USACE-ERDC_SEIR
# UA-EpiCovDA
# IowaStateLW-STEM

    # Get current death truth data
    deaths <- us_deaths()

    # Initialize analysis dataframe 
    analysis <- data.frame(name = character(), mse = numeric(), 
                            recent_median_error = numeric(),
                            recent_variance = numeric(),
                            max_error_date = numeric(), 
                            min_error_date= numeric(), num_preds = numeric())

    # Initialize final error dataframe 
    total_errs <- data.frame(dates = deaths$date) 

    # Initialize final variance dataframe
    total_vars <- data.frame(dates = deaths$date)
     
    # Perform analysis on each of the models
    for (model in models){
        # Get predictions for each model
        predictions <- preds(model) 
        # Get statistics from predictions. This call also produces plots
        stats <- c_analyse(deaths, predictions, model) 
        new_row <- data.frame(name = model, mse = stats[[1]], 
                    recent_median_error = stats[[2]], recent_variance = stats[[3]],
                    max_error_date = stats[[4]], min_error_date = stats[[5]], 
                    num_preds = stats[[6]])
        # Add each model's statistics to summary analysis
        analysis <- rbind(analysis, new_row)
        # Add each model's errors to total errors dataframe
        total_errs <- cbind(total_errs, new = stats[[7]][2]) 
        names(total_errs)[ncol(total_errs)] <- model
        # Add each  model's variances to total variance dataframe
        total_vars <- cbind(total_vars, new = stats[[8]]) 
        names(total_vars)[ncol(total_vars)] <- model
    }

    # Reorder analysis by error ASC
    analysis <- analysis[order(analysis$recent_median_error),]
    analysis$mse <- analysis$mse / 10000
    analysis$recent_median_error <- analysis$recent_median_error / 10000
    
    # Generate summary table
    png("../visualizations/sum_tab.png", height = 800, width = 800)
    g <- tableGrob(analysis, rows = NULL)
    g <- gtable_add_grob(g,
            grobs = rectGrob(gp = gpar(fill = NA, lwd = 2)),
            t = 2, b = nrow(g), l = 1, r = ncol(g))
    g <- gtable_add_grob(g,
            grobs = rectGrob(gp = gpar(fill = NA, lwd = 2)),
            t = 1, l = 1, r = ncol(g))
    grid.draw(g)
    dev.off()

    # Save total errors plot
    start <- format(deaths$date[1], "%b %d, %Y")
    end <- format(deaths$date[nrow(deaths)], "%b %d, %Y")
    Molten <- melt(total_errs, id.vars = "dates")    
    title <- sprintf("Prediction errors of various COVID-19 prediction models from %s to %s", start, end) 
    err_plot <- ggplot(data = subset(Molten, !is.na(value)), aes(x = dates, y = value, colour = variable)) + geom_line() + geom_point() + labs(title = title) + ylab("Predicted Deaths") + theme(plot.title = element_text(size = 10)) 
    ggsave("../visualizations/total_errors.png", err_plot) 

    # Save total variances plot
    Molten <- melt(total_vars, id.vars = "dates")
    title <- sprintf("Variance in prediction error of various COVID-19 prediction models from %s to %s", start, end) 
    var_plot <- ggplot(data = subset(Molten, !is.na(value)), aes(x = dates, y = value, colour = variable)) + geom_line() + geom_point() + labs(title = title) + ylab("Variance in Prediction Error") + theme(plot.title = element_text(size = 10))
    ggsave("../visualizations/total_vars.png", var_plot)

    return(analysis)
}
