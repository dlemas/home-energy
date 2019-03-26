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

url="https://emoncms.org/feed/data.json?"
full.url=paste0(url,api_key,"&id=208024&start=1553473942000&end=1553560342000&interval=60");full.url
req <- fromJSON(full.url)

# worked! Was not using unixtime_milliseconds

as.numeric(Sys.time()) * 1000



