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
source("preds.R")
source("us_deaths.R")
source("clean_analyse.R")

analyse <- function(models= c("LANL-GrowthRate", "MOBS-GLEAM_COVID",
                    "UMass-MechBayes", "YYG-ParamSearch", "COVIDhub-ensemble",
                    "UCLA-SuEIR", "IowaStateLW-STEM", "MITCovAlliance-SIR", 
                    "JHU_IDD-CovidSP", "USACE-ERDC_SEIR", "IHME-CurveFit",
                    "UA-EpiCovDA", "UT-Mobility")){
    # Initialize analysis dataframe 
    analysis <- data.frame(name = character(), mse = numeric(),
                            max_error_date = numeric(), 
                            min_error_date= numeric(), num_preds = numeric())

    # Get current death truth data
    deaths <- us_deaths()
     
    # Perform analysis on each of the models
    for (model in models){
        # Get predictions for each model
        predictions <- preds(model) 
        # Get statistics from predictions. This call also produces plots
        stats <- c_analyse(deaths, predictions, model) 
        new_row <- data.frame(name = model, mse = stats[[1]], 
                    max_error_date = stats[[2]], min_error_date = stats[[3]],
                    num_preds = stats[[4]]) 
        # Add each model's statistics to summary analysis
        analysis <- rbind(analysis, new_row)
    }
    
    # Generate summary table
    png("../visualizations/sum_tab.png", height = 720, width = 720)
    g <- tableGrob(analysis, rows = NULL)
    g <- gtable_add_grob(g,
            grobs = rectGrob(gp = gpar(fill = NA, lwd = 2)),
            t = 2, b = nrow(g), l = 1, r = ncol(g))
    g <- gtable_add_grob(g,
            grobs = rectGrob(gp = gpar(fill = NA, lwd = 2)),
            t = 1, l = 1, r = ncol(g))
    grid.draw(g)
    dev.off()

    return(analysis)
}
