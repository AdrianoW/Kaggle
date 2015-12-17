setwd("~/Documents/Machine Learning/Kaggle/Rossman")
# Based on Ben Hamner script from Springleaf
# https://www.kaggle.com/benhamner/springleaf-marketing-response/random-forest-example

library(data.table)
library(readr)
library(xgboost)

#my favorite seed^^

cat("reading the train and test data\n")
train <- fread("./input/train.csv", stringsAsFactors = T)
test  <- fread("./input/test.csv", stringsAsFactors = T)
store <- fread("./input/store.csv", stringsAsFactors = T)

train <- fread("./intermediate//train_processed.csv", stringsAsFactors = T, header = T)
test <- fread("./intermediate//test_processed.csv", stringsAsFactors = T, header = T)

# removing the date column (since elements are extracted) and also StateHoliday which has a lot of NAs (may add it back in later)
train <- merge(train,store, by='Store')
test <- merge(test,store, by='Store')

# There are some NAs in the integer columns so conversion to zero
train[is.na(train)]   <- 0
test[is.na(test)]   <- 0

cat("train data column names and details\n")
names(train)
str(train)
summary(train)
cat("test data column names and details\n")
names(test)
str(test)
summary(test)

# looking at only stores that were open in the train set
# may change this later
train <- train[ which(train$Open=='1'),]
train <- train[ which(train$Sales!='0'),]

# seperating out the elements of the date column for the train set
train$month <- as.integer(format(as.IDate(train$Date), "%m"))
train$year <- as.integer(format(as.IDate(train$Date), "%y"))
train$day <- as.integer(format(as.IDate(train$Date), "%V"))

# removing the date column (since elements are extracted) and also StateHoliday which has a lot of NAs (may add it back in later)
train <- train[,-3,with=FALSE]

# seperating out the elements of the date column for the test set
test$month <- as.integer(format(as.IDate(test$Date), "%m"))
test$year <- as.integer(format(as.IDate(test$Date), "%y"))
test$day <- as.integer(format(as.IDate(test$Date), "%d"))

# removing the date column (since elements are extracted) and also StateHoliday which has a lot of NAs (may add it back in later)
test <- test[,-4,with=FALSE]

feature.names <- names(train)[c(1,2,5:18)]
cat("Feature Names\n")
feature.names

cat("assuming text variables are categorical & replacing them with numeric ids\n")
for (f in feature.names) {
   if (class(train[[f]])=="character") {
      levels <- unique(c(train[[f]], test[[f]]))
      train[[f]] <- as.integer(factor(train[[f]], levels=levels))
      test[[f]]  <- as.integer(factor(test[[f]],  levels=levels))
   }
}

cat("train data column names after slight feature engineering\n")
names(train)
cat("test data column names after slight feature engineering\n")
names(test)
tra<-train[,feature.names]
RMPSE<- function(preds, dtrain) {
   labels <- getinfo(dtrain, "label")
   elab<-exp(as.numeric(labels))-1
   epreds<-exp(as.numeric(preds))-1
   err <- sqrt(mean((epreds/elab-1)^2))
   return(list(metric = "RMPSE", value = err))
}
nrow(train)

tra <- train
unique(train$StateHoliday)
tra  <- train[ which(train$StateHoliday=='0'),]
h<-sample(nrow(tra),25000)

dval<-xgb.DMatrix(data=data.matrix(tra[h,c(1,2,5:18), with=F]),label=log(tra$Sales+1)[h])
dtrain<-xgb.DMatrix(data=data.matrix(tra[-h,c(1,2,5:18), with=F]),label=log(tra$Sales+1)[-h])
watchlist<-list(val=dval,train=dtrain)
param <- list(  objective           = "reg:linear",
                booster = "gbtree",
                eta                 = 0.02, # 0.06, #0.01,
                max_depth           = 10, #changed from default of 8
                subsample           = 0.9, # 0.7
                colsample_bytree    = 0.7 # 0.7
                #num_parallel_tree   = 2
                #alpha = 0.0001,
                #lambda = 1
)


clf_normal <- xgb.train(   params              = param,
                    data                = dtrain,
                    nrounds             = 3500, #300, #280, #125, #250, # changed from 300
                    verbose             = 0,
                    early.stop.round    = 20,
                    watchlist           = watchlist,
                    maximize            = FALSE,
                    feval=RMPSE
)
te  <- data.matrix(test[which(test$StateHoliday=='0'),!c("Id"), with=F])
pred1_normal <- exp( predict(clf_normal,te) ) -1
submission <- data.frame(Id=test[which(test$StateHoliday=='0'),c('Id'), with=F], Sales=pred1_normal)

write_csv(submission, "./ouput/gbm_promo2_now.csv")

xgb.plot.importance(xgb.importance(feature_names = ))
names(test)[]

# just holidays
tra  <- train[ which(train$StateHoliday!='0'),]
h<-sample(nrow(tra),nrow(tra)*.2)
dval<-xgb.DMatrix(data=data.matrix(tra[h,c(1,2,5:20), with=F]),label=log(tra$Sales+1)[h])
dtrain<-xgb.DMatrix(data=data.matrix(tra[-h,c(1,2,5:20), with=F]),label=log(tra$Sales+1)[-h])
watchlist<-list(val=dval,train=dtrain)
param <- list(  objective           = "reg:linear",
                booster = "gbtree",
                eta                 = 0.01, # 0.06, #0.01,
                max_depth           = 5, #changed from default of 8
                subsample           = .7, # 0.7
                colsample_bytree    = 0.85 # 0.7
                num_parallel_tree   = 2
                alpha = 0.0001,
                lambda = 1
)


clf_holiday <- xgb.train(   params              = param,
                           data                = dtrain,
                           nrounds             = 6000, #300, #280, #125, #250, # changed from 300
                           verbose             = 0,
                           #early.stop.round    = 200,
                           watchlist           = watchlist,
                           maximize            = FALSE,
                           feval=RMPSE
)
te  <- data.matrix(test[which(test$StateHoliday=='a'),!c("Id"), with=F])
pred1_holiday <- exp(predict(clf_holiday, te)) -1
subm_holiday <- data.frame(Id=test[which(test$StateHoliday=='a'),c('Id'),with=F], Sales=pred1_holiday)

sub_final  <- rbind(submission, subm_holiday)
sub_final[test$Open=='0','Sales'] = 0
cat("saving the submission file\n")
write_csv(sub_final, "rf_mesclada.csv")


pred_train <- exp(predict(clf, data.matrix(train[,feature.names]))) -1
plot(log(pred_train+1),(log(pred_train+1) - log(train$Sales+1))/log(pred_train+1) )


# make a test of predicting store by store
store_1  <- train[ which(train$Store=='1'),]
store_2  <- train[ which(train$Store=='2'),]


plot($*tra$SchoolHoliday, tra$Sale)
t  <- as.factor(tra$StateHoliday)
t
