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

# weighted_pred
#       Make a prediction for next week's COVID deaths based off of a weighted
#       average from variance and errors of each model
#
# Parameters
#       preds : vector
#               Contains last week's predictions from each model
#       errs : vector
#               Contains most recent median error from each model
#       vars : vector
#               Contains most recent rolling variance from each model
#       actual : int
#               The reported amount of deaths
weighted_pred <- function(preds_, errs, vars, actual){
    # Get weights as inverse of error and variance
    err_weights <- 1 / errs
    var_weights <- 1 / vars

    # Get intermediate values for each weighted average
    err_vals <- preds_ * err_weights
    var_vals <- preds_ * var_weights

    # Get weighted average from error and variance 
    err_avg <- sum(err_vals, na.rm = TRUE) / sum(err_weights, na.rm = TRUE)
    var_avg <- sum(var_vals, na.rm = TRUE) / sum(var_weights, na.rm = TRUE)

    # Vectorize weighted averages
    weighted_avgs <- c(err_avg, var_avg)

    # Get prediction error from error and variance weighted averages
    err <- abs(actual - weighted_avgs)
    
    # Get weights
    weights <- 1 / err

    # Intermediate values in final weighted average
    vals <- weighted_avgs * weights

    # Get prediction
    pred <- sum(vals) / sum(weights)

    return (pred)
}

analyse <- function(models= c("LANL-GrowthRate", "MOBS-GLEAM_COVID", 
                    "UMass-MechBayes", "YYG-ParamSearch", "MITCovAlliance-SIR", 
                    "UCLA-SuEIR", "COVIDhub-ensemble", "IHME-CurveFit", 
                    "UT-Mobility", "USACE-ERDC_SEIR", "UA-EpiCovDA",
                    "IowaStateLW-STEM", "JHU_IDD-CovidSP")){ 

    # Get current death truth data
    deaths <- us_deaths()

    # Initialize prediction vector for weighted average prediction
    #w_preds <- numeric()
    
    # Initialize error vector for weighted average prediction
    #w_errs <- numeric()

    # Initialize variance vector for weighted average prediction
    #w_vars <- numeric()

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

    # Initialize final prediction dataframe
    total_preds <- data.frame(dates = deaths$date)
     
    # Perform analysis on each of the models
    for (model in models){
        # Get predictions for each model
        predictions <- preds(model) 
        # Get statistics from predictions. This call also produces plots for each model
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
        # Add each model's prediction to total prediction dataframe
        total_preds <- cbind(total_preds, new = stats[[9]][2])
        names(total_preds)[ncol(total_preds)] <- model
        
        # Weighted average prediction 
        # Get most recent prediction
        #pred <- predictions$value[length(predictions$value)]
        #w_preds <- append(w_preds, pred)

        # Get most recent error
        #errs <- stats[[7]][2]
        #not_na_err <- which(!is.na(errs))
        #err_ind <- not_na_err[length(not_na_err) - 1] 
        #err <- errs[[1]][err_ind] 
        #w_errs <- append(w_errs, err)

        # Get most recent variance
        #vars <- stats[[8]]
        #not_na_var <- which(!is.na(vars))
        #var_ind <- not_na_var[length(not_na_var) - 1]
        #var <- vars[var_ind]
        #w_vars <- append(w_vars, var)
    }

    # Reorder analysis by error ASC
    analysis <- analysis[order(analysis$recent_median_error),]
    analysis$mse <- analysis$mse 
    analysis$recent_median_error <- analysis$recent_median_error 
    
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

    # Get prediction from weighted average
    #pred <- weighted_pred(w_preds, w_errs, w_vars, deaths$value[length(deaths$value) - 1]) 
    #print(w_preds)
    #print(w_errs)
    #print(w_vars)
    #sprintf("Prediction based off of weighted averages : %f", pred)
    #print(pred)

    # Get weighted average predictions
    weight_preds <- data.frame(date = deaths$date, value = deaths$value) 
    weight_preds$value <- NA 
    for (ind in 1:length(deaths$date)){
        preds_ <- total_preds[ind,2:ncol(total_preds)] 
        errs <- total_errs[ind,2:ncol(total_errs)]
        vars <- total_vars[ind,2:ncol(total_vars)]
        actual <- deaths$value[ind]
        if ((sum(is.na(preds_)) == length(preds_)) || (sum(is.na(errs)) == length(errs)) || (sum(is.na(vars)) == length(vars))){
            next
        } else {
            pred <- weighted_pred(preds_, errs, vars, actual)
            weight_preds$value[ind] <- pred
        } 
    }
    model_name <- "Weighted Average"
    # Perform analysis on weighted average model
    c_analyse(deaths, weight_preds, model_name)

    return(analysis)
}
