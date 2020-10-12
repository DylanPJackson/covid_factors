# Covid Factors
An Independent Study supervised by Dr. Homan at RIT to better anticipate
COVID-19 related deaths through an analysis of existing prediction models.

The general aim is to identify which features of various models are most
reliable for predicting changes in COVID-19 death rates. Thus, we analyse
the performance of various models, and identify during what time periods
these models performed the best in. In doing so, we can conclude which 
models were most reliable, thereby concluding which features are most reliable.

A much more in depth explanation full of research and discussion is updated 
on [this Overleaf](https://www.overleaf.com/read/jfwhdwprydxg).

Current graphs of various model performance is available in the
visualizations folder.

## Visualizations
Table of model name, error, dates of max and min error, and number of obversations
ordered by error
![sum\_tab](https://github.com/DylanPJackson/covid_factors/blob/master/visualizations/sum_tab.png)

## Why?
Over the summer, I was looking to start a new project. I was reading one of my
favorite news sites, FiveThirtyEight, and saw that they had created a dashboard
which highlighted various COVID-19 death prediction models. I found it useful
to have access to a summary of these models' recent predictions, but what I
realized would be really useful was some anaysis on which models were the most
accurate. 

The inspiration to potentially create some useful analysis led me to expand
this interest to an Independent Study with Professor Homan from the RIT CS
department. Under his instruction, I have shifted the focus of the project
towards answering several critical questions regarding these models, and how
they can help us plan for the future. Questions such as,
* What features do the most accurate models rely on? In other words, what are the most reliable data for identifying trends in COVID related deaths?
* When are the observed models in agreement / disagreement? By consequence, what times of the year are most / least predictable, and how global, national, and local events play into COVID related death trends
* What types of models are the most dependable given the current / expected state of the world?  

## How is your data stored? How are you working with it?
If you've looked in the data folder, you'll notice that I only have a .csv for
current US deaths. That is because the real data that I spend most of my time
working with is located [here](https://github.com/reichlab/covid19-forecast-hub/tree/master/data-processed),
under the Reich Lab's GitHub for processed prediction data for the models I observe.
I have a local copy of their GitHub on my machine, but I don't see a reason to
track it in this GitHub as well.

When figuring out how best to pre-process the data so I only work with what I
need, I normally just inspect some of the raw GitHub files, then transition to
messing around with it in the R interactive shell. Once I've identified what
formatting changes I need to do, I'll create a .R script to do all of the
pre-processing, analyzing, and visualizing. 

I'm working on identifying a way to create one generic script that can be run
against or include all of the models and their data. At the moment, there are
some differences in how certain models' data is formatted, so I will either
reformat all of the data into a uniform format, or adapt to these changes.
