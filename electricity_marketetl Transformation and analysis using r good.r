# this just removes everything from memory
rm(list=ls(all=T)) 

########################## ETL in R###################################################################

# Extract and load the last few days of eclectricity data from the
## original websigh path as below
#http://mis.nyiso.com/public/csv/pal/20240312pal.csv

load_url<-'http://mis.nyiso.com/public/csv/pal/'


# NYISO has up to 10 days of data so want to write a program
# that will autmatically extract the last 10 files/dates
days_back<-10;

# reverse sequence of dates 10 days back
dates<-seq(Sys.Date(),Sys.Date()-days_back+1,-1) 

#load the the rest of the base url to date part of the url and stiping all the spaces and hypens 
load_urls<-paste(load_url,gsub('-','',dates),'pal.csv',sep='') #urls to process

# I could easily create a single csv (rbind) and manually import it to a db
# But I wanted to be able to frequently extract and load new data!
# Each time you run this code, it should load the last few days to your db

# For each loaded file, we will insert each record to the db - SLOW (no bulk)

# Open connection first
require(RPostgres) # did you install this package?
equire(DBI)
# Did you create the user in pgAdmin?
conn <- dbConnect(RPostgres::Postgres()
                  ,user="electricitymarketwriter3"
                  ,password="write123"
                  ,host="localhost"
                  ,port=5432
                  ,dbname="electricitymaket3")
### For lupe to interate through each file on the base webpage and extracting the csv

for(url in load_urls){
  #url<-load_urls[1]  this is so you can check your url
  t0<-Sys.time()
  load_csv<-na.omit(read.csv(file=url))
  #load_csv$Time.Stamp<-as.character(as.POSIXct(load_csv$Time.Stamp,format="%m/%d/%Y %H:%M:%S"))
  cat("Processing",url,"...")
  
  
  #### then take the extracted files and load them into the database i created in postgress electricity market2
  for(k in 1:nrow(load_csv)){
    #k<-1
    stm<-paste(
      'INSERT INTO load VALUES ('
      ,"'",load_csv$Time.Stamp[k],"',"
      ,"'",load_csv$Time.Zone[k],"',"
      ,"'",load_csv$Name[k],"',"
      ,load_csv$PTID[k],","
      #,load_csv$Load[k],");"
      ,load_csv$Load[k],") ON CONFLICT (time_stamp, time_zone, ptid) DO NOTHING;"
      ,sep=""
    )
    
    result<-dbSendQuery(conn,stm) # you can inspect the results here
    
    #dbGetQuery(conn,stm)
  } # of for(k)
  t1<-Sys.time()
  cat('done after',(t1-t0),'s.\n')
  

  } # of for(url)

# Close db connection
dbDisconnect(conn)
warning()

# Extract and Load Historical Data ----------------------------------------------------

# Set this to T if you want the monthly process to run
run.monthly<-F

# This is for previous months (zipped)
https://mis.nyiso.com/public/csv/pal/20241001pal_csv.zip

# We can use a similar approach (for each file for each row - INSERT)
# but we also have zip files so we will need to store extracted files somewhere
out_path<-'C:/Temp/NYISO'

## number of month out by 5 so 5 ahead

months<-seq(as.Date("2023-12-01"), by = "month", length.out = 3)
#I want five behind so I have to reverse the five ahead
months<-rev(months)

# We can use a similar approach (for each file for each row - INSERT)
# but we also have zip files so we will need to store extracted files somewhere
out_path<-'C:/Temp/NYISO'

#months<-seq(as.Date("2021-08-01"), by = "month", length.out = 15)
#months<-rev(months)
zipped_load_urls<-paste(load_url,gsub('-','',months),'pal_csv.zip',sep='') #urls to process
http://mis.nyiso.com/public/csv/pal/20241101pal_csv.zip



#urls to process for arcive with zip files and to load in db

#zipped_load_urls<-paste(load_url,gsub('-','',months),"C:\temp\NYISO\Unconfirmed 355689.crdownload",sep='')
 #Open connection
