# filename
#       total_summary.R
#
# description
#       Given a list of model names, and analyses, perform the requested
#       analyses on each of the models
#
# author
#       Dylan P. Jackson

## TODO ===================
# Get all model names
# Get all analysis types
# Load in all of the files for each dataset into a dataframe 
#       (basically a df of df)
# Get predictions for each model 
# Plot individual predictions if requested
# Get deaths
# Plot individual comparisons if requested
# Perform mse if requested
# Get best date if requestd
# Get worst date if requested
# Display all data requested for table
# Display all models predictions on one grpah if requested

library(gridExtra)
library(grid)

analyse <- function(models= c("LANL-GrowthRate", "MOBS_GLEAM_COVID",
                    "UMass-MechBayes", "YYG-ParamSearch", "COVIDhub-ensemble",
                    "UCLA-SuEIR", "IowaStateLW-STEM", "MITCovAlliance-SIR", 
                    "JHU_IDD-CovidSP", "USACE-ERDC_SEIR", "IHME-CurveFit",
                    "UA-EpiCovDA", "UT-Mobility")){
    # Initialize analysis dataframe 
    analysis <- data.frame(name = character(), mse = numeric(),
                            max_error_d = numeric(), min_error_d = numeric(),
                            num_obs = numeric())
     
    grid.table(analysis, rows = NULL) 
    return (max_error_d)
}
