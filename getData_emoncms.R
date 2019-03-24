##-------------- 
# **************************************************************************** #
# ***************                Project Overview              *************** #
# **************************************************************************** #

# Author:      Dominick Lemas 
# Date:        March 22, 2019 
# IRB:
# Description: RedCap API system for emoncms project


# **************************************************************************** #
# ***************                Library                       *************** #
# **************************************************************************** #

# install.packages(c("httr", "jsonlite", "lubridate"))
library(keyringr)
library(httr)
library(lubridate)
library(jsonlite)

# Get Redcap API Token
# # https://cran.r-project.org/web/packages/keyringr/vignettes/Avoiding_plain_text_passwords_in_R_with_keyringr.html
credential_label <- "emoncms_api"
credential_path <- paste(Sys.getenv("USERPROFILE"), '\\DPAPI\\passwords\\', Sys.info()["nodename"], '\\', credential_label, '.txt', sep="")
emoncms_token<-decrypt_dpapi_pw(credential_path)
print(emoncms_token)

# https://www.r-bloggers.com/accessing-apis-from-r-and-a-little-r-programming/

# directory
url  <- "https://emoncms.org/feed/data.json"
raw.result <-GET(url= url, path=emoncms_token)
names(raw.result)
raw.result$status_code
raw.result$url



# Create connections
rcon <- redcapConnection(url=uri, token=beach_token)

# list of instruments
exportInstruments(rcon)

https://emoncms.org/feed/timevalue.json?id=208025
https://emoncms.org/feed/value.json?id=208025

# Returns feed data between start time and end time at 
#  the interval specified. If no data is present null 
# values are returned.
https://emoncms.org/feed/data.json?id=208025&start=1516147200&end=1553385600&interval=3600&apikey=emoncms_token
https://emoncms.org/feed/data.json?id=208025&start=1516147200&end=1516449600&interval=3600&apikey=


# Returns feed data between start time and end time at the 
# interval specified. Each datapoint is the average (mean) 
# for the period starting at the datapoint timestamp.
https://emoncms.org/feed/average.json?id=208025&start=1516147200&end=1553385600&interval=3600

# Returns feed datapoints at the start of each day 
# aligned to user timezone set in the user profile. This 
# is used by the bar graph and apps module to generate 
# kWh per day from cumulative kWh data.
https://emoncms.org/feed/data.json?id=208025&start=1516147200&end=1553385600&mode=daily&apikey=1703639b7af71c88a67aa5914e581bb9

https://emoncms.org/feed/data.json?id=208025