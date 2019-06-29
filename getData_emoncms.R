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
library(tidyverse)
#library(RJSONIO)
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

# https://emoncms.org/site/api#feed

# start date/time
start.time=as.POSIXct(strptime("2018-02-01 00:00:00", "%Y-%m-%d %H:%M:%S"))
start.time.ms=as.numeric(start.time)*1000 

# stop date/time
stop.time=as.POSIXct(strptime("2019-06-01 00:00:00", "%Y-%m-%d %H:%M:%S"))
stop.time.ms=as.numeric(stop.time)*1000 

# loop through days
# time.interval <- start.time %--% stop.time
# time.duration <- as.duration(time.interval)
# days_between=round(as.numeric(time.duration)/86400,0) # seconds in day

date.list=seq(start.time, stop.time, by="days")
index=length(date.list)

# Start the Loop
days<- list()
for (i in 1:(index))
{
  # dates to pull data b/w
  start=ymd(date.list[i])
  end=ymd(start) + days(1)
  
  # unixmillisec
  start_hms=paste0(start," 00:00:00")
  start.time=as.POSIXct(strptime(start_hms, "%Y-%m-%d %H:%M:%S"))
  start.unix=as.numeric(start.time)*1000 
  
  end_hms=paste0(end," 00:00:00")
  end.time=as.POSIXct(strptime(end_hms, "%Y-%m-%d %H:%M:%S"))
  end.unix=as.numeric(end.time)*1000 
  
  # emoncms url
  url="https://emoncms.org/feed/data.json?";url
  full.url=paste0(url,api_key,"&id=208024&start=",start.unix,"&end=",end.unix,"&interval=60");full.url # min

  # pull data
  req <- fromJSON(full.url)
  
  # format data
  mydata=req %>% as.data.frame() %>%
  mutate(date_hms=as.POSIXct(V1/1000, origin="1970-01-01")) %>%
  rename(KWh=V2, time_unix=V1)
  
  # add to list
  days[[i+1]] <- mydata
}

#combine all into one
house_kwh <- rbind_pages(days)
  
  






# emoncms url
url="https://emoncms.org/feed/data.json?";url
# full.url=paste0(url,api_key,"&id=208024&start=",start.time.ms,"&end=",stop.time.ms,"&interval=43200");full.url
# full.url=paste0(url,api_key,"&id=208024&start=",start.time.ms,"&end=",stop.time.ms,"&mode=daily");full.url
full.url=paste0(url,api_key,"&id=208024&start=",start.time.ms,"&end=",stop.time.ms,"&interval=43200");full.url # daily
full.url=paste0(url,api_key,"&id=208024&start=",start.time.ms,"&end=",stop.time.ms,"&interval=60");full.url # daily

