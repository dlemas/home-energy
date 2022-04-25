#' Get RedCap API Token
#' @return api token
get_API_token <- function(credential_label){
  # Get Emoncms API Token
  credential_path <- paste(Sys.getenv("USERPROFILE"), '\\DPAPI\\passwords\\', Sys.info()["nodename"], '\\', credential_label, '.txt', sep="")
  token<-decrypt_dpapi_pw(credential_path)
  #api_key <-paste0("api_key=",emoncms_token)
  return(token)
}

#' Get Home Power Data
#' Queries the emoncms API to get home power (wats)
#' every 60 seconds from start time to present
#' https://emoncms.org/site/api#feed
#' @return data.frame containing: unix-time, wat, date-time
getKWData <- function(api_key, start_date, seconds){
  
  # troubleshoot
  # (api_key, "2019-07-01", 40)
  # start.time=ymd(c("2022-04-01"))
  # stop.time=ymd(c("2022-04-03"))

  # dates
  start.time=as.POSIXct(strptime(start_date, "%Y-%m-%d"))
  stop.time=Sys.Date() 
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
    # url="https://emoncms.org/feed/average.json?";url
    
    full.url=paste0(url,KEY,"&id=208025&start=",start.unix,"&end=",end.unix,"&mode=",seconds);full.url # min
    # full.url=paste0(url,KEY,"&id=208025&start=",start.unix,"&end=",end.unix,"&mode=daily");full.url # min
    # full.url=paste0(url,KEY,"&id=208025&start=",start.unix,"&end=",end.unix,"&interval=900");full.url # min
    

    # https://www.emoncms.org/feed/data.json?id=0&start=UNIXTIME_MILLISECONDS&end=UNIXTIME_MILLISECONDS&mode=daily
    
    
    # pull data
    pull <- fromJSON(full.url)
    mydata=pull %>% as.data.frame() %>%
      mutate(tmp=V1)
    
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