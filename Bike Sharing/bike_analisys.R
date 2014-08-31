# import the libraries we are going to use
# library(caret)
library(corrgram)
library(randomForest)
# library(e1071)
library(stringi)
setwd("~/Documents/Box Sync/Box Sync/DSR/Machine Learning/Kaggle/Bike Sharing")
# load the data
df = read.csv(file = 'train.csv')
df_test = read.csv(file = 'test.csv')
summary(df)

# datetime - hourly date + timestamp
# season -  1 = spring, 2 = summer, 3 = fall, 4 = winter
# holiday - whether the day is considered a holiday
# workingday - whether the day is neither a weekend nor holiday
# weather - 1: Clear, Few clouds, Partly cloudy, Partly cloudy
# 2: Mist + Cloudy, Mist + Broken clouds, Mist + Few clouds, Mist
# 3: Light Snow, Light Rain + Thunderstorm + Scattered clouds, Light Rain + Scattered clouds
# 4: Heavy Rain + Ice Pallets + Thunderstorm + Mist, Snow + Fog
# temp - temperature in Celsius
# atemp - "feels like" temperature in Celsius
# humidity - relative humidity
# windspeed - wind speed
# casual - number of non-registered user rentals initiated
# registered - number of registered user rentals initiated
# count - number of total rentals

# create the factors according to file distribution below
df$season  <- factor(df$season, labels = c('spring', 'summer', 'fall', 'winter'))
df$weather <-  factor(df$weather)

df_test$casual  <- 0
df_test$registered  <- 0
df_test$season  <- factor(df_test$season, labels = c('spring', 'summer', 'fall', 'winter'))
df_test$weather <-  factor(df_test$weather)


# check relationtship graph
cor(df[, 2:(length(df))])
# seems that temp, a temp humidity are highly correlated, season a little
corrgram(df, order=TRUE, lower.panel=panel.shade,
         upper.panel=panel.pie, text.panel=panel.txt,
         main="Correlation between vars")

# random forest with all
modelRF  <- randomForest( count ~.-datetime-casual-registered,data=df, importance = TRUE)
plot(modelRF)
summary(modelRF)
importance(modelRF, scale = TRUE)
varImpPlot(modelRF)

# keep some to test data and see how it goes
index <- 1:nrow(df)
testIdx  <- sample(index,replace = FALSE, size = nrow(df)*.90)

# create datasets
train  <- df[testIdx,]
test    <- df[-testIdx,]

# train and predict
modelRF <- randomForest( count ~.-datetime-casual-registered,data=train, importance = TRUE)
pred <-  predict(modelRF, newdata = test)
test$pred <- pred
modelRF$call
# lets calculate the error according to competition rules
err <- calculateError(test)
err

# remove other features
remove_Feat(modelRF, train, test)

# prepare file for submission
pred <-  predict(modelRF, newdata = df_test)
out  <- data.frame(df_test$datetime, ceiling(pred))
colnames(out) <- c('datetime','count')
write.csv(out, file='out_submission.csv', sep=",",row.names = FALSE,
          col.names=TRUE, quote = FALSE)


# error according to kaggle
calculateError <- function (data) {
   sqrt(sum((log(data$pred+1)-log(data$count+1))^2)/nrow(data))
}

remove_Feat  <- function(model,train,test) {
#    model  <- modelRF

   # number of features left to test
   n_feat  <- nrow(model$importance)

   #  loop testing all combinations
   result  <- data.frame(features=rep('NONO', n_feat), err=rep(-999.99, n_feat),stringsAsFactors = FALSE)

   # save the initial result
   err <- calculateError(test)
   result[1,] <-  c(as.character(model$call[[2]][3]), err)

   for (i in 1:(n_feat-1)) {
      # order by the worst feature and put it on the function call
      ord_feat <- as.data.frame(model$importance)
      worst_feat <- rownames(ord_feat[order(ord_feat$'%IncMSE', decreasing = FALSE),])[1]
      print(stri_paste('removing ', worst_feat, sep=" "))
      print(rownames(ord_feat))
      model$call[[2]][3] <- parse(text = paste0(model$call[[2]][3], "-",worst_feat))
      model <- eval(model$call)

      # predict the value and find the error, puting it into a var
      pred <-  predict(model, newdata = test)
      test$pred <- pred
   #    test$diff  <- test$pred - test$count

      # save the new parameter call and the error for it
      err <- calculateError(test)
      result[i,] <-  c(as.character(model$call[[2]][3]), err)
      print(stri_paste('error ', err, sep=" "))
   }

   # return the errors list
   return(result)
}

