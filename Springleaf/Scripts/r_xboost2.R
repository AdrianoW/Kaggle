setwd("~/Documents/Machine Learning/Kaggle/Spring/r")
library(readr)
library(xgboost)
library(h2o)
my_h2o <- h2o.init(nthreads = 6,max_mem_size = "10G")
set.seed(8472397) #seed bag1:8, then eta=0.06not0.04&nround125not250: bag2:64, bag3:6, bag4:88, bag5: 0.03-300-seed666
#bag6:16, train[1:80000,], val=train[80001:120000,], 0.06, 125  #bag7: 888,train[65000:145000,], val=train[1:40000,], 0.06, 125
#bag8: 888,train[65000:145000,], val=train[1:40000,], 0.03, 300

#seed bag9:9999, 0.02,300,random

#bag10:425, bag11:718, bag12:719, bag13:720, bag14:721


cat("reading the train and test data\n")
train <- read_csv("../input/train.csv")
test  <- read_csv("../input/test.csv")

# get the amount of different values for each column
train.unique.count=lapply(train, function(x) length(unique(x)))

# filter the columns with a single value and 2 different values
train.unique.count_1=unlist(train.unique.count[unlist(train.unique.count)==1])
train.unique.count_2=unlist(train.unique.count[unlist(train.unique.count)==2])
train.unique.count_2=train.unique.count_2[-which(names(train.unique.count_2)=='target')]

delete_const=names(train.unique.count_1)
delete_NA56=names(which(unlist(lapply(train[,(names(train) %in% names(train.unique.count_2))], function(x) max(table(x,useNA='always'))))==145175))
delete_NA89=names(which(unlist(lapply(train[,(names(train) %in% names(train.unique.count_2))], function(x) max(table(x,useNA='always'))))==145142))
delete_NA918=names(which(unlist(lapply(train[,(names(train) %in% names(train.unique.count_2))], function(x) max(table(x,useNA='always'))))==144313))

#VARS to delete
#safe to remove VARS with 56, 89 and 918 NA's as they are covered by other VARS
print(length(c(delete_const,delete_NA56,delete_NA89,delete_NA918)))

train=train[,!(names(train) %in% c(delete_const,delete_NA56,delete_NA89,delete_NA918))]
test=test[,!(names(test) %in% c(delete_const,delete_NA56,delete_NA89,delete_NA918))]

# From manual data analysis
datecolumns = c("VAR_0073", "VAR_0075", "VAR_0156", "VAR_0157", "VAR_0158", "VAR_0159", "VAR_0166", "VAR_0167", "VAR_0168", "VAR_0176", "VAR_0177", "VAR_0178", "VAR_0179", "VAR_0204", "VAR_0217")

train_cropped <- train[datecolumns]
train_cc <- data.frame(apply(train_cropped, 2, function(x) as.double(strptime(x, format='%d%b%y:%H:%M:%S', tz="UTC")))) #2 = columnwise

for (dc in datecolumns){
   train[dc] <- NULL
   train[dc] <- train_cc[dc]
}

train_cc <- NULL
train_cropped <- NULL
gc()

test_cropped <- test[datecolumns]
test_cc <- data.frame(apply(test_cropped, 2, function(x) as.double(strptime(x, format='%d%b%y:%H:%M:%S', tz="UTC")))) #2 = columnwise

for (dc in datecolumns){
   test[dc] <- NULL
   test[dc] <- test_cc[dc]
}

test_cc <- NULL
test_cropped <- NULL
gc()


# safe target and put it at the end again
train_target <- train$target
train$target <- NULL
train$target <- train_target

# names(train)  # 1934 variables

for (f in feature.names) {
   if (class(train[[f]])=="character") {
      levels <- unique(c(train[[f]], test[[f]]))
      train[[f]] <- as.integer(factor(train[[f]], levels=levels))
      test[[f]]  <- as.integer(factor(test[[f]],  levels=levels))
   }
}

cat("replacing missing values with -1\n")
train[is.na(train)] <- -1
test[is.na(test)]   <- -1
write_csv(train, '../Input/train_processed.csv')
write_csv(test, '../Input/test_processed.csv')
train <- read_csv("../input/train_processed.csv")
test  <- read_csv("../input/test_processed.csv")
#val.2  <- read_csv("../Preprocessing/val2.csv")
#tr <- read_csv("../Preprocessing/train.csv")
test <- read_csv("../Preprocessing/test.csv")

feature.names <- setdiff(names(val.2), c('target', 'ID'))
h <- sample(nrow(train), 120000)
val<-train[-h,]
tr <-train[h,]
rm(train)

# generate 2 validation.
h <- sample(nrow(train), 120000)
tr <-train[h,]
val<-train[-h,]
h <- sample(nrow(val), round(0.50*nrow(val)))
val.1  <- val[h,]
val.2  <- val[-h,]

# put into the dmatrix used with xgboost
dtrain <- xgb.DMatrix(data.matrix(tr[,feature.names]), label=tr$target)
dval.1 <- xgb.DMatrix(data.matrix(val.1[,feature.names]), label=val.1$target)
dval.2 <- xgb.DMatrix(data.matrix(val.2[,feature.names]), label=val.2$target)

# train the model
watchlist <- watchlist <- list(eval = dval.1, train = dtrain)
#watchlist <- watchlist <- list(eval = dval.2, train = dtrain)
param <- list(  objective           = "binary:logistic",
                # booster = "gblinear",
                eta                 = 0.01, # 0.06, #0.01,
                max_depth           = 16, #changed from default of 8
                subsample           = 0.95, # 0.7
                colsample_bytree    = 0.8, # 0.7
                eval_metric         = "auc",
                nthread = 2,
                alpha = 0.0001,
                lambda = 1
)
# best model so far
# max_depth 15, subsample 1, bytree .8, lamda 1
clf <- xgb.train(params              = param,
                    data                = dtrain,
                    nrounds             = 1200, #300, #280, #125, #250, # changed from 300
                    verbose             = 1,
                    early.stop.round    = 25,
                    watchlist           = watchlist,
                    maximize            = TRUE,
                    #nthread = 2,
                    nfold = 3
                    )
#best 408

xgb.save(clf, '../Training/xgb_e.01_md16_ss.95_byt.8_aph.0001_lamb1.model')
submission <- data.frame(ID=test$ID)
#clf <- xgb.load('../Training/xgb_e.01_md16_ss.95_byt.8_aph.0001_lamb1.model')

# create the submission file
submission$target <- NA
for (rows in split(1:nrow(test), ceiling((1:nrow(test))/10000))) {
   submission[rows, "target"] <- predict(clf, data.matrix(test[rows,feature.names]))
}
cat("saving the submission file\n")
write_csv(submission, "../Training/xgb_e.01_md16_ss.95_byt.8_aph.0001_lamb1.csv")

# save the validation output
submission.val <- data.frame()
#submission.val$target <- NA
submission.val[rows, "target"] <- predict(clf, data.matrix(val.2))

cat("saving the submission file\n")
write_csv(submission.val, "../Training/xgb_val.csv")

# Get the feature real names
names <- dimnames(dtrain)[[2]]

# Compute feature importance matrix
importance_matrix <- xgb.importance(names, model = clf)
xgb.plot.importance(importance_matrix[1:10,])

# load an old model
clf  <- xgb.load('./xgboost.model')
xgb.dump(clf, fname = './xgboost.model.dump')