require(RPostgres) # did you install this package?
require(DBI)
# Did you create the user in pgAdmin?
conn <- dbConnect(RPostgres::Postgres()
                  ,user="electricitymarketwriter"
                  ,password="write123"
                  ,host="localhost"
                  ,port=5432
                  ,dbname="Electricitymarket"
)
#"C:\temp\NYISO\Unconfirmed 355689.crdownload"


for(zipped_url in zipped_load_urls){
  if(!run.monthly) break()
  #zipped_url<-zipped_load_urls[1]
  temp_file<-paste(out_path,'/temp.zip',sep="")
  download.file(zipped_url,temp_file) # download archive to a temp file
  unzip(zipfile = temp_file, exdir = out_path) #extract from archive
  file.remove(temp_file) # delete temp file
  
  csvs<-rev(list.files(out_path,full.names = T))
  
  for(csv in csvs){
    #csv<-csvs[1]
    load_csv<-na.omit(read.csv(file=csv))
    #load_csv$Time.Stamp<-as.character(as.POSIXct(load_csv$Time.Stamp,format="%m/%d/%Y %H:%M:%S"))
    
    cat("Processing",csv,"...")
    t0<-Sys.time()
    for(k in 1:nrow(load_csv)){
      #k<-1
      stm<-paste(
        'INSERT INTO load VALUES ('
        ,"'",load_csv$Time.Stamp[k],"',"
        ,"'",load_csv$Time.Zone[k],"',"
        ,"'",load_csv$Name[k],"',"
        ,load_csv$PTID[k],","
        #,load_csv$Load[k],");"
        ,load_csv$Load[k],") ON CONFLICT (time_stamp, time_zone, ptid) DO NOTHING;"
        ,sep=""
      )
      
      result<-dbSendQuery(conn,stm) # you can inspect the results here
      
      #dbGetQuery(conn,stm)
    } # of for(k)
    t1<-Sys.time()
    file.remove(csv)
    cat('done after',(t1-t0),'s.\n')
    
  } # of for(csv)
  
} # of for(url)

 

for(zipped_url in zipped_load_urls){
  if(!run.monthly) break()
  #zipped_url<-zipped_load_urls[1]
  temp_file<-paste(out_path,"\temp.zip",sep=)
  download.file(zipped_url,temp_file) # download archive to a temp file
  unzip(zipfile = temp_file, exdir = out_path) #extract from archive
  file.remove(temp_file) # delete temp file
  
  csvs<-rev(list.files(out_path,full.names = T))
  
  for(csv in csvs){
    csv<-csvs[1]
    load_csv<-na.omit(read.csv(file=csv))
    #load_csv$Time.Stamp<-as.character(as.POSIXct(load_csv$Time.Stamp,format="%m/%d/%Y %H:%M:%S"))
    
    cat("Processing",csv,"...")
    t0<-Sys.time()
    for(k in 1:nrow(load_csv)){
      #k<-1
      stm<-paste(
        'INSERT INTO load VALUES ('
        ,"'",load_csv$Time.Stamp[k],"',"
        ,"'",load_csv$Time.Zone[k],"',"
        ,"'",load_csv$Name[k],"',"
        ,load_csv$PTID[k],","
        #,load_csv$Load[k],");"
        ,load_csv$Load[k],") ON CONFLICT (time_stamp, time_zone, ptid) DO NOTHING;"
        ,sep=""
      )
      
      result<-dbSendQuery(conn,stm) # you can inspect the results here
      
      #dbGetQuery(conn,stm)
    } # of for(k)
    t1<-Sys.time()
    file.remove(csv)
    cat('done after',(t1-t0),'s.\n')
    
  } # of for(csv)
  
} # of for(url)

# Close db connection
dbDisconnect(conn)

# Restore point for the database electricitymarket2.backup

# Forecast average hourly load for the next 24 hours ----------------------

# We will now use the data extracted transformed and loaded from NYISO
# We will consider hourly average of total (all zones) load for a time range

# set up time range
from_dt<-'2024-03-01 00:00:00'
to_dt<-'2024-03-30 23:59:59'

#build a a query load the data into the database table I created

