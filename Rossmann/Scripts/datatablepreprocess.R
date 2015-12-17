setwd("~/Documents/Machine Learning/Kaggle/Rossman")
# Based on Ben Hamner script from Springleaf
# https://www.kaggle.com/benhamner/springleaf-marketing-response/random-forest-example

library(data.table)
library(readr)
library(xgboost)
library(ggplot2)
library(stringi)

cat("reading the train and test data\n")
train <- fread("./input/train.csv", stringsAsFactors = T)
test  <- fread("./input/test.csv", stringsAsFactors = T)
store <- fread("./input/store.csv", stringsAsFactors = T)

train[,Date:=as.Date(Date)]
test[,Date:=as.Date(Date)]

# separating out the elements of the date column for the train set
train[,month:=as.integer(format(Date, "%m"))]
train[,year:=as.integer(format(Date, "%y"))]
train[,weekyear:=as.integer(format(Date, "%V"))]
train[,Store:=as.factor(as.numeric(Store))]

test[,month:=as.integer(format(Date, "%m"))]
test[,year:=as.integer(format(Date, "%y"))]
test[,weekyear:=as.integer(format(Date, "%V"))]
test[,Store:=as.factor(as.numeric(Store))]

# replace NA with 0
store[ Promo2SinceWeek=='NA', store:=0]

# removing the date column (since elements are extracted) and also StateHoliday which has a lot of NAs (may add it back in later)
train <- merge(train,store, by='Store')
test <- merge(test,store, by='Store')

# create a promo 2 flag
m_dict  <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
create_promo_2_flag  <- function(r, dt) {
   # check if promo2 is enabled
   if( r[which(colnames(dt)=="Promo2")] == 1) {
      #check if this is the month and year of promo 2
      year  <- r[which(colnames(dt)=="Promo2SinceYear")]
      weekyear <- r[which(colnames(dt)=="weekyear")]

      # check if weeyear is NA
      if( weekyear=="NA" ) {
         weekyear <- 0
      }

      # if after promo2year and promo week
      if(r[which(colnames(dt)=="Promo2SinceYear")] <= year &&
            r[which(colnames(dt)=="Promo2SinceWeek")] <= weekyear) {
         # check if the current month is inside PromoInterval
         prom_month  <- m_dict[as.integer(r[which(colnames(dt)=="month")])]
         prom_interval  <- r[which(colnames(dt)=="PromoInterval")]
         if (length(grep(prom_month, prom_interval)) >0) {
            1
         } else {
            0
         }
      }
      else {
         0
      }
   } else {
      0
   }
}
train[,Promo2Now:=as.factor(apply(train, 1, FUN=create_promo_2_flag, train))]
test[,Promo2Now:=as.factor(apply(test, 1, FUN=create_promo_2_flag, test))]

# create the reopened date
reopened.day <- max(train[ , .N,by=Date][N==935,Date])+1
closed.day <- min(train[ , .N,by=Date][N==935,Date])
closed.stores  <- train[ , .N, by = Store][N<941, Store]

train$daySinceReopening  <- -1
train[which(train$Date>=reopened.day & train$Store %in% closed.stores)]$daySinceReopening  <-
   train[which(train$Date>=reopened.day & train$Store %in% closed.stores)]$Date - reopened.day
test$daySinceReopening  <- -1
test[which(test$Date>=reopened.day & test$Store %in% closed.stores)]$daySinceReopening  <-
   test[which(test$Date>=reopened.day & test$Store %in% closed.stores)]$Date - reopened.day


# remove the columns used to create the previous flag
train[, PromoInterval:=NULL]
train[, Promo2SinceYear:=NULL]
train[, Promo2SinceWeek:=NULL]

test[, PromoInterval:=NULL]
test[, Promo2SinceYear:=NULL]
test[, Promo2SinceWeek:=NULL]

# checking if there is statistical relevance on the new flag
promo.sales <- train[,.(MSALES = mean(Sales)), by=list(Store,year, Promo2Now)]
summary(aov( MSALES ~ Promo2Now, data=promo.sales))
TukeyHSD(aov( MSALES ~ Promo2Now, data=promo.sales))
# alone there is a correlation

# save files
save_dfs()


# histograms
par(mfrow=c(4,2))
par(mar = rep(2, 4))
hist(train$Sales)
plot(train[,.(sum(Sales)), by=list(DayOfWeek, year)])
plot(train[,.(sum(Sales)), by=Promo])

# how are the state holidays sales
train[ StateHoliday!='0' ,.(MSALES=mean(Sales)), by=list(Date)]
state.holiday <- train[ StateHoliday!='0' ,.(MSALES=mean(Sales)), by=list(Store, Date)]
ggplot(state.holiday[MSALES>0,],
       aes(x=Date, y=MSALES)) + geom_point(shape=1)

# get the holiday names to make a correspondence between years



# store types
plot(train[,.(mean(Sales)), by=Assortment])
plot(train[,.(mean(Sales)), by=StoreType])

# is there a pattern for storetype
sales.storetype <- train[,.(MSALES = mean(Sales)), by=list(Store,StoreType, year)]
ggplot(sales.storetype[sample(nrow(sales.storetype), 600),],
       aes(x=Store, y=MSALES, color=StoreType, group=year, shape=as.factor(year))) + geom_point(shape=1)
# b is better.

# is there a pattern for Assortment
sales.asssortment <- train[,.(MSALES = mean(Sales)), by=list(Store,Assortment, year)]
ggplot(sales.asssortment[sample(nrow(sales.asssortment), 600),],
       aes(x=Store, y=MSALES, color=Assortment, group=year, shape=as.factor(year))) + geom_point(shape=1)
# b is better.

# does competition distance changes anything?
sales.store.competition.year <- train[,.(MSALES = mean(Sales)), by=list(Store,CompetitionDistance, year)]
ggplot(sales.store.competition.year[,],
       aes(x=log(CompetitionDistance), y=MSALES, color=year)) + geom_point(shape=1)

qplot( x=1:100, y=exp(1:100))
# between months and years 200
# 800 bad year 2015
sales.store.year.month <- train[,.(mean(Sales)), by=list(Store, year, month)]
ggplot(data=sales.store.year.month[Store %in% as.factor(800),],
       aes(x=month, y=V1, color=year, group=year)) +
   geom_line()
# years average sales per month are ok with average per day

# is there any changes between years?
sales.store.year.day <- train[,.(mean(Sales)), by=list(Store, year, DayOfWeek)]
ggplot(data=sales.store.year.day[Store %in% as.factor(200),],
       aes(x=DayOfWeek, y=V1, color=year, group=year)) +
   geom_line()
# some stores have a dropout and other are having good times

par(mfrow=c(1,1))
boxplot(train$Sales~train$StoreType+train$DayOfWeek)
boxplot(log(train$Sales+1)~train$StoreType+train$StateHoliday)
boxplot(train$Sales~train$month+train$year)
plot(train$Sales~train$month+train$year)

save_dfs <- function() {
   write.table(train, file="./intermediate/train_processed.csv", sep = ",", row.names = F)
   write.table(test, file="./intermediate/test_processed.csv", sep = ",",row.names = F)
}

