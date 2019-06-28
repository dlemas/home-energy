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
start.time=as.POSIXct(strptime("2018-01-01 00:00:00", "%Y-%m-%d %H:%M:%S"))
start.time.ms=as.numeric(start.time)*1000 

# stop date/time
stop.time=as.POSIXct(strptime("2019-06-01 00:00:00", "%Y-%m-%d %H:%M:%S"))
stop.time.ms=as.numeric(stop.time)*1000 

# pull data: interval in seconds
url="https://emoncms.org/feed/data.json?";url
# full.url=paste0(url,api_key,"&id=208024&start=",start.time.ms,"&end=",stop.time.ms,"&interval=604800");full.url
# full.url=paste0(url,api_key,"&id=208024&start=",start.time.ms,"&end=",stop.time.ms,"&mode=daily");full.url
full.url=paste0(url,api_key,"&id=208024&start=",start.time.ms,"&end=",stop.time.ms,"&mode=daily");full.url # daily

# pull data
req <- fromJSON(full.url)
# count datapoints: most likely need to batch b/c files are large
# datapoints=as.numeric(str_split(req$message, "=")[[1]][2])

# format
df1=req %>% as.data.frame() %>%
  mutate(date=as.Date(as.POSIXct(V1/1000, origin="1970-01-01"))) %>%
  rename(KWh=V2)
names(df1)
str(df1)
plot(df1$date,df1$KWh)
