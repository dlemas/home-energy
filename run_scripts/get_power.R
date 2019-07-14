library(ezknitr)
analysis.dir=paste0(Sys.getenv("USERPROFILE"),"\\Documents\\GitHub\\emoncms\\")
out.dir=paste0(Sys.getenv("USERPROFILE"),"\\Dropbox (UFL)\\02_Projects\\EMONCMS\\")
ezknit(file="get_power_data.Rmd", out_dir=paste0(out.dir,"reports"))

