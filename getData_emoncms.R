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

bcl <- read.csv("bcl-data.csv", stringsAsFactors = FALSE)


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
start.time=as.POSIXct(strptime("2018-01-17 00:00:00", "%Y-%m-%d %H:%M:%S"))
start.time.ms=as.numeric(start.time)*1000 

# stop date/time
stop.time=Sys.time()
# stop.time=as.POSIXct(stop.time)
# stop.time=as.POSIXct(strptime("2018-06-01 00:00:00", "%Y-%m-%d %H:%M:%S"))
stop.time.ms=as.numeric(stop.time)*1000 

# days list
date.seq=seq(start.time, stop.time, by="days")
date.list=as.Date(date.seq,format ="%m/%d/%y")
index=length(date.list)

# Start the Loop
days<- list()
for (i in 1:(index))  # issue with 40th date. missing data?
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
  mydata=req %>% as.data.frame()

  # add to list
  days[[i]] <- mydata
}

#combine all into one
days_flat <- rbind_pages(days)

# output files
data.file.name="kwh.csv";data.file.name
data.dir=paste0(Sys.getenv("USERPROFILE"),"\\Dropbox (UFL)\\02_Projects\\EMONCMS\\data\\");data.dir
data.file.path=paste0(data.dir,data.file.name);data.file.path

# format data
house_kwh=days_flat %>%
mutate(date_hms=as.POSIXct(V1/1000, origin="1970-01-01")) %>%
rename(kwh=V2, time_unix=V1) %>%
write.csv(.,file=data.file.path,row.names=F)

