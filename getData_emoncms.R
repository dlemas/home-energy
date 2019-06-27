##-------------- 
# **************************************************************************** #
# ***************                Project Overview              *************** #
# **************************************************************************** #

# Author:      Dominick Lemas 
# Date:        March 22, 2019 
# IRB:
# Description: Emoncms API system for emoncms project

# **************************************************************************** #
# ***************                Library                       *************** #
# **************************************************************************** #

# install.packages(c("httr", "jsonlite", "lubridate"))
library(keyringr)
library(httr)
library(dplyr)
library(lubridate)
#library(jsonlite)
library(RJSONIO)
#library(rjson)
# Load packages
#library(shiny)
#library(shinythemes)
options(scipen = 999)

# Get Emoncms API Token
# https://cran.r-project.org/web/packages/jsonlite/vignettes/json-apis.html
credential_label <- "emoncms_api"
credential_path <- paste(Sys.getenv("USERPROFILE"), '\\DPAPI\\passwords\\', Sys.info()["nodename"], '\\', credential_label, '.txt', sep="")
emoncms_token<-decrypt_dpapi_pw(credential_path)
print(emoncms_token)
api_key <-paste0("apikey=",emoncms_token)

# start date/time
start.time=as.POSIXct(strptime("2017-02-22 00:00:00", "%Y-%m-%d %H:%M:%S"))
start.time.ms=as.numeric(start.time)*1000 # 1485061200000
print(as.numeric(start.time)*1000, digits=15)

# stop date/time
stop.time=as.POSIXct(strptime("2017-02-23 00:00:00", "%Y-%m-%d %H:%M:%S"))
stop.time.ms=as.numeric(stop.time)*1000 # 1485147600000
print(as.numeric(stop.time.ms)*1000, digits=15)

# https://emoncms.org/site/api#feed

url="https://emoncms.org/feed/data.json?"
full.url=paste0(url,api_key,"&id=208024&start=",start.time.ms,"&end=",stop.time.ms,"&interval=3600");full.url
# power for week starting with first day of data.
# needs to be calibrated to calendar
req <- fromJSON(full.url)
df=as.data.frame(req)
df$date=as.Date(as.POSIXct(df$V1/1000, origin="1970-01-01"))

# ready for analysis.





