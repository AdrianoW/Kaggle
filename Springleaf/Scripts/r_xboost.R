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

# cols
cols_big_empty = c('VAR_0074', 'VAR_0206', 'VAR_0208', 'VAR_0209', 'VAR_0210', 'VAR_0211', 'VAR_0270', 'VAR_0284',
                   'VAR_0289', 'VAR_0290', 'VAR_0311', 'VAR_0340', 'VAR_0345', 'VAR_0346', 'VAR_0347', 'VAR_0348',
                   'VAR_0349', 'VAR_0350', 'VAR_0368', 'VAR_0369', 'VAR_0370', 'VAR_0403', 'VAR_0408', 'VAR_0410',
                   'VAR_0419', 'VAR_0427', 'VAR_0465', 'VAR_0475', 'VAR_0492', 'VAR_0494', 'VAR_0495', 'VAR_0073',
                   'VAR_0075', 'VAR_0156', 'VAR_0157', 'VAR_0158', 'VAR_0159', 'VAR_0166', 'VAR_0167', 'VAR_0168',
                   'VAR_0176', 'VAR_0177', 'VAR_0178', 'VAR_0179', 'VAR_0217')

train <- read_csv("../input/train_processed.csv")
test  <- read_csv("../input/test_processed.csv")
#val.2  <- read_csv("../Preprocessing/val2.csv")
#tr <- read_csv("../Preprocessing/train.csv")
test <- read_csv("../Preprocessing/test.csv")

cols_class_low  <-  read_csv('../Preprocessing/class_low.cols')
cols_class_high <-read_csv('../Preprocessing/class_high.cols')
cols_vals<-read_csv('../Preprocessing/vals.cols')

h <- sample(nrow(train), 120000)
val<-train[-h,]
tr <-train[h,]
rm(train)

k_group  <- read_csv('../Preprocessing/pred_train.csv')
train  <- cbind(train, k_group)
k_group  <- read_csv('../Preprocessing/pred_test.csv')
test  <- cbind(test, k_group)


# generate 2 validation.
h <- sample(nrow(train), 130000)
tr <-train[h,]
val<-train[-h,]



h <- sample(nrow(val), round(0.50*nrow(val)))
base  <- val[h,]
meta  <- val[-h,]

# testing removal of features
feature.names <- setdiff(names(train), c('target', 'ID'))
fn_no_dates  <-  setdiff(feature.names, datecolumns)
fn_no_big_empty  <- setdiff(feature.names, cols_big_empty)
fn_no_big_empty_dates  <- setdiff(feature.names, c(cols_big_empty, datecolumns))

features  <- fn_no_big_empty_dates
# put into the dmatrix used with xgboost
#tr  <- rbind(tr, val.2)
dtrain_full <- xgb.DMatrix(data.matrix(train[,features]), label=train$target)
dtrain <- xgb.DMatrix(data.matrix(tr[,features]), label=tr$target)
dval <- xgb.DMatrix(data.matrix(val[,features]), label=val$target)

dbase <- xgb.DMatrix(data.matrix(base[,features]), label=base$target)
dmeta <- xgb.DMatrix(data.matrix(meta[,features]), label=meta$target)

# train the model
watchlist <- list( d1=dval, d2= dtrain)
#watchlist <- watchlist <- list(eval = dval.2, train = dtrain)
param <- list(  objective           = "binary:logistic",
                # booster = "gblinear",
                eta                 = 0.01, # 0.06, #0.01,
                max_depth           = 16, #changed from default of 8
                subsample           = 0.95, # 0.7
                colsample_bytree    = 0.8, # 0.7
                eval_metric         = "auc",
                nthread = 6,
                alpha = 0.0001,
                lambda = 1
)

# best model so far
# max_depth 15, subsample 1, bytree .8, lamda 1
clf_base <- xgb.train(params              = param,
                    data                = dtrain,
                    nrounds             = 1300, #300, #280, #125, #250, # changed from 300
                    verbose             = 1,
                    early.stop.round    = 25,
                    watchlist           = watchlist,
                    maximize            = TRUE,
                    #nthread = 2,
                    nfold = 3
                    )
#best 408

submission <- data.frame(ID=test$ID)

# create the submission file
submission$target <- NA
for (rows in split(1:nrow(test), ceiling((1:nrow(test))/10000))) {
   submission[rows, "target"] <- predict(clf_base, data.matrix(test[rows,features]))
}
cat("saving the submission file\n")
write_csv(submission, "../Training/lastKnoDates.csv")