# lets try with SVM
library(e1071)
m_svm  <- svm(count ~+temp+atemp+humidity+holiday,data=train)
plot(m_svm)
summary(m_svm)
pred <-  predict(m_svm, newdata = test)
test$pred <- pred
test$pred[test$pred<0] <- 0
err <- calculateError(test)
err
# prepare file for submission
pred <-  predict(modelRF, newdata = df_test)
out  <- data.frame(df_test$datetime, ceiling(pred))
colnames(out) <- c('datetime','count')
write.csv(out, file='out_submission.csv', sep=",",row.names = FALSE,
          col.names=TRUE, quote = FALSE)


featurePlot( unclass(test$season)[1:leng(test$season)], test$count )



library(Metrics)  # for beautiful rmsle error calculation
library(rpart)    # for decision tree algorithm

library(caret)    # for data partitioning (createDataPartition)
setwd("~/Documents/Box Sync/Box Sync/DSR/Machine Learning/Kaggle/Bike Sharing")
set_up_features <- function(df) {

   df$datetime <- strptime(df$datetime, format="%Y-%m-%d %H:%M:%S")
   df$hour <- as.factor(df$datetime$hour)
   df$wday <- as.factor(df$datetime$wday)
   df$month <- as.factor(df$datetime$mon)
   df$year <- as.factor(df$datetime$year + 1900)
   df
}

get_predictions <- function(fit, test) {
   Prediction <- predict(fit, test)
   Prediction[Prediction < 0 ] <- 0
   Prediction <- as.integer(Prediction)
   data.frame(datetime=strftime(test$datetime, format="%Y-%m-%d %H:%M:%S"), count=Prediction)
}

train_raw <- read.csv(
   "train.csv",
   colClasses = c(
      "character", # datetime
      "factor", # season
      "factor", # holiday
      "factor", # workingday
      "factor", # weather
      "numeric", # temp
      "numeric", # atemp
      "integer", # humidity
      "numeric", # windspeed
      "integer", # casual
      "integer", # registered
      "integer" # count
   ))

   train_raw <- set_up_features(train_raw)

   set.seed(415)
   inTrain <- createDataPartition(train_raw$count, p=0.7, list=F, times=1)
   train <- train_raw[inTrain, ]
   cv <- train_raw[-inTrain, ]

   # random forest
   dtfit <- randomForest(count ~
                     hour +
                     month +
                     year +
                     weather +
                     atemp +

                     workingday +
                     holiday +
                     windspeed +
                     humidity +
                     season,
                  data=train)

   print(rmsle(cv$count, get_predictions(dtfit, cv)$count))

   # linear regression
   dtfit <- lm(count ~
                            hour +
                            month +
                            year +
                            weather +
                            atemp +

                            workingday +
                            holiday +
                            windspeed +
                            humidity +
                            season,
                         data=train)

   print(rmsle(cv$count, get_predictions(dtfit, cv)$count))
   # Other useful functions
   coefficients(dtfit) # model coefficients
   confint(dtfit, level=0.95) # CIs for model parameters
   fitted(dtfit) # predicted values
   residuals(dtfit) # residuals
   anova(dtfit) # anova table
   vcov(dtfit) # covariance matrix for model parameters
   influence(dtfit) # regression diagnostics

   # svm
   library(e1071)
   dtfit <- svm(  count ~
                  hour +
                  month +
                  year +
                  weather +
                  atemp +

                  workingday +
                  holiday +
                  windspeed +
                  humidity +
                  season,
               data=train, kernel = "polynomial", gamma = 1, degree = 2, type='nu-regression', nu = 0.5)

   print(rmsle(cv$count, get_predictions(dtfit, cv)$count))

# prepare extraction

test_raw <- read.csv(
   "test.csv",
   colClasses = c(
      "character", # datetime
      "factor", # season
      "factor", # holiday
      "factor", # workingday
      "factor", # weather
      "numeric", # temp
      "numeric", # atemp
      "integer", # humidity
      "numeric" # windspeed
   ))

test_raw <- set_up_features(test_raw)
pred <- get_predictions(dtfit, test_raw)$count
out  <- data.frame(datetime= test_raw$datetime, count=ceiling(pred))

write.csv(out, file='out_submission.csv', sep=",",row.names = FALSE,
          col.names=TRUE, quote = FALSE)
