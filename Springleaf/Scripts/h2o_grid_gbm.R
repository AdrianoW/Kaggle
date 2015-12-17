setwd("~/Documents/Machine Learning/Kaggle/Spring/r")
# The readr library is the best way to read and write CSV files in R
library(readr)
library(ROCR)
require(dplyr)
library(h2o)
my_h2o <- h2o.init(nthreads = 6,max_mem_size = "10G")
set.seed(8472397)

train <- read_csv("../input/train_processed.csv")
test  <- read_csv("../input/test_processed.csv")

datecolumns = c("VAR_0073", "VAR_0075", "VAR_0156", "VAR_0157", "VAR_0158", "VAR_0159", "VAR_0166", "VAR_0167", "VAR_0168", "VAR_0176", "VAR_0177", "VAR_0178", "VAR_0179", "VAR_0204", "VAR_0217")
cols_big_empty = c('VAR_0074', 'VAR_0206', 'VAR_0208', 'VAR_0209', 'VAR_0210', 'VAR_0211', 'VAR_0270', 'VAR_0284',
                   'VAR_0289', 'VAR_0290', 'VAR_0311', 'VAR_0340', 'VAR_0345', 'VAR_0346', 'VAR_0347', 'VAR_0348',
                   'VAR_0349', 'VAR_0350', 'VAR_0368', 'VAR_0369', 'VAR_0370', 'VAR_0403', 'VAR_0408', 'VAR_0410',
                   'VAR_0419', 'VAR_0427', 'VAR_0465', 'VAR_0475', 'VAR_0492', 'VAR_0494', 'VAR_0495', 'VAR_0073',
                   'VAR_0075', 'VAR_0156', 'VAR_0157', 'VAR_0158', 'VAR_0159', 'VAR_0166', 'VAR_0167', 'VAR_0168',
                   'VAR_0176', 'VAR_0177', 'VAR_0178', 'VAR_0179', 'VAR_0217')
feature.names <- setdiff(names(train), c('target', 'ID'))
fn_no_dates  <-  setdiff(feature.names, datecolumns)
fn_no_big_empty  <- setdiff(feature.names, cols_big_empty)
fn_no_big_empty_dates  <- setdiff(feature.names, c(cols_big_empty, datecolumns))

h <- sample(nrow(train), 120000)
tr <-train[h,]
val<-train[-h,]
h <- sample(nrow(val), round(0.50*nrow(val)))
val.1  <- val[h,]
val.2  <- val[-h,]
rm(train)
feature.names <- names(tr)[(3:ncol(tr)-1)]

my_h2o_train<-as.h2o(my_h2o,train)
my_h2o_train<-as.h2o(my_h2o,tr)
my_h2o_val<-as.h2o(my_h2o,val.1)
my_h2o_val.2<-as.h2o(my_h2o,val.2)
my_h2o_test<-as.h2o(my_h2o,test)
#features_full  <- setdiff(colnames(my_h2o_train), c('ID', 'target'))
h2o.assign(my_h2o_train, key="train.hex")
h2o.assign(my_h2o_val, key="val1")
h2o.assign(my_h2o_val.2, key="val2")
h2o.assign(my_h2o_test, key="test.hex")

#my_h2o_val <- as.h2o(my_h2o,val10k)
my_h2o_train[, "target"] <- as.factor(my_h2o_train[, "target"])
my_h2o_val[, "target"] <- as.factor(my_h2o_val[, "target"])
my_h2o_val.2[, "target"] <- as.factor(my_h2o_val.2[, "target"])
my_h2o_train <- h2o.removeVecs(my_h2o_train, "ID")
my_h2o_val <- h2o.removeVecs(my_h2o_val, "ID")
my_h2o_val.2 <- h2o.removeVecs(my_h2o_val.2, "ID")