qry<-paste(
  "SELECT date_trunc('hour',time_stamp) as ymdh, AVG(total_load) as avg_load
  FROM 
  (SELECT time_stamp, time_zone, SUM(load) as total_load
    FROM load",
  " WHERE time_stamp BETWEEN '",from_dt,"' AND '",to_dt,"'",
  " GROUP BY time_stamp, time_zone) TL
  GROUP BY date_trunc('hour',time_stamp)
  ORDER BY ymdh;",sep=""
)

#retrieve from db (we will use the writer role to read - it has all rights)

# Open connection
require(RPostgres) # did you install this package?
require(DBI)
# Did you create the user in pgAdmin?
conn <- dbConnect(RPostgres::Postgres()
                  ,user="electricitymarketwriter"
                  ,password="write123"
                  ,host="localhost"
                  ,port=5432
                  ,dbname="Electricitymarket"
)

hrly_load<-dbGetQuery(conn,qry) #retrieve data

dbDisconnect(conn) # close connection
#check
head(hrly_load)
tail(hrly_load)
nrow(hrly_load)

#make univariate
rownames(hrly_load)<-format(hrly_load$ymdh,"%F %T") # formatting added for R 4.3
hrly_load$ymdh<-NULL

#check
head(hrly_load)

library(forecast)


#very basic plot the last 7 days (24*7 hours)
plot(tail(hrly_load$avg_load,24*7),type='l')

#make it a time series object
require(xts)
hrly_load.xts<-as.xts(hrly_load)

#better plot
require(ggplot2) # Did you install this package?
ggplot(hrly_load.xts, aes(x = Index, y = avg_load)) + geom_line()

#smart solution (use PerformanceAnalytics)
require(PerformanceAnalytics)
chart.TimeSeries(hrly_load.xts)

#MAY NOT WORK: interactive time-series plot
require(dygraphs) 
dygraph(hrly_load.xts)

#forecast the next 24 hours (the "old" way)
require(forecast) #did you install this package?

#use a powerful technique (automatic arima) to fit model
aa<-auto.arima(hrly_load.xts,stepwise = F)
summary(aa)

#forecast
fcst<-forecast(aa,24)
plot(fcst)

#Better plot - 95pct intervals
require(dygraphs)
fcst.95pct<-as.data.frame(fcst)[,c('Lo 95','Point Forecast','Hi 95')]
#but we need hours (with possible time change)
last.date<-tail(rownames(hrly_load),1)

fcst.hours<-tail(seq(from=as.POSIXct(last.date, tz="America/New_York"), 
    to=as.POSIXct(last.date, tz="America/New_York")+3600*24, by="hour"),-1)

#check
head(fcst.hours)
tail(fcst.hours)
length(fcst.hours)

#just plot the forecast
rownames(fcst.95pct)<-fcst.hours
dygraph(fcst.95pct) %>%
  dySeries(c('Lo 95','Point Forecast','Hi 95'))

#MAY NOT WORK: plot everything (interactive)
fake.fcst.95pct<-as.data.frame(hrly_load)
fake.fcst.95pct$`Lo 95`<-hrly_load$avg_load
fake.fcst.95pct$`Hi 95`<-hrly_load$avg_load
fake.fcst.95pct<-fake.fcst.95pct[,c('Lo 95','avg_load','Hi 95')]
colnames(fcst.95pct)<-c('Lo 95','avg_load','Hi 95')

#bind and plot
dygraph(rbind(fake.fcst.95pct,fcst.95pct)) %>%
  dySeries(c('Lo 95','avg_load','Hi 95'))



#load the historical data for the day following the last day

new_from_dt<-as.character(as.POSIXct(to_dt)+1)
new_to_dt<-as.character(as.POSIXct(to_dt)+60*60*24)

new_qry<-paste(
  "SELECT date_trunc('hour',time_stamp) as ymdh, AVG(total_load) as avg_load
  FROM 
  (SELECT time_stamp, time_zone, SUM(load) as total_load
    FROM load",
  " WHERE time_stamp BETWEEN '",new_from_dt,"' AND '",new_to_dt,"'",
  " GROUP BY time_stamp, time_zone) TL
  GROUP BY date_trunc('hour',time_stamp)
  ORDER BY ymdh;",sep=""
)

conn <- dbConnect(RPostgres::Postgres()
                  ,user="electricitymarketwriter"
                  ,password="write123"
                  ,host="localhost"
                  ,port=5432
                  ,dbname="Electricitymarket"
)

new_hrly_load<-dbGetQuery(conn,new_qry) #retrieve data
rownames(new_hrly_load)<-format(new_hrly_load$ymdh,"%F %T") # formatting added for R 4.4
new_hrly_load$ymdh<-NULL

dbDisconnect(conn) # close connection
#check
head(new_hrly_load)
plot(new_hrly_load$avg_load)

#accuracy
accuracy<-new_hrly_load
accuracy$fcst<-fcst$mean[1:nrow(accuracy)] # mean is the actual forecast

head(accuracy)

#what is the mean absolute error (MAE) in MW?
accuracy$E<-accuracy$avg_load-accuracy$fcst
accuracy$AE<-abs(accuracy$E)
mae<-mean(accuracy$AE)
mae
#how about mean absolute percentage error (MAPE)?
accuracy$PE<-accuracy$E/accuracy$avg_load
accuracy$APE<-abs(accuracy$PE)
mape<-mean(accuracy$APE)
mape
# plot
require(PerformanceAnalytics)
chart.TimeSeries(accuracy[,c('avg_load','fcst')],legend.loc='bottomright')
chart.TimeSeries(accuracy[,c('E'),drop=F],legend.loc='bottomright')


# The new (and better) way to deal with ts forecasting
require(plyr) # did you install this package?
require(tsibble) # did you install this package?
# If you get an rlang version error, close this file, restart R session, remove the rlang package and reinstall it. SAY "no" IF RSTUDIO ASKS TO RESTART R SESSION AGAIN. 
# If you get a vctrs version error, close this file,restart R session, remove the vcrs package and reinstall it. SAY "no" IF RSTUDIO ASKS TO RESTART R SESSION AGAIN.  
hrly_load_complete<- rbind(hrly_load,new_hrly_load)
head(hrly_load_complete)
hrly_load_complete$ymdh<-as.POSIXct(row.names(hrly_load_complete)) #add it back but as date/time
hrly_load_complete %>% as_tsibble(index=ymdh) -> hrly_load.tsibble

library(feasts)  #did you install this package?
hrly_load.tsibble %>% autoplot(avg_load)

# is the series stationary?
# perform the KPSS test (we want p-value>0.05)
hrly_load.tsibble %>% features(avg_load, unitroot_kpss)
# let's try some differencing
hrly_load.tsibble %>% autoplot(difference(avg_load,24))
hrly_load.tsibble %>% autoplot(difference(difference(avg_load,24),1))
# much better - re-check with KPSS (no piping this time)
unitroot_kpss(difference(difference(hrly_load.tsibble$avg_load,24),1))

# withhold the last day
train <- hrly_load.tsibble %>% filter_index(. ~ as.character(as.Date(new_to_dt)-1))
tail(train)

# autofit ARIMA
require(fable)  #did you install this package?
fit <- train  %>% model(ARIMA(avg_load,stepwise = F,approximation =T ))
# you can try without approximation - it will take much longer
gg_tsresiduals(fit) # is is a good fit?

# Let's perform a portmanteau (Ljung-Box) test to check
# Ha: The data are not independently distributed; they exhibit serial correlation.
## Note: suggested lag=10 for non-seasonal
# Note: dof=K where K is the number of parameters estimated by the model (in this case K=P+Q+p+q)
augment(fit) %>%
  features(.innov, ljung_box, lag = 10, dof = 5)
# A large p-value (>0.05) means that there is not enough evidence to support Ha - this is good for the foreacast
# So, it passes as white noise based on the Ljung-Box test

glance(fit)

fit %>%
  forecast(h = "24 hours") %>%
  accuracy(hrly_load.tsibble)


# plot the entire range with forecast
require(ggplot2)
fit %>% forecast(h=24) %>%
  autoplot(train) +
  labs(x="", y = "Hrly load", title = "Load Forecast")

# just the last day
fit %>%
  forecast(h="24 hours") %>%
  autoplot(hrly_load.tsibble %>% filter_index(as.character(as.Date(new_to_dt)) ~ as.character(as.Date(new_to_dt))))


# even the best model has an average percentage error of 16% so they are not that great but hourly data has complex seasonality which I could improve this result if I had more time,
# mabe a composition arima with harmonics, or est 
