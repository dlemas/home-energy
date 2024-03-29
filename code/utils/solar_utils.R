
#' Description: Return the site power measurements in 15 minutes resolution.
#' Queries the solaredge API 
#' URL: /site/{siteId}/ power
#' 1 month between dates.
#' Example URL: https://monitoringapi.solaredge.com/site/1/power?startTime=2013-05-5%2011:00:00&endTime=2013-05-05%2013:00:00&api_key=L4QLVQ1LOKCQX2193VSEICXW61NP6B1O
#' Method: GET
#' Accepted formats: JSON, XML and CSV
#' Date format: mm-dd-yy
#' @return data.frame containing: unix-date/time, value (wat)

# start_date='20-05-05'
# end_date='20-12-25'

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
  #power_final$type="solar"
  #power_final$units="wh"
  
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