# create the features for the meta learner
xgb.save(clf_base, '../Training/last.model')
#clf_base  <- xgb.load('../Training/base.xgb_e.01_md16_ss.95_byt.8_aph.0001_lamb1_nodate.model')
xgb_pred  <- predict(clf_base,  data.matrix(train[,features]))
meta_add  <- cbind(train, xgb_pred)
xgb_pred  <- predict(clf_base,  data.matrix(test[,features]))
test_add  <- cbind(test, xgb_pred)

clf_base  <- xgb.load('../Training/xgb_e.01_md16_ss.95_byt.8_aph.0001_lamb1.model')
xgb1_pred  <- predict(clf_base,  data.matrix(train[,features]))
meta_add  <- cbind(meta_add, xgb1_pred)
xgb1_pred  <- predict(clf_base,  data.matrix(test[,features]))
test_add  <- cbind(test_add, xgb1_pred)

clf_base  <- xgb.load('../Training/xgb_e.01_md16_ss.95_byt.8_aph.0001_lamb1_nodate.model')
xgb2_pred  <- predict(clf_base,  data.matrix(train[,features]))
meta_add  <- cbind(meta_add, xgb2_pred)
xgb2_pred  <- predict(clf_base,  data.matrix(test[,features]))
test_add  <- cbind(test_add, xgb2_pred)

k_group  <- read_csv('../Preprocessing/pred_train.csv')
meta_add  <- cbind(meta_add, k_group)
k_group  <- read_csv('../Preprocessing/pred_test.csv')
test_add  <- cbind(test_add, k_group)

## split for test of meta learner
h <- sample(nrow(meta_add), 120000)
tr_meta <-meta_add[h,]
val_meta<-meta_add[-h,]

# train meta learner
features_meta <- setdiff(names(tr_meta), c('target', 'ID'))
features_meta  <- setdiff(features_meta, c(cols_big_empty, datecolumns))
dmeta_train <- xgb.DMatrix(data.matrix(tr_meta[,features_meta]), label=tr_meta$target)
dmeta_val <- xgb.DMatrix(data.matrix(val_meta[,features_meta]), label=val_meta$target)

# train the model
watchlist_meta <- list(train = dmeta_train, valid=dmeta_val)
param_meta <- list(  objective           = "binary:logistic",
                # booster = "gblinear",
                eta                 = 0.01, # 0.06, #0.01,
                #max_depth           = 5, #changed from default of 8
                #subsample           = 0.95, # 0.7
                #colsample_bytree    = 0.8, # 0.7
                eval_metric         = "auc",
                nthread = 6
                #alpha = 0.0001,
                #lambda = 1
)

# best model so far
# max_depth 15, subsample 1, bytree .8, lamda 1
clf_meta <- xgb.train(params              = param_meta,
                      data                = dmeta_train,
                      nrounds             = 50, #300, #280, #125, #250, # changed from 300
                      verbose             = 1,
                      #early.stop.round    = 25,
                      watchlist           = watchlist_meta,
                      maximize            = TRUE,
                      #nthread = 2,
                      nfold = 5
)

xgb.save(clf_meta, '../Training/winner_meta.model')

submission <- data.frame(ID=test_add$ID)

# create the submission file
submission$target <- NA
for (rows in split(1:nrow(test), ceiling((1:nrow(test))/10000))) {
   submission[rows, "target"] <- predict(clf_meta, data.matrix(test_add[rows,features_meta]))
}
cat("saving the submission file\n")
write_csv(submission, "../Training/test_add.csv")

sum(train$target>.5)

# save the validation output
submission.val <- data.frame()
submission.val$target <- NA
for (rows in split(1:nrow(test), ceiling((1:nrow(test))/10000))) {
   submission.val[rows, "target"] <- predict(clf, data.matrix(val.2[rows,feature.names]))
}
cat("saving the submission file\n")
write_csv(submission.val, "../Training/xgb_val.csv")

# Get the feature real names
names <- dimnames(dtrain)[[2]]

# Compute feature importance matrix
importance_matrix <- xgb.importance(names, model = clf)
xgb.plot.importance(importance_matrix[1:10,])

# load an old model
clf  <- xgb.load('../Training/xgb_e.01_md16_ss.95_byt.8_aph.0001_lamb1_nodate.model')
xgb.dump(clf, fname = './xgboost.model.dump')
importance  <- xgb.importance(model=clf, feature_names = features)
