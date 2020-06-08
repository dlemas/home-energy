#' Get RedCap API Token
#' @return api token
get_API_token <- function(credential_label){
  # Get Emoncms API Token
  #credential_label <- "emoncms_api"
  credential_path <- paste(Sys.getenv("USERPROFILE"), '\\DPAPI\\passwords\\', Sys.info()["nodename"], '\\', credential_label, '.txt', sep="")
  emoncms_token<-decrypt_dpapi_pw(credential_path)
  api_key <-paste0("apikey=",emoncms_token)
  return(api_key)
}

#' Get Home Power Data
#' Queries the emoncms API to get home power (wats)
#' every 60 seconds from start time to present
#' https://emoncms.org/site/api#feed
#' @return data.frame containing: unix-time, wat, date-time
getKWData <- function(api_key, start_date, seconds){

    # dates
    start.time=as.POSIXct(strptime(start_date, "%Y-%m-%d"))
    stop.time=Sys.time()
    date.seq=seq(start.time, stop.time, by="days")
    date_hms=date.seq
  
    # days index
    index=length(date_hms)
  
    # Start the Loop
    days<- list()
    for (i in 1:(index))  # issue with 40th date. missing data?
        {
            # start date
            start=ymd(date_hms[i])
            start_hms=paste0(start," 00:00:00")
            start.time=as.POSIXct(strptime(start_hms, "%Y-%m-%d %H:%M:%S"))
            start.unix=as.numeric(start.time)*1000 
            
            # end date
            end=ymd(start) + days(1)
            end_hms=paste0(end," 00:00:00")
            end.time=as.POSIXct(strptime(end_hms, "%Y-%m-%d %H:%M:%S"))
            end.unix=as.numeric(end.time)*1000 
    
            # emoncms url
            url="https://emoncms.org/feed/data.json?";url
            full.url=paste0(url,api_key,"&id=208025&start=",start.unix,"&end=",end.unix,"&mode=",seconds);full.url # min
    
           # https://www.emoncms.org/feed/data.json?id=0&start=UNIXTIME_MILLISECONDS&end=UNIXTIME_MILLISECONDS&mode=daily
            
            
            # pull data
            req <- fromJSON(full.url)
            mydata=req %>% as.data.frame()
    
            # add to list
            days[[i]] <- mydata
          }
  
      #combine all into one
      days_flat <- rbind_pages(days)
  
      # format data
      power=days_flat %>%
      mutate(date_hms=as.POSIXct(V1/1000, origin="1970-01-01")) %>%
      rename(kwh=V2, time_unix=V1) 
}

#' Update Home Power Data
#' Queries the emoncms API to UPDATE home power (wats)
#' every 60 seconds from start time to present
#' https://emoncms.org/site/api#feed
#' @return data.frame containing: unix-time, wat, date-time
updateKWData <- function(api_key, power){
  
  # start date/time
  start.time=last(power$date_hms)+30
  start.unix=as.numeric(start.time)*1000 
  
  # end date/time
  stop.time=Sys.time()
  end.unix=as.numeric(stop.time)*1000 
  
  # emoncms url
  url="https://emoncms.org/feed/data.json?";url
  full.url=paste0(url,api_key,"&id=208024&start=",start.unix,"&end=",end.unix,"&interval=10");full.url # min
  
  # pull data
  power_new <- fromJSON(full.url) %>%
  as.data.frame() %>%
  mutate(date_hms=as.POSIXct(V1/1000, origin="1970-01-01")) %>%
  rename(kwh=V2, time_unix=V1) 

# combine with old data
power_update <-rbind(power,power_new)

}