
# Home Power Integration

This is a program to intergrate power consumption and solar power generation. 

Key functions
- sitepower()- total solar power for system b/w dates.



=======
### Overview

	project
	|
	|- code/          # any programmatic code	
	|
	|- data/          # raw and processed and analysis data, are not changed once created
	| |- analysis/    # analysis data derived from cleaned data
	| |- processed/   # cleaned data derived from raw data
	| |- raw/         # raw data
	|                 
	|- exploratory/   # exploratory data analysis for study
	| |- notebook/    # preliminary analyses
	| +- scratch/     # temporary files that can be safely deleted or lost
	|
	|- presentation/  # powerpoint related to project 	
  |
	|- results        # all output from workflows and analyses
	| |- tables/      # text version of tables to be rendered with kable in R
	| |- figures/     # graphs, likely designated for manuscript figures
	| +- pictures/    # diagrams, images, and other non-graph graphics
	|
	|- CONTRIBUTING   # instructions for how to contribute to this project
	|- INSTRUCTIONS   # instructions for how to get started with with github
	|- LICENSE        # the license for this project
	|- README         # the top level description of content (this doc)

### How to regenerate this repository

#### Dependencies and locations
* Gnu Make should be located in the user's PATH
* mothur (v1.XX.0) should be located in the user's PATH
* R (v. 3.X.X) should be located in the user's PATH
* R packages:
  * `knitr`
  * `rmarkdown`
* etc


#### Running analysis

```
git clone https://github.com/SchlossLab/LastName_BriefDescription_Journal_Year.git
make write.paper
```

## References
- Based on [tutorial](https://rviews.rstudio.com/2017/11/15/shiny-and-scheduled-data-r/)


