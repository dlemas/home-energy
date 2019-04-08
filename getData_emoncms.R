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
library(jsonlite)

# Get Emoncms API Token
# https://cran.r-project.org/web/packages/jsonlite/vignettes/json-apis.html
credential_label <- "emoncms_api"
credential_path <- paste(Sys.getenv("USERPROFILE"), '\\DPAPI\\passwords\\', Sys.info()["nodename"], '\\', credential_label, '.txt', sep="")
emoncms_token<-decrypt_dpapi_pw(credential_path)
print(emoncms_token)
api_key <-paste0("apikey=",emoncms_token)

# Last updated time and value for feed
url="https://emoncms.org/feed/timevalue.json?id=208024"
req <- fromJSON(paste0(url, api_key))

# start date
start.time=as.Date("01-18-2017", "%m-%d-%Y") # 1516237260000

url="https://emoncms.org/feed/data.json?"
full.url=paste0(url,api_key,"&id=208024&start=1516237260000&end=1554688346000&interval=604800");full.url
# power for week starting with first day of data.
# needs to be calibrated to calendar
req <- fromJSON(full.url)
df=as.data.frame(req)
df$date=as.Date(as.POSIXct(df$V1/1000, origin="1970-01-01"))

# ready for analysis.





