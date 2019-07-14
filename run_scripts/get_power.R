# load packages
library(knitr)
library(markdown)
library(rmarkdown)

# directories
analysis.dir=paste0(Sys.getenv("USERPROFILE"),"\\Documents\\GitHub\\emoncms\\reports\\")
out.dir=paste0(Sys.getenv("USERPROFILE"),"\\Dropbox (UFL)\\02_Projects\\EMONCMS\\reports\\")

# execute report
rmarkdown::render(paste0(analysis.dir,"get_power_data.Rmd"),  # file 2
                  output_file =  paste0("report_", Sys.Date(), ".html"), 
                  output_dir = out.dir)