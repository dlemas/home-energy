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

#' Description: Return the site power measurements in 15 minutes resolution.
#' Queries the solaredge API 
#' URL: /site/{siteId}/ power
#' 1 month between dates.
#' Example URL: https://monitoringapi.solaredge.com/site/1/power?startTime=2013-05-5%2011:00:00&endTime=2013-05-05%2013:00:00&api_key=L4QLVQ1LOKCQX2193VSEICXW61NP6B1O
#' Method: GET
#' Accepted formats: JSON, XML and CSV
#' Date format: mm-dd-yy
#' @return data.frame containing: unix-date/time, value (wat)

# start_date="05-05-2020"
# end_date="12-25-2020"

sitepower <- function(api_key, start_date, end_date){

  # https://mgimond.github.io/ES218/Week02c.html
  # https://cran.r-project.org/web/packages/jsonlite/jsonlite.pdf
  
  # date inputs
  tmp_start=ymd(start_date)
  tmp_end=ymd(end_date)
  
  # interval info
  # time.interval= tmp_start %--% tmp_end
  # time.duration <- as.duration(time.interval)
  # time.period <- as.period(time.interval)
  
  # batch
  batch_dates=seq(tmp_start,tmp_end, by = '1 month')
  date_interval<- interval(tmp_start,tmp_end)
  last_date=int_end(date_interval)
  batch_final=c(batch_dates,last_date)
  
  # loop  
  pages <- list()
  for(i in 1:length(batch_dates)){
    
    # url
    url="https://monitoringapi.solaredge.com/site/";url
    
    # API parameters
    site_ID="1219503/"
    param1="power?"
    
    # dates
    start.time=paste0("startTime=",batch_final[i],"%2000:00:00&")
    end.time=paste0("endTime=",batch_final[i+1],"%2000:00:00&")
    
    # data pull
    full.url=paste0(url,site_ID,param1,start.time,end.time,api_key);full.url # min
    power_tmp <- fromJSON(full.url)
    power=power_tmp$power$values %>%
      as.data.frame() 
    pages[[i]] <- power
    power_final=unlist(pages)
    
    } # end loop
  power_final=bind_rows(pages)
  
  } # end function

#' Description: Return the site power measurements in 15 minutes resolution.
#' Queries the solaredge API 
#' URL: /site/{siteId}/ power
#' 1 month between dates.
#' Example URL: https://monitoringapi.solaredge.com/site/1/power?startTime=2013-05-5%2011:00:00&endTime=2013-05-05%2013:00:00&api_key=L4QLVQ1LOKCQX2193VSEICXW61NP6B1O
#' Method: GET
#' Accepted formats: JSON, XML and CSV
#' Date format: mm-dd-yy
#' @return data.frame containing: unix-date/time, value (wat)

# start_date="2020-08-20 23:45:00"
# end_date=today()

update_sitepower <- function(api_key, start_date, end_date){
  
  # https://mgimond.github.io/ES218/Week02c.html
  # https://cran.r-project.org/web/packages/jsonlite/jsonlite.pdf
  
  # date inputs
  tmp_start=ymd_hms(start_date)
  tmp_end=as.POSIXct(end_date)
  
  # interval info
  # time.interval= tmp_start %--% tmp_end
  # time.duration <- as.duration(time.interval)
  # time.period <- as.period(time.interval)
  
  # batch
  batch_dates=seq(tmp_start,tmp_end, by = '1 month')
  date_interval<- interval(tmp_start,tmp_end)
  last_date=int_end(date_interval)
  batch_final=c(batch_dates,last_date)
  
  # loop  
  pages <- list()
  for(i in 1:length(batch_dates)){
    
    # url
    url="https://monitoringapi.solaredge.com/site/";url
    
    # API parameters
    site_ID="1219503/"
    param1="power?"
    
    # need to parse the time into URL
    
    # dates
    start.time=paste0("startTime=",batch_final[i],"%2000:00:00&")
    end.time=paste0("endTime=",batch_final[i+1],"%2000:00:00&")
    
    # data pull
    full.url=paste0(url,site_ID,param1,start.time,end.time,api_key);full.url # min
    power_tmp <- fromJSON(full.url)
    power=power_tmp$power$values %>%
      as.data.frame() 
    pages[[i]] <- power
    power_final=unlist(pages)
    
  } # end loop
  power_final=bind_rows(pages)
  
} # end function


#' Description: Display the site overview data.
#' Queries the solaredge API 
#' URL: /site/{siteId}/ overview
#' Example URL: https://monitoringapi.solaredge.com/ site/{siteId}/overview?api_key=L4QLVQ1LOKCQX2193VSEICXW61NP6B1O
#' Method: GET
#' Accepted formats: JSON and XML 
#' @return data.frame containing: unix-date/time, value (wat)
siteoverview <- function(api_key){

  # url
  url="https://monitoringapi.solaredge.com/site/";url

  # API parameters
  site_ID="1219503/"
  param1="overview?"

  # data pull
  full.url=paste0(url,site_ID,param1,api_key);full.url # min
  overview <- fromJSON(full.url)%>%
    as.data.frame() 
  
} # end function