ntrees_opt <- c(150)
maxdepth_opt <- c(3, 5, 7)
learnrate_opt <- c(0.01,0.1)
balance_classes <- c(FALSE)
nbins  <-  c(5, 10)
nbins_cats  <-  c(5,40)
min_rows  <- c(5,10,15)
hyper_parameters <- list(ntrees=ntrees_opt, max_depth=maxdepth_opt, learn_rate=learnrate_opt,
                         balance_classes=balance_classes, nbins=nbins, nbins_cats=nbins_cats,
                         min_rows=min_rows)

grid <- h2o.grid("gbm", hyper_params =hyper_parameters,
                 y = "target",
                 x = c(feature.names,'k_class'), distribution="bernoulli",
                 training_frame = my_h2o_train,
                 validation_frame =my_h2o_val)

gbm  <-  h2o.gbm(y = "target",
                 x = c(feature.names,'k_class'), distribution="bernoulli",
                 training_frame = my_h2o_train,
                 validation_frame =my_h2o_val,
                 ntrees = 500,
                 learn_rate = .01
                  )

kmeans  <- h2o.kmeans(training_frame = my_h2o_train, k = 10)
insert_k_column(kmeans, my_h2o_train)
insert_k_column(kmeans, my_h2o_val)
insert_k_column(kmeans, my_h2o_val.2)
insert_k_column(kmeans, my_h2o_test)
h2o.table(my_h2o_val.2[, c('k_class', 'target')])

# print grid search
grid_models_big  <- grid_models
grid_models <- lapply(grid@model_ids, function(model_id) { model = h2o.getModel(model_id) })
for (i in 1:length(grid_models)) {
   print ("==============================================================")
   params <- grid_models[[i]]@allparameters
   print(sprintf("bins_cat:%f balance_class:%f max_depth: %f min_rows:%f learn_rate:%f nbins:%f ",
                 params$nbins_cat,
                 params$balance_classes,
                 params$max_depth,
                 params$min_rows,
                 params$learn_rate,
                 params$nbins))

   auc  <-  calculate_auc(grid_models[[i]], my_h2o_val, val.1)
   print(sprintf("auc train: %f", h2o.auc(grid_models[[i]])))
   print(sprintf("auc val1: %f", auc))

   auc2  <-  calculate_auc(grid_models[[i]], my_h2o_val.2, val.2)
   print(sprintf("auc val2: %f", auc2))

   print(sprintf("DIFF auc: %f", auc-auc2))
}
# calculate the metric for validation and the parameters used
calculate_auc  <- function(model, newdata, val_data) {

   print(h2o.varimp(model)$variable[(1:10)])

   my_pr <- as.data.frame(h2o.predict(model, newdata=newdata))
   # Extract the relevant variables from the dataset.
   sdata <- subset(val_data[,], select=c("ID", "target"))
   output_test <- cbind(sdata, my_pr)

   pred  <- prediction(output_test$p1, val_data$target)
   perf <- performance(pred, measure = "tpr", x.measure = "fpr")
   auc <- performance(pred, measure = "auc")
   auc <- auc@y.values[[1]]
}

insert_k_column  <- function(model, data) {
   k_class  <- as.factor(h2o.predict(model, data))
   data['k_class']  <- k_class
}

#roc.data <- data.frame(fpr=unlist(perf@x.values),
#                       tpr=unlist(perf@y.values),
#                       model="GLM")
#ggplot(roc.data, aes(x=fpr, ymin=0, ymax=tpr)) +
#   geom_ribbon(alpha=0.2) +
#   geom_line(aes(y=tpr)) +
#   ggtitle(paste0("ROC Curve w/ AUC=", auc))

# predict the final value
create_submission  <- function(model, h2o_data, rdata) {
   my_pr <- as.data.frame(h2o.predict(model, newdata=h2o_data))
   # Extract the relevant variables from the dataset.
   sdata <- subset(rdata[,], select=c("ID"))
   output_test <- cbind(sdata, my_pr)[,c("ID", "p1")]
   colnames(output_test) <- c("ID", "target")
   write_csv(output_test, '../Out/h20_gbm_grid_4.csv')
